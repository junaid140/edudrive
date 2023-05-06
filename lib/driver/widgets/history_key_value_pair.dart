
import 'package:flutter/material.dart';

import '../res/app_color/app_color.dart';
import '../res/font_assets/font_assets.dart';

class HistoryKeyValuePair extends StatelessWidget {
  HistoryKeyValuePair({Key? key,required this.title,required this.value}) : super(key: key);
  String title,value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(title,
              style: FontAssets.mediumText.copyWith(color: AppColor.whiteColor),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
              textAlign: TextAlign.left,
              style: FontAssets.smallText.copyWith(color: AppColor.whiteColor,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
