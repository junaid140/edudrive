import 'package:edudrive/driver/utils/utils.dart';
import 'package:edudrive/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../res/font_assets/font_assets.dart';
import '../../services/firestore_services.dart';
import '../widgets/tap_to_action.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'auth_screen.dart';


// enum AuthMode { Signup, Login }


class ComplainScreen extends StatefulWidget {
  const ComplainScreen({Key? key}) : super(key: key);

  static const routeName = '/complain_screen';

  @override
  _ComplainScreenState createState() => _ComplainScreenState();
}

class _ComplainScreenState extends State<ComplainScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController title = TextEditingController();
  TextEditingController about = TextEditingController();
  final _focusNode = FocusNode();

  bool _isLoading = false;

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
    setState(() {
      _isLoading = true;
    });
    try {
      final userData = Provider.of<UserProvider>(context, listen: false);


        await FirestoreServices().addComplain(FirebaseAuth.instance.currentUser!.uid,
            {"title":title.text,"about":about.text,"uid":FirebaseAuth.instance.currentUser!.uid,"created_at":DateTime.now()}).then((value){
              Utils().toastMessage("Complain Submitted");
              title.text = "";
              about.text = "";
        });



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
          'Complain',
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

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReuseableTitleText(title: "Subject",),
                            CustomTextField(
                              hint: 'Complain Subject',
                              controller: title,


                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Field is empty';
                                }
                              },

                            ),
                          ],
                        ),
                        SizedBox(height: 20,),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReuseableTitleText(title: "Complain Description",),
                            CustomTextField(
                              hint: 'Write some thing here',
                              controller: about,
                              textInputAction: TextInputAction.newline,
                              min: 10,max: 15,

                              validator: (value) {
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
                            label: 'Submit',
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


