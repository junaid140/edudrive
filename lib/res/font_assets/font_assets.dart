import 'package:edudrive/res/app_color/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontAssets{
  static TextStyle base=GoogleFonts.inter();


  static TextStyle smallText=base.copyWith(
      color: AppColor.whiteColor,
    fontSize: 13,
  );
  static TextStyle mediumText=base.copyWith(
      color: AppColor.whiteColor,
    fontSize: 16,
      );
  static TextStyle largeText=base.copyWith(
      color: AppColor.whiteColor,
    fontSize: 20,
    fontWeight: FontWeight.w700
      );
  static TextStyle appbarText=base.copyWith(
      color: AppColor.whiteColor,
    fontSize: 24,
    fontWeight: FontWeight.w700
      );


}