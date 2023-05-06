
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../res/app_color/app_color.dart';

class ScheduleBookShimmer extends StatelessWidget {
  final bool isEnabled;
  ScheduleBookShimmer({required this.isEnabled,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 17,left: 20,right: 20),
      child: Shimmer(

          duration: Duration(seconds: 2),
          enabled: isEnabled,
          child:
          Container(
            height: MediaQuery.of(context).size.height*0.4,
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
              onTap: (){

              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                          height: 10, width: 100, color: Colors.grey[300]),
                      Spacer(),
                Container(
                    height: 10, width: 40, color: Colors.grey[300]),
                      Container(
                          height: 10, width: 40, color: Colors.grey[300]),

                    ],
                  ),
                  SizedBox(height: 10,),
                  Container(
                    margin: EdgeInsets.all(5),
                      height: 10, width: MediaQuery.of(context).size.width*0.6, color: Colors.grey[300]),
                  Container(
                    margin: EdgeInsets.all(5),
                      height: 10, width: MediaQuery.of(context).size.width*0.6, color: Colors.grey[300]),
                  Container(
                    margin: EdgeInsets.all(5),
                      height: 10, width: MediaQuery.of(context).size.width*0.6, color: Colors.grey[300]),
                  Container(
                    margin: EdgeInsets.all(5),
                      height: 10, width: MediaQuery.of(context).size.width*0.6, color: Colors.grey[300]),
                  Container(
                    margin: EdgeInsets.all(5),
                      height: 10, width: MediaQuery.of(context).size.width*0.6, color: Colors.grey[300]),
                  Container(
                    margin: EdgeInsets.all(5),
                      height: 10, width: MediaQuery.of(context).size.width*0.6, color: Colors.grey[300]),
                  Container(
                    margin: EdgeInsets.all(5),
                      height: 10, width: MediaQuery.of(context).size.width*0.6, color: Colors.grey[300]),
                  Container(
                    margin: EdgeInsets.all(5),
                      height: 10, width: MediaQuery.of(context).size.width*0.6, color: Colors.grey[300]),


                ],
              ),
            ),
          )

      ),
    );
  }
}
