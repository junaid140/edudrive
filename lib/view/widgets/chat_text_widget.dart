import 'package:flutter/material.dart';

import '../../res/app_color/app_color.dart';

class ChatTextWidget extends StatelessWidget {
  ChatTextWidget({Key? key,
  required this.text,
  required this.user
  }) : super(key: key);
  String text;
  bool user;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: user?Alignment.centerRight:Alignment.centerLeft,
      child: Container(

        // width: MediaQuery.of(context).size.width*0.7,
        padding: EdgeInsets.fromLTRB(15,6,15,6),
        margin: EdgeInsets.only(bottom: 15,left: user?40:0,right: user?0:40),

        decoration: BoxDecoration(
            border: Border.all(
                color: AppColor.primaryButtonColor,
                width: 1
            ),
            borderRadius: BorderRadius.circular(10),
            color: AppColor.whiteColor,
            boxShadow: [
              BoxShadow(
                color: Color(0xff6F8CB0).withOpacity(0.41),
                offset: Offset(4,4),
                blurRadius: 20,
              )
            ]
        ),
        child: Text(text,
          textAlign: TextAlign.left,),
      ),
    );
  }
}
