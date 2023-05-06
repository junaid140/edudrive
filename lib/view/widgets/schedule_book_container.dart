
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../res/app_color/app_color.dart';
import '../../res/font_assets/font_assets.dart';
import '../screens/history.dart';

class ScheduleBookContainer extends StatelessWidget {
  ScheduleBookContainer({Key? key,
    required this.onEdit,
    required this.onTap,
    required this.onDelete,
    required this.challanId,
     this.status = 0,
     this.driverName="",
     this.driverNumber="",
    required this.pickupLocation,
    required this.amount,
    required this.dropOffLocation,
    required this.totalDistance,
    required this.startDate,
    required this.endDate,
    required this.pickUpTime,
    required this.dropOffTime,
    required this.availabeSeats,
    this.isDelete=true,
    this.isDriverDetail=true,
    this.isStatus=false,
    this.isEdit=true,
  }) : super(key: key);
  String challanId,driverName,driverNumber,pickupLocation,dropOffLocation,totalDistance,startDate,endDate,pickUpTime,dropOffTime, amount;
  int availabeSeats, status;
  VoidCallback onEdit,onDelete, onTap;
  bool isEdit,isDelete,isDriverDetail, isStatus;



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
          color: AppColor.primaryButtonColor
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

                isEdit?IconButton(onPressed: onEdit,
                  icon: SvgPicture.asset("assets/icon/edit.svg"),
                ):SizedBox.shrink(),

                isStatus? Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: status==0?Colors.orange:status==1?Colors.blue.shade400:status==2?Colors.green:Colors.red
                    ),
                    margin: EdgeInsets.only(top: 10,right: 16),
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                    child: Text("${status==0?"Pending":status==1?"On Payment":status==2?"Active":"Decline"}",style: FontAssets.smallText.copyWith(color: AppColor.whiteColor),)
                  // 0-> pending, 1-> on Payment, 2-> Active, 3-> Decline
                ):SizedBox.shrink()

              ],
            ),
            SizedBox(height: 10,),
            isDriverDetail?  HistoryKeyValuePair(title: 'Van Driver Name',value: driverName):SizedBox.shrink(),
            isDriverDetail? HistoryKeyValuePair(title: 'Driver Number',value: driverNumber):SizedBox.shrink(),
            HistoryKeyValuePair(title: 'Pickup Location',value: pickupLocation),
            HistoryKeyValuePair(title: 'Drop Off Location',value: dropOffLocation),
            HistoryKeyValuePair(title: 'Total Distance',value: totalDistance),
            HistoryKeyValuePair(title: 'Start Date',value: startDate),
            HistoryKeyValuePair(title: 'End Date',value: endDate),
            HistoryKeyValuePair(title: 'Pickup Time',value: pickUpTime),
            HistoryKeyValuePair(title: 'Drop Off Time',value: dropOffTime),
            isDriverDetail? HistoryKeyValuePair(title: 'Available Seats',value: availabeSeats.toString()):HistoryKeyValuePair(title: 'Requested Seats',value: availabeSeats.toString()),
            isDriverDetail?SizedBox.shrink():   HistoryKeyValuePair(title: 'Amount',value: "\$ $amount"),

          ],
        ),
      ),
    );
  }
}
