
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../driver/res/app_color/app_color.dart';
import '../../res/font_assets/font_assets.dart';
import 'history_key_value_pair.dart';

class InstantBookContainer extends StatelessWidget {
  InstantBookContainer({Key? key,

    required this.challanId,
    required this.status,
    required this.pickupLocation,
    required this.dropOffLocation,
     this.fare = "",
  }) : super(key: key);
  String challanId,fare,status,pickupLocation,dropOffLocation;



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 17,left: 20,right: 20),
      padding: EdgeInsets.fromLTRB(20,20,12,20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              offset: Offset(0,4),
              blurRadius: 4,
              color: AppColor.blackColor.withOpacity(0.25),
            ),
          ],
          color: AppColor.primaryColor
      ),
      child: GestureDetector(
        // onTap: onTap,
        child: Column(
          children: [
            Row(
              children: [
                Text("ID#: $challanId",style: FontAssets.smallText.copyWith(
                  color: AppColor.whiteColor,
                  fontWeight: FontWeight.w400,
                ),),
                Spacer(),
                Container(decoration: BoxDecoration(color: Colors.blue.shade300,
                    borderRadius: BorderRadius.circular(16)),child:
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("$status",style: FontAssets.smallText.copyWith(color: Colors.white)),
                ),)
              ],
            ),
            SizedBox(height: 10,),
            HistoryKeyValuePair(title: 'Pickup Location',value: pickupLocation),
            HistoryKeyValuePair(title: 'Drop Off Location',value: dropOffLocation),
            HistoryKeyValuePair(title: 'Fare Amount',value: double.parse(fare).toStringAsFixed(2)),
            HistoryKeyValuePair(title: 'payment_method',value: "PayPal"),



          ],
        ),
      ),
    );
  }
}
