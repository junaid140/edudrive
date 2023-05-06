import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:edudrive/view/screens/otp_verify_screen.dart';
import 'package:edudrive/view/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'auth_screen.dart';

class SignUpWithPhone extends StatefulWidget {
  const SignUpWithPhone({Key? key}) : super(key: key);

  static const routeName = '/sign_up_with_phone';

  @override
  State<SignUpWithPhone> createState() => _SignUpWithPhoneState();
}

class _SignUpWithPhoneState extends State<SignUpWithPhone> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();
  String initialCountry = 'PK';
  String? number;
  bool _isLoading = false;
  final auth=FirebaseAuth.instance;

  @override
  void initState() {
    _isLoading=false;
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColor.scaffoldBackgroundColor,
        title: Text(
          'eduDrive',
          style: FontAssets.largeText.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 28,
              color: AppColor.primaryButtonColor
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.2,
                ),
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ReuseableTitleText(title: "Mobile Number"),
                      IntlPhoneField(
                        cursorColor: AppColor.whiteColor,
                        dropdownTextStyle: FontAssets.mediumText,

                        dropdownIcon: Icon(Icons.arrow_drop_down,color: AppColor.whiteColor,),
                        initialCountryCode: "PK",

                        pickerDialogStyle: PickerDialogStyle(
                          countryCodeStyle: FontAssets.smallText,
                          countryNameStyle: FontAssets.mediumText,
                          searchFieldCursorColor: AppColor.whiteColor,
                          textStyle: FontAssets.smallText,


                          searchFieldInputDecoration: InputDecoration(
                            hintStyle: FontAssets.smallText,
                            hintText: "Select Country Code",
                            counterStyle: FontAssets.smallText,


                          )
                        ),

                        style: FontAssets.mediumText,

                        decoration: InputDecoration(
                          counterStyle: FontAssets.smallText,
                          contentPadding: EdgeInsets.only(left: 20),
                          hintText: '3012345678',
                          hintStyle: FontAssets.mediumText.copyWith(
                            color: AppColor.whiteColor.withOpacity(0.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              width: 2,
                              color: AppColor.whiteColor,
                            ),
                          ),
                          enabled: true,
                          enabledBorder:OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              width: 2,
                              color: AppColor.whiteColor,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              width: 2,
                              color: AppColor.whiteColor,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              width: 2,
                              color: Colors.red,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              width: 2,
                              color: AppColor.whiteColor,
                            ),
                          ),
                        ),

                        onChanged: (phone) {
                          print(phone.completeNumber);
                          number = phone.completeNumber;
                        },

                        onCountryChanged: (country) {
                          print('Country changed to: ' + country.name);
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CustomButton(
                        label: "Next",
                        loading: _isLoading,
                        onTap: () async {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });

                            await auth.verifyPhoneNumber(
                                    timeout: Duration(seconds: 60),
                                    phoneNumber: number,
                                    verificationCompleted:
                                        (PhoneAuthCredential credential) {},
                                    verificationFailed:
                                        (FirebaseAuthException e) {
                                      print('-----------------------------');
                                      print(e);
                                      if (e.toString() ==
                                          '[firebase_auth/invalid-phone-number] The format of the phone number provided is incorrect. Please enter the phone number in a format that can be parsed into E.164 format. E.164 phone numbers are written in the format [+][country code][subscriber number including area code]. [ Invalid format. ]') {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Enter Phone Number with country Code",
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      }
                                    },
                                    codeSent: (String verificationId,
                                        int? resendToken) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  OtpVerifyScreen(phoneNumber: number!,
                                                    verificationId: verificationId,
                                                  )));
                                    },
                                    codeAutoRetrievalTimeout: (e) {
                                      print(
                                          "This is Code Retrieval Timeout Error : $e");
                                    })
                                .then((value) {})
                                .onError((error, stackTrace) {
                              print(error);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AuthScreen1()));
                      },
                      child: RichText(text: TextSpan(
                        children: [
                          TextSpan(text: "Already have an account?", style: FontAssets.mediumText,),
                          TextSpan(text: "Sign In", style:  FontAssets.mediumText
                              .copyWith(fontWeight: FontWeight.bold),),
                        ]
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
