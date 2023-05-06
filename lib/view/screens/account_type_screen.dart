import 'package:edudrive/driver/screens/auth_screen.dart';
import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:edudrive/view/screens/auth_screen.dart' as parentAuth;
import 'package:edudrive/view/screens/sign_up_with_phone.dart';
import 'package:flutter/material.dart';

class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({Key? key}) : super(key: key);
  static const routeName = '/account-type';

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColor.blackColor,
        title: Text(
          'eduDrive',
          style: FontAssets.largeText.copyWith(
              color: AppColor.whiteColor,
              fontSize: 28
          ),
        ),
      ),
      backgroundColor: AppColor.blackColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AccountTypeButton(
                title: "Login as Driver",
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AuthScreen()));
                }),
            SizedBox(height: MediaQuery.of(context).size.height*.05,),
            AccountTypeButton(
                title: "Login as Parent",
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpWithPhone()));
                }),
          ],
        ),
      ),
    );
  }
}

class AccountTypeButton extends StatelessWidget {
  AccountTypeButton({
    Key? key,
    required this.title,
    required this.onTap
  }) : super(key: key);

  VoidCallback onTap;
  String title;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: FontAssets.base.copyWith(
                color: AppColor.blackColor,
                fontWeight:FontWeight.w400,
                fontSize: 16,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward,color: AppColor.blackColor,size: 16,),
          ],
        ),
      ),
    );
  }
}

