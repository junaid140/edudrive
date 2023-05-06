import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class TapToActionText extends StatelessWidget {
  const TapToActionText({
    Key? key,
    this.label,
    this.tapLabel,
    this.onTap,
    this.padding = const EdgeInsets.only(top: 20),
  }) : super(key: key);

  final String? label;
  final String? tapLabel;
  final void Function()? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      width: double.infinity,
      child: Center(
        child: RichText(
          text: TextSpan(
            text: label,
            style: FontAssets.mediumText,
            children: <TextSpan>[
              TextSpan(
                text: tapLabel,
                style: FontAssets.mediumText.copyWith(fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()..onTap = onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
