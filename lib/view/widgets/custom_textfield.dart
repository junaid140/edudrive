import 'package:edudrive/res/app_color/app_color.dart';
import 'package:flutter/material.dart';

import '../../res/font_assets/font_assets.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField({
    Key? key,
    required this.hint,
    this.enable=true,
    this.readOnly=false,
    this.keyboardType,
    this.controller,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.validator,
    this.onSaved,
    this.focusNode,
    this.max=1,
    this.min=1,
    this.obscure = false,
  })  : enabledBorder =   OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: AppColor.primaryButtonColor,width: 2),
  ),
        errorBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.red,width: 2),
        ),
        focusedErrorBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColor.primaryButtonColor,width: 2),

        ),
        focusedBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColor.primaryButtonColor,width: 2),

        ),super(key: key);

  CustomTextField.underline({
    Key? key,
    required this.hint,
    this.keyboardType,
    this.controller,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.validator,
    this.onSaved,
    this.max=1,
    this.min=1,
    this.focusNode,
    this.obscure = false, this.enable=true,this.readOnly=false,
  })  : enabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: AppColor.primaryButtonColor,width: 2),
  ),
        errorBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.red,width: 2),
        ),
        focusedErrorBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColor.primaryButtonColor,width: 2),

        ),
        focusedBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColor.primaryButtonColor,width: 2),

        ),
        super(key: key);

  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final bool enable;
  final bool readOnly;
  final Widget? suffixIcon;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final FocusNode? focusNode;
  final bool obscure;
  int max,min;

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
      maxLines: max,
      minLines: min,
      obscureText: obscure,
      style: FontAssets.mediumText.copyWith(
          color: AppColor.blackColor,

      ),

      enabled: enable,
      obscuringCharacter: "*",
      textInputAction: textInputAction,readOnly: readOnly,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 20),
        hintText: hint,
        hintStyle: FontAssets.mediumText.copyWith(
          color: AppColor.blackColor.withOpacity(0.5),
        ),

        filled: true,
        fillColor: AppColor.whiteColor,
        enabledBorder: enabledBorder,
        errorBorder: errorBorder,
        border: enabledBorder,
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
