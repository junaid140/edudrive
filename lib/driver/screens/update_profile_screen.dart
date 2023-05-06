import 'package:edudrive/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../helpers/http_exception.dart';
import '../providers/auth.dart';
import '../providers/driver_provider.dart';
import '../res/app_color/app_color.dart';
import '../res/font_assets/font_assets.dart';
import '../widgets/reuseable_title_text.dart';
import '../widgets/tap_to_action.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'car_info_screen.dart';


// enum AuthMode { Signup, Login }


class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  static const routeName = '/update-profile-screen';

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  final _focusNode = FocusNode();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
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

  update(){
    final userData = Provider.of<DriverProvider>(context, listen: false);
   setState((){
       name.text = userData.name;
       email.text = userData.email;
   phoneNumber.text = userData.mobile;
   });
  }

  Future<void> _submit(context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final userData = Provider.of<DriverProvider>(context, listen: false);

      if(name.text==userData.name && phoneNumber.text ==userData.mobile){
        return;
      }
      else{
        await FirestoreServices().updateDriver(FirebaseAuth.instance.currentUser!.uid, {"name":name.text,"mobile":phoneNumber.text});
        await Provider.of<DriverProvider>(context, listen: false).fetchDriverDetails();
      }


    }  catch (error) {
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

  @override
  void initState() {
    // TODO: implement initState
    update();
    super.initState();
  }

  @override
  void dispose() {
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

        leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.white,),onPressed: (){
          Navigator.pop(context);
        },),
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
                        Center(
                          child: CircleAvatar(backgroundImage: AssetImage('assets/images/user_icon.png',),
                          radius: 60,),
                        ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReuseableTitleText(title: "Driver Name",),
                              CustomTextField(
                                hint: 'name',
                                controller: name,
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
                          SizedBox(height: 20,),
                          Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReuseableTitleText(title: "Email",),
                            CustomTextField(
                              controller: email,
                              hint: 'user@gmail.com',
                              enable: false,
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
                        SizedBox(height: 20,),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReuseableTitleText(title: "Mobile Number",),
                            CustomTextField(
                              hint: 'Mobile Number',
                              controller: phoneNumber,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Field is empty';
                                }

                              },
                              onSaved: (value) {
                                _authData['email'] = value!;
                              },
                            ),
                          ],
                        ),


                        SizedBox(height: 36),
                        if (_isLoading)
                          Center(child: CircularProgressIndicator())
                        else
                          CustomButton(
                            label: 'Update Profile',
                            onTap: (){
                              _submit(context);
                            },
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


