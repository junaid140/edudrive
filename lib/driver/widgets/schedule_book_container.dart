
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../driver/res/app_color/app_color.dart';
import '../../res/font_assets/font_assets.dart';
import 'history_key_value_pair.dart';

class ScheduleBookContainer extends StatelessWidget {
  ScheduleBookContainer({Key? key,
    required this.onEdit,
    required this.onTap,
    required this.onDelete,
    required this.challanId,
    required this.status,

    required this.pickupLocation,
    required this.dropOffLocation,
    required this.totalDistance,
    required this.startDate,
    required this.endDate,
    required this.pickUpTime,
    required this.dropOffTime,
    required this.availabeSeats,
     this.bookedSeats = 0,
  }) : super(key: key);
  String challanId,status,pickupLocation,dropOffLocation,totalDistance,startDate,endDate,pickUpTime,dropOffTime;
  int availabeSeats, bookedSeats;
  VoidCallback onEdit,onDelete, onTap;


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
        onTap: onTap,
        child: Column(
          children: [
            Row(
              children: [
                Text(challanId,style: FontAssets.smallText.copyWith(
                  color: AppColor.whiteColor,
                  fontWeight: FontWeight.w400,
                ),),
                Spacer(),
                IconButton(onPressed: onDelete,
                  icon: Icon(Icons.delete,color: Colors.white,),
                ),
                IconButton(onPressed: onEdit,
                  icon: Icon(Icons.edit,color: Colors.white,),
                ),

              ],
            ),
            SizedBox(height: 10,),
            HistoryKeyValuePair(title: 'Pickup Location',value: pickupLocation),
            HistoryKeyValuePair(title: 'Drop Off Location',value: dropOffLocation),
            HistoryKeyValuePair(title: 'Start Date',value: startDate),
            HistoryKeyValuePair(title: 'End Date',value: endDate),
            HistoryKeyValuePair(title: 'Pickup Time',value: pickUpTime),
            HistoryKeyValuePair(title: 'Drop Off Time',value: dropOffTime),
            HistoryKeyValuePair(title: 'Total Seats',value: availabeSeats.toString()),
            HistoryKeyValuePair(title: 'Available Seats',value: (availabeSeats-bookedSeats).toString()),


          ],
        ),
      ),
    );
  }
}
