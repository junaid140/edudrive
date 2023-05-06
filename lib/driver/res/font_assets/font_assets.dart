import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_color/app_color.dart';

class FontAssets{
  static TextStyle base=GoogleFonts.inter();


  static TextStyle smallText=base.copyWith(
      color: AppColor.primaryTextColor,
    fontSize: 12,
  );
  static TextStyle mediumText=base.copyWith(
      color: AppColor.primaryTextColor,
    fontSize: 16,
      );
  static TextStyle largeText=base.copyWith(
      color: AppColor.primaryTextColor,
    fontSize: 20,
    fontWeight: FontWeight.w700
      );


}