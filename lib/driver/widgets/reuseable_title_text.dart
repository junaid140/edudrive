import 'package:flutter/material.dart';
import '../res/font_assets/font_assets.dart';

class ReuseableTitleText extends StatelessWidget {
  ReuseableTitleText({Key? key,
    required this.title}) : super(key: key);
  final title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(title,
        style: FontAssets.mediumText.copyWith(fontWeight: FontWeight.w400, color: Colors.white),),
    );
  }
}
