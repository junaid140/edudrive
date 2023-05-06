import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:edudrive/view/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../helpers/http_exception.dart';
import '../../providers/auth.dart';
import '../../res/app_color/app_color.dart';
import '../widgets/tap_to_action.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

enum AuthMode { Signup, Login }

class AuthScreen1 extends StatefulWidget {
  const AuthScreen1({Key? key}) : super(key: key);

  static const routeName = '/auth1';

  @override
  _AuthScreen1State createState() => _AuthScreen1State();
}

class _AuthScreen1State extends State<AuthScreen1> {
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
    }

    try {
      if (_authMode == AuthMode.Login) {
        print("Email : ${(_authData['email'] as String).trim()}");
        print("Password : ${_authData['password'] as String}");
        await Provider.of<Auth>(context, listen: false).login(
          email: (_authData['email'] as String).trim(),
          password: _authData['password'] as String,
        ).then((value)  {
          setState(() {
            _isLoading=false;
          });
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DashboardScreen()));
        });
      }
      else {
        await Provider.of<Auth>(context, listen: false).signupWithEmail(
          email: (_authData['email'] as String).trim(),
          password: _authData['password'] as String,
          name: (_authData['name'] as String).trim(),
          mobile: (_authData['mobile'] as String).trim(),
        ).then((value){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>DashboardScreen()));
        });
      }
    } on FirebaseAuthException catch (e) {
      print("--Error kia h--");
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
      _showErrorDialog(errorMessage);
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
      _showErrorDialog(errorMessage);
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
                    if (_authMode == AuthMode.Signup)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReuseableTitleText(title: "Name"),
                          CustomTextField(
                            hint: 'name',
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
                                _authData['name'] = value;
                                return null;
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReuseableTitleText(title: "Email"),
                          CustomTextField(
                            hint:'user@gmail.com' ,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Field is empty';
                              }
                              else if(!value.contains('@')) {
                                return 'Invalid email address';
                              }
                              else{
                                _authData['email'] = value;
                                return null;
                              }
                            },
                            onSaved: (value) {
                              _authData['email'] = value!;
                            },
                          ),
                        ],
                      ),


                    if (_authMode == AuthMode.Signup)
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReuseableTitleText(title: "Mobile"),
                          IntlPhoneField(
                            cursorColor: AppColor.blackColor,
                            dropdownTextStyle: FontAssets.mediumText,
                            initialCountryCode: "PK",
                            style: FontAssets.mediumText,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColor.whiteColor,
                              counterStyle: FontAssets.smallText.copyWith(color: AppColor.whiteColor),
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
                    // if (_authMode == AuthMode.Signup)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReuseableTitleText(title: "Password"),
                        CustomTextField(
                          hint: '********',
                          obscure: _obscure,
                          keyboardType: TextInputType.text,
                          textInputAction: _authMode == AuthMode.Signup
                              ? TextInputAction.next
                              : TextInputAction.done,
                          controller: _passwordController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Field is empty';
                            }
                            else if(value.length < 5) {
                              return 'Password is too short';
                            }
                            else{
                              _authData['password'] = value!;
                              return null;
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
                            color: AppColor.primaryIconColor,
                          ),
                        ),
                      ],
                    ),
                    if (_authMode == AuthMode.Signup)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          ReuseableTitleText(title: "Confirm Password"),
                          CustomTextField(
                            hint: '********',
                            obscure: _obscureConfirm,
                            keyboardType: TextInputType.text,
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
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirm = !_obscureConfirm;
                                });
                              },
                              icon: Icon(
                                _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                              ),
                              color: AppColor.primaryIconColor,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 36),
                    if (_isLoading)
                      CircularProgressIndicator(

                      )
                    else
                      CustomButton(
                        loading:_isLoading,
                        label: _authMode == AuthMode.Login
                            ? 'Sign In'
                            : 'Create Account',
                        onTap: _submit,
                      ),
                    SizedBox(height: 16),
                    TapToActionText(
                      label:
                          '${_authMode == AuthMode.Login ? 'Don\'t' : 'Already'} have an account? ',
                      tapLabel:
                          _authMode == AuthMode.Login ? 'Sign up' : 'Sign In',
                      onTap: _switchAuthMode,
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

class ReuseableTitleText extends StatelessWidget {
  ReuseableTitleText({Key? key,
  required this.title}) : super(key: key);
  final title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(title,
        style: FontAssets.mediumText.copyWith(fontWeight: FontWeight.w400,
        color: AppColor.whiteColor),),
    );
  }
}
