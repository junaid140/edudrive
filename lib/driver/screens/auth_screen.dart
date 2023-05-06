import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../helpers/http_exception.dart';
import '../providers/auth.dart';
import '../res/app_color/app_color.dart';
import '../res/font_assets/font_assets.dart';
import '../widgets/reuseable_title_text.dart';
import '../widgets/tap_to_action.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'car_info_screen.dart';


enum AuthMode { Signup, Login }


class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  static const routeName = '/auth';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _passwordController = TextEditingController();
  final _focusNode = FocusNode();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'name': '',
    'email': '',
    'mobile': '',
    'password': '',
  };
  void _showErrorDialog(String message,context) {
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

  Future<void> _submit(context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        print("----login");
        await Provider.of<Auth>(context, listen: false).login(
          email: (_authData['email'] as String).trim(),
          password: _authData['password'] as String,
          context:context,
        );

      }
      else {

        await Provider.of<Auth>(context, listen: false).signupWithEmail(
          email: (_authData['email'] as String).trim(),
          password: _authData['password'] as String,
          name: (_authData['name'] as String).trim(),
          mobile: (_authData['mobile'] as String).trim(),
          context: context
        );
        Navigator.of(context).pushNamed(CarInfoScreen.routeName);

      }
    } on FirebaseAuthException catch (e) {
      var errorMessage = 'Firebase Authentication failed';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      }
      _showErrorDialog(errorMessage,context);
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      } else if (error.toString().contains('User does not exist')) {
        errorMessage = 'User does not exist.';
      }
      _showErrorDialog(errorMessage,context);
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage,context);
      print(error);
    }
    if (mounted)
      setState(() {
        _isLoading = false;
      });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
    _formKey.currentState!.reset();
    _passwordController.clear();
  }



  @override
  void dispose() {
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        // backgroundColor: AppColor.whiteColor,
        title: Text(
          'eduDrive',
          style: FontAssets.largeText.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 28
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_authMode == AuthMode.Signup)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReuseableTitleText(title: "Driver Name",),
                              CustomTextField(
                                hint: 'name',
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Field is empty';
                                  }
                                },
                                onSaved: (value) {
                                  _authData['name'] = value!;
                                },
                              ),
                            ],
                          ),
                        if (_authMode == AuthMode.Login)
                          SizedBox(height: 50,),
                          Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReuseableTitleText(title: "Email",),
                            CustomTextField(
                              hint: 'user@gmail.com',
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Field is empty';
                                }
                                if (!value.contains('@')) {
                                  return 'Invalid email address';
                                }
                              },
                              onSaved: (value) {
                                _authData['email'] = value!;
                              },
                            ),
                          ],
                        ),
                        if (_authMode == AuthMode.Signup)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReuseableTitleText(title: "Mobile Number",),
                              IntlPhoneField(
                                cursorColor: AppColor.blackColor,
                                dropdownTextStyle: FontAssets.mediumText,
                                initialCountryCode: "PK",
                                style: FontAssets.mediumText,
                                pickerDialogStyle: PickerDialogStyle(

                                  searchFieldInputDecoration: InputDecoration(
                                    fillColor: AppColor.whiteColor,
                                    hintStyle:FontAssets.mediumText.copyWith(color: Colors.grey),
                                    hintText: "Search Country",
                                    filled: true,

                                  ),
                                  countryNameStyle:FontAssets.mediumText.copyWith(color: AppColor.whiteColor)
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  counterStyle: TextStyle(
                                    color: AppColor.whiteColor
                                  ),
                                  fillColor: AppColor.whiteColor,
                                  contentPadding: EdgeInsets.only(left: 20),
                                  hintText: '3012345678',
                                  hintStyle: FontAssets.mediumText.copyWith(
                                    color: AppColor.blackColor.withOpacity(0.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: AppColor.blackColor,
                                    ),
                                  ),
                                  enabled: true,
                                  enabledBorder:OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: AppColor.blackColor,
                                    ),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                    width: 2,
                                    color: AppColor.blackColor,
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
                                      color: AppColor.blackColor,
                                    ),
                                  ),
                                ),

                                onChanged: (phone) {
                                  print(phone.completeNumber);
                                  _authData['mobile'] = phone.completeNumber;
                                },

                                onCountryChanged: (country) {
                                  print('Country changed to: ' + country.name);
                                },
                              ),
                            ],
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReuseableTitleText(title: "Password",),
                            CustomTextField(
                              hint: '*******',
                              obscure: _obscure,
                              textInputAction: _authMode == AuthMode.Signup
                                  ? TextInputAction.next
                                  : TextInputAction.done,
                              controller: _passwordController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Field is empty';
                                }
                                if (value.length < 5) {
                                  return 'Password is too short';
                                }
                              },
                              onSaved: (value) {
                                _authData['password'] = value!;
                              },
                              onFieldSubmitted: _authMode == AuthMode.Signup
                                  ? (_) {
                                      FocusScope.of(context).requestFocus(_focusNode);
                                    }
                                  : null,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscure = !_obscure;
                                  });
                                },
                                icon: Icon(
                                  _obscure ? Icons.visibility : Icons.visibility_off,
                                ),
                                color: AppColor.blackColor,
                              ),
                            ),
                          ],
                        ),
                        if (_authMode == AuthMode.Signup)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReuseableTitleText(title: "Confirm Password",),
                              CustomTextField(
                                hint: '*******',
                                obscure: _obscureConfirm,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirm = !_obscureConfirm;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  color: AppColor.blackColor,
                                ),
                                textInputAction: TextInputAction.done,
                                focusNode: _focusNode,
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  if (value!.isEmpty) {
                                    return 'Field is empty';
                                  }
                                },
                              ),
                            ],
                          ),
                        SizedBox(height: 36),
                        if (_isLoading)
                          Center(child: CircularProgressIndicator())
                        else
                          CustomButton(
                            label: _authMode == AuthMode.Login
                                ? 'Sign In'
                                : 'Sign Up',
                            onTap: (){
                              _submit(context);
                            },
                          ),
                        SizedBox(height: 16),
                        TapToActionText(
                          label:
                              '${_authMode == AuthMode.Login ? 'Don\'t' : 'Already'} have an account? ',
                          tapLabel:
                              _authMode == AuthMode.Login ? 'Sign Up' : 'Sign In',
                          onTap: _switchAuthMode,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


