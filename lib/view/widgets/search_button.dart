import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:flutter/material.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color:AppColor.primaryButtonColor,width: 2),
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(width: 10),
          Text(
            'Search Drop Off',
            style: FontAssets.smallText.copyWith(color: AppColor.blackColor)
          ),
        ],
      ),
    );
  }
}
