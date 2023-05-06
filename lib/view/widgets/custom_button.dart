import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    Key? key,
    required this.label,
    required this.onTap,
    this.loading=false,
    this.color,
  }) : super(key: key);

  final String label;
  final void Function()? onTap;
  bool? loading;
  Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(

          // padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: color??AppColor.primaryButtonColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: AppColor.whiteColor.withOpacity(0.72),
                  offset: Offset(3,3),

                ),
                BoxShadow(
                  blurRadius: 15,
                  color: AppColor.whiteColor.withOpacity(0.2),
                  offset: Offset(0,5),

                ),

              ]
          ),
          child: Center(
            child: loading!?CircularProgressIndicator(color: AppColor.whiteColor,):Text(label,
              style: FontAssets.largeText.copyWith(
                  color: AppColor.whiteColor,
                  fontSize: 18
              ),
            ),
          ),),

      ),
    );
  }
}