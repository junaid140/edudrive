import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField({
    Key? key,
    required this.hint,
    this.keyboardType,
    this.controller,
    this.enable=true,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.validator,
    this.onSaved,
    this.focusNode,
    this.obscure = false,
  })  : enabledBorder =   OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: AppColor.blackColor,width: 2),
  ),
        errorBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.red,width: 2),
        ),
        focusedErrorBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColor.blackColor,width: 2),

        ),
        focusedBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColor.blackColor,width: 2),

        ),super(key: key);

  CustomTextField.underline({
    Key? key,
    required this.hint,
    this.keyboardType,
    this.controller,
    this.textInputAction,
    this.prefixIcon,
    this.enable=true,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.validator,
    this.onSaved,
    this.focusNode,
    this.obscure = false,
  })  : enabledBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: AppColor.whiteColor,width: 2),
        ),
        errorBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.red,width: 2),
        ),
        focusedErrorBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColor.whiteColor,width: 2),

        ),
        focusedBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColor.whiteColor,width: 2),

        ),
        super(key: key);

  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enable;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final FocusNode? focusNode;
  final bool obscure;

  late final InputBorder enabledBorder;
  late final InputBorder errorBorder;
  late final InputBorder focusedErrorBorder;
  late final InputBorder focusedBorder;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: AppColor.primaryIconColor,
      keyboardType: keyboardType,
      controller: controller,
      obscureText: obscure,
      style: FontAssets.mediumText.copyWith(
          color: AppColor.blackColor
      ),
      obscuringCharacter: "*",
      textInputAction: textInputAction,
      decoration: InputDecoration(
          filled: true,
        enabled: enable,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.only(left: 20),
        hintText: hint,
        hintStyle: FontAssets.mediumText.copyWith(
          color: AppColor.blackColor.withOpacity(0.5),
        ),
        border: enabledBorder,
        enabledBorder: enabledBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: focusedErrorBorder,
        focusedBorder: focusedBorder,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      onSaved: onSaved,
      focusNode: focusNode,
    );
  }
}
