import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:edudrive/services/firestore_services.dart';
import 'package:edudrive/view/screens/dashboard_screen.dart';
import 'package:edudrive/view/screens/saveParentData.dart';
import 'package:edudrive/view/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';

class OtpVerifyScreen extends StatefulWidget {
  OtpVerifyScreen( {Key? key, required this.verificationId,required this.phoneNumber}) : super(key: key);
  final verificationId;
  final String phoneNumber;
  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = AppColor.whiteColor;
    const fillColor = AppColor.textFormFilledColor;
    const borderColor = AppColor.whiteColor;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: FontAssets.mediumText,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
    );

    return Scaffold(
       body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*.3,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("OTP Send to ${widget.phoneNumber} Number",style: FontAssets.mediumText.copyWith(color: Colors.white),),
                    SizedBox(height: 50,),
                    Directionality(
                      // Specify direction if desired
                      textDirection: TextDirection.ltr,
                      child: Pinput(
                        length: 6,
                        controller: pinController,
                        focusNode: focusNode,
                        // androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
                        // listenForMultipleSmsOnAndroid: true,

                        defaultPinTheme: defaultPinTheme,
                        validator: (value) {
                          if(value!.isEmpty){
                            return "Field can't be empty";
                          }else if(value.length<6){
                          return "Enter 6 Digit Code";
                          }else{
                            return null;
                          }
                        },
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        onCompleted: (pin) {
                          debugPrint('onCompleted: $pin');
                        },
                        onChanged: (value) {
                          debugPrint('onChanged: $value');
                        },
                        cursor: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 9),
                              width: 22,
                              height: 1,
                              color: focusedBorderColor,
                            ),
                          ],
                        ),
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: focusedBorderColor),
                          ),
                        ),
                        submittedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: focusedBorderColor),
                          ),
                        ),
                        errorPinTheme: defaultPinTheme.copyBorderWith(
                          border: Border.all(color: Colors.redAccent),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    CustomButton(
                      onTap: () async {
                        focusNode.unfocus();
                        if (formKey.currentState!.validate()) {
                          final credentials = PhoneAuthProvider.credential(
                              verificationId: widget.verificationId,
                              smsCode: pinController.text.toString());
                          try {
                          UserCredential userCredential =   await _auth.signInWithCredential(credentials);
                          var parentData =   await FirestoreServices().getParent(userCredential.user!.uid);
                          if(parentData.data()!=null){
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DashboardScreen()));
                          }
                          else{
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SaveParentData(phoneNumber: widget.phoneNumber)));
                          }

                          } catch (e) {
                            print(e.toString());
                            if(e.toString()=='[firebase_auth/invalid-verification-code] The sms verification code used to create the phone auth credential is invalid. Please resend the verification code sms and be sure use the verification code provided by the user.'){
                              Fluttertoast.showToast(
                                  msg: "Incorrect PIN. Please renter again",
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                              pinController.clear();
                            }
                          }
                        }
                      },
                      label: 'Verify',),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}
