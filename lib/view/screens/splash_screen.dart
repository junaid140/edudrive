import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edudrive/driver/screens/account_type_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../driver/res/app_color/app_color.dart';
import '../../driver/res/font_assets/font_assets.dart';
import '../../driver/screens/navigation_bar.dart';
import '../../view/screens/dashboard_screen.dart';

import 'account_type_screen.dart';
import 'auth_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  static const routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 3),(){
      if(FirebaseAuth.instance.currentUser!=null){
        FirebaseFirestore.instance.collection("parent").doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
          if(value.exists){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DashboardScreen()));
          }else{
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BottomBar()));
          }
        });
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AccountTypeScreen()));
      }
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1577ff),
      body: Center(
        child: Image.asset("assets/logo/edudrive.png",width: MediaQuery.of(context).size.width*0.7,)
      ),
    );
  }
}
