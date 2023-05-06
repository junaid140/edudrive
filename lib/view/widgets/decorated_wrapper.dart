import 'package:edudrive/res/app_color/app_color.dart';
import 'package:flutter/material.dart';

class DecoratedWrapper extends StatelessWidget {
  const DecoratedWrapper({
    Key? key,
    this.child,
  }) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color:AppColor.blackColor,
            blurRadius: 3,
            // spreadRadius: 0.5,
            offset: Offset(0.7, 0.7),
          ),
        ],
      ),
      child: child,
    );
  }
}
