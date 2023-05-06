import 'package:edudrive/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../providers/auth.dart';
import '../../res/app_color/app_color.dart';
import '../../res/font_assets/font_assets.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'auth_screen.dart';
import 'dashboard_screen.dart';

class SaveParentData extends StatefulWidget {
  String phoneNumber;
   SaveParentData({Key? key,required this.phoneNumber}) : super(key: key);

  @override
  State<SaveParentData> createState() => _SaveParentDataState();
}

class _SaveParentDataState extends State<SaveParentData> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController name = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  bool _isLoading = false;
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
    }

    try {

      await FirestoreServices().addParent(FirebaseAuth.instance.currentUser!.uid, {
        'name': name.text,
        'email': "",
        'mobile': widget.phoneNumber,
        'uid':FirebaseAuth.instance.currentUser!.uid,
        'created_at':DateTime.now()}).then((value) {
        setState(() {
          _isLoading=false;
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DashboardScreen()));

      });


    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
      print(error);
    }
    if (mounted)
      setState(() {
        _isLoading = false;
      });
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    phoneNumber.text=widget.phoneNumber;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBackgroundColor,
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
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.05,),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReuseableTitleText(title: "Name"),
                          CustomTextField(
                            hint: 'name',
                            controller: name,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Field is empty';
                              }
                              else if (value.length<3) {
                                return 'Invalid Name';
                              }
                              else{
                                return null;
                              }
                            },
                            onSaved: (value) {
                            },
                          ),

                          ReuseableTitleText(title: "Phone Number"),
                          CustomTextField(
                            hint: 'Phone number',
                            controller:phoneNumber..text="${widget.phoneNumber}" ,
                            readOnly: true,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Field is empty';
                              }
                              else if (value.length<3) {
                                return 'Invalid Name';
                              }
                              else{
                                return null;
                              }
                            },
                            onSaved: (value) {
                            },
                          ),
                        ],
                      ),
                    SizedBox(height: 50,),
                    if (_isLoading)
                      CircularProgressIndicator(

                      )
                    else
                      CustomButton(
                        loading:_isLoading,
                        label: 'Create Account',
                        onTap: _submit,
                      ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
