import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'floating_appbar_wrapper.dart';

class FloatingAppBarWrapperWithTextField extends StatelessWidget {
  const FloatingAppBarWrapperWithTextField({
    Key? key,
    required this.height,
    required this.width,
    required this.leadingIcon,
    required this.hintLabel,
    this.controller,
    this.onSubmitted,
  }) : super(key: key);

  final double height;
  final double width;
  final SvgPicture leadingIcon;
  final String hintLabel;
  final TextEditingController? controller;
  final void Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width*0.9,
      child: TextFormField(
        controller: controller,
        textInputAction: TextInputAction.send,
        onFieldSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelStyle: FontAssets.smallText,
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: AppColor.whiteColor,
          prefix:Padding(
            padding: const EdgeInsets.only(left: 20,right: 10),
            child: leadingIcon,
          ) ,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColor.primaryButtonColor,width: 2),
          ),
          errorBorder :OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.red,width: 2),
          ),
          focusedErrorBorder : OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColor.primaryButtonColor,width: 2),

          ),
          focusedBorder : OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColor.primaryButtonColor,width: 2),

          ),
          hintText: hintLabel,
          hintStyle: FontAssets.smallText.copyWith(color: AppColor.blackColor),
          border: InputBorder.none,
          prefixIconConstraints: BoxConstraints(
            maxHeight: 10,
            minHeight: 10,
            minWidth: 26,
            maxWidth: 34,
          ),
        ),
        style: FontAssets.smallText.copyWith(color: AppColor.blackColor),
      ),
    );
  }
}
