import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../repository/driver_repo.dart';
import '../../utils/formatDate.dart';
import 'dashboard_screen.dart';
import 'order_tracking_page.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // getAllBooking(){
  //   return FirebaseFirestore.instance.collection("requestsScheduleBooks")
  //       .where("parentId",isEqualTo: FirebaseAuth.instance.currentUser!.uid).where("status",isEqualTo: 2).snapshots();
  // }
  final requestReference = FirebaseFirestore.instance.collection("requestsScheduleBooks")
      .where("parentId",isEqualTo: FirebaseAuth.instance.currentUser!.uid);
  bool isLoading = false;
  List<Map<String, dynamic>> requestData = [];
  _getData() async {
    setState(() {
      isLoading = true;
    });
    requestReference
    // .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((doc) async{
      requestData.clear();
      for (var item in doc.docs) {
        var driverData =  await DriverRepo().fetchDriverDetails(item["driver_id"]);
        print(driverData);
        requestData.add({
          "request":item.data(),
          "driver":driverData,
        });
      }
      setState(() {
        isLoading = false;
      });
      if (mounted) setState(() {});
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    _getData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
      ),
      body: Consumer<UserProvider>(
          builder: (ctx, users, _){
            // print(users.user.id);
            return
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitleText(title: "Booking History"),
                        Container(height: MediaQuery.of(context).size.height*0.9,
                          child: ListView.builder(
                              itemCount: requestData.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (context,index) {
                                var request = requestData[index]["request"];
                                return GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderTrackingPage(data: request,)));
                                  },
                                  child: Container(
                                      width: MediaQuery.of(context).size.width*0.87,
                                      margin: EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: AppColor.userDetailsCardColor,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Stack(
                                        fit: StackFit.passthrough,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15.0,
                                              vertical: 15,
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "Driver Name",
                                                            style: FontAssets.smallText.copyWith(
                                                                fontWeight: FontWeight.w300,
                                                                color: AppColor.whiteColor,
                                                                fontSize: 13),
                                                          ),
                                                          Text(
                                                            "${requestData[index]["driver"]["name"]}",
                                                            style: FontAssets.largeText.copyWith(
                                                                fontWeight: FontWeight.w500,
                                                                color: AppColor.whiteColor,
                                                                fontSize: 20),
                                                          ),
                                                        ]),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    // CircleAvatar(
                                                    //   radius: 30,
                                                    //   child: Image.asset(
                                                    //     "assets/images/user_icon.png",
                                                    //     // height: 200,
                                                    //     // width: 100,
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                                Text(
                                                  "Pick & Drop Time",
                                                  style: FontAssets.smallText.copyWith(
                                                      fontWeight: FontWeight.w300,
                                                      color: AppColor.whiteColor),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.symmetric(vertical: 4),
                                                  padding: EdgeInsets.symmetric(vertical: 4,horizontal: 10),
                                                  decoration: BoxDecoration(
                                                      color: Color(0xff92FEC2),
                                                      borderRadius: BorderRadius.only(
                                                        bottomLeft: Radius.circular(5),
                                                        topLeft: Radius.circular(5),
                                                        topRight: Radius.circular(25),
                                                        bottomRight: Radius.circular(25),
                                                      )
                                                  ),
                                                  child: Text("${DateFormat("hh:mm ").format(request["startDate"].toDate())} - ${DateFormat("hh:mm ").format(request["endDate"].toDate())}",
                                                    style: FontAssets.largeText.copyWith(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColor.primaryButtonColor
                                                    ),),
                                                ),
                                                Text(
                                                  "Duration",
                                                  style: FontAssets.smallText.copyWith(
                                                      fontWeight: FontWeight.w300,
                                                      color: AppColor.whiteColor),
                                                ),
                                                SizedBox(height: 2,),
                                                Container(
                                                  margin: EdgeInsets.symmetric(vertical: 4),
                                                  padding: EdgeInsets.symmetric(vertical: 4,horizontal: 10),
                                                  decoration: BoxDecoration(
                                                      color: Color(0xffF3995C),
                                                      borderRadius: BorderRadius.only(
                                                        bottomLeft: Radius.circular(5),
                                                        topLeft: Radius.circular(5),
                                                        topRight: Radius.circular(25),
                                                        bottomRight: Radius.circular(25),


                                                      )
                                                  ),
                                                  child: Text("${getTimeAgoString(time: Timestamp.fromDate(request["startDate"].toDate()).toDate().toIso8601String(),toTime: request["endDate"].toDate())}",
                                                    style: FontAssets.largeText.copyWith(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w700,
                                                        color: AppColor.primaryButtonColor
                                                    ),),
                                                )
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            top: 20,
                                            right: 5,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 3),
                                              decoration: BoxDecoration(
                                                color: request["status"]==0?Colors.orange:request["status"]==1?Colors.blue.shade300:
                                                request["status"]==2?Colors.green:Colors.red,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Center(child: Text("${request["status"]==0?"Pending":
                                              request["status"]==1?"On Payment":request["status"]==2?"Active":"Decline"}",
                                                style: FontAssets.smallText.copyWith(
                                                    color: AppColor.whiteColor
                                                ),),),
                                            ),
                                          ),
                                          Positioned(
                                              right: 0,
                                              bottom: 5,
                                              child: Image.asset('assets/images/colored_van.png',height: 120,
                                                fit: BoxFit.cover,))
                                        ],
                                      )
                                  ),
                                );
                              }
                          ),
                        ),

                      ]
                  ),
                ),
              );
          }
      ),
    );
  }
}


