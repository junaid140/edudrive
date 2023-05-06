import 'package:edudrive/driver/res/app_color/app_color.dart';
import 'package:edudrive/driver/res/font_assets/font_assets.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  final String label;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(

          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColor.primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: AppColor.whiteColor.withOpacity(0.72),
                offset: Offset(3,3),

              ),
              BoxShadow(
                blurRadius: 40,
                color: AppColor.whiteColor.withOpacity(0.2),
                offset: Offset(0,20),

              ),

            ]
          ),
            child: Center(
                child: Text(label,
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
