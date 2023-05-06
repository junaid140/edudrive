import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:flutter/material.dart';

import '../../models/predicted_places.dart';

class PredictedTile extends StatelessWidget {
  const PredictedTile(this.predictedPlace, {Key? key, this.onTap})
      : super(key: key);

  final PredictedPlaces predictedPlace;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(predictedPlace.placeId),
      minLeadingWidth: 0,
      tileColor:AppColor.primaryButtonColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onTap: onTap,
      leading: Icon(
        Icons.location_on,
        color: AppColor.whiteColor,
        size: 40,
      ),
      title: Text(
        predictedPlace.mainText ?? '',
        style: FontAssets.smallText.copyWith(
          color: AppColor.whiteColor,
          fontWeight: FontWeight.bold,
        )
      ),
      subtitle: Text(
        predictedPlace.secondaryText ?? '',
        overflow: TextOverflow.ellipsis,
        style: FontAssets.smallText.copyWith(
          color: AppColor.whiteColor,
          fontWeight: FontWeight.w400,
        )
      ),
    );
  }
}