class NewBookingType extends StatelessWidget {
  NewBookingType({Key? key,
    required this.title,
    required this.onTap}) : super(key: key);

  VoidCallback onTap;
  String title;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:AppColor.primaryButtonColor,
          boxShadow: [
            BoxShadow(
                color: AppColor.whiteColor,
                offset: Offset(3,3),
                blurRadius: 10
            ),
            BoxShadow(
              color: Color(0xff032B47).withOpacity(0.2),
              offset: Offset(0,20),
              blurRadius: 40,
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(vertical: 25,horizontal: 25),
        margin: EdgeInsets.only(bottom: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,style: FontAssets.largeText.copyWith(
                color: AppColor.whiteColor
            ),textAlign: TextAlign.left,),
            SvgPicture.asset("assets/icon/van.svg",),
            SvgPicture.asset("assets/icon/arrow.svg"),

          ],
        ),
      ),
    );
  }
}

class HistoryStatusContainer extends StatelessWidget {
  HistoryStatusContainer({Key? key,
  required this.challanId,
  required this.status,
  required this.driverName,
  required this.driverNumber,
    required this.pickupLocation,
    required this.dropOffLocation,
    required this.date,
    required this.time
  }) : super(key: key);
  String challanId,status,driverName,driverNumber,pickupLocation,dropOffLocation,date,time;


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 17),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              offset: Offset(0,4),
              blurRadius: 4,
              color: AppColor.blackColor.withOpacity(0.25),
            ),
          ],
          color: status=="Complete"?
          AppColor.userDetailsCardColor:
          Color(0xff063471)
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(challanId,style: FontAssets.smallText.copyWith(
                color: AppColor.whiteColor,
                fontWeight: FontWeight.w400,
              ),),
              Container(
                width: 90,
                padding: EdgeInsets.symmetric(vertical: 3,horizontal: 15),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: status=="Complete"?AppColor.statusColor:Color(0xffC30F0F),
                ),

                child: Center(
                  child: Text(status,
                    style: FontAssets.smallText.copyWith(fontWeight: FontWeight.w700,
                        color: AppColor.whiteColor),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          HistoryKeyValuePair(title: 'Van Driver Name',value: driverName),
          HistoryKeyValuePair(title: 'Driver Number',value: driverNumber),
          HistoryKeyValuePair(title: 'Pickup Location',value: pickupLocation),
          HistoryKeyValuePair(title: 'Drop Off Location',value: dropOffLocation),
          HistoryKeyValuePair(title: 'Date',value: date),
          HistoryKeyValuePair(title: 'Time',value: time),
        ],
      ),
    );
  }
}


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
