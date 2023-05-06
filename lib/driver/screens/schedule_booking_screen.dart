import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:edudrive/driver/screens/request_view_screen.dart';
import 'package:edudrive/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../res/app_color/app_color.dart';
import '../widgets/schedule_book_container.dart';
import 'create_schedule_book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleBookingScreen extends StatelessWidget {
  const ScheduleBookingScreen({Key? key}) : super(key: key);
  static const routeName = '/schedule-booking-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     onPressed: (){},
      //     icon: Icon(Icons.menu,color: Colors.white,),
      //   ),
      //   centerTitle: true,
      //   title: Text("Schedule Book",style: TextStyle(
      //       fontSize: 20,
      //       fontWeight: FontWeight.bold
      //   ),),
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: (){
                Navigator.pushNamed(context, CreateScheduleBookScreen.routeName);
              },
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.white.withOpacity(0.73), blurRadius: 8,offset: Offset(3,3))
                  ],
                  color: AppColor.primaryColor
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text("Create Schedule Book",
                          maxLines: 3,
                          style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 23
                      )),
                    ),
                    SizedBox(width: 10,),
                    Image.asset("assets/images/van_icon.png",height: 80,)
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Schedule Book',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            SizedBox(
              // height: MediaQuery.of(context).size.height*0.55,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection("scheduleBooks").where("uid",isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
                builder: (context,AsyncSnapshot<QuerySnapshot> snapshot) {
                  return snapshot.hasData? snapshot.data!.docs.length>0?
                  ListView.builder(
                      // primary: false,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context,index){
                        var data = snapshot.data!.docs[index];
                    return ScheduleBookContainer(
                        onTap: (){
                          print(snapshot.data!.docs[index]["id"]);
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestViewScreen(bookingId: snapshot.data!.docs[index]["id"])));
                        },
                        onEdit: (){
                        },
                        onDelete: (){


                            // set up the button
                            Widget okButton = TextButton(
                              child: Text("Yes"),
                              onPressed: () async{
                                await FirebaseFirestore.instance.collection("scheduleBooks").doc(data["id"]).delete();
                                Navigator.pop(context);
                                Utils().toastMessage("Schedule Book Deleted");

                              },
                            );Widget noButton = TextButton(
                              child: Text("No"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            );

                            // set up the AlertDialog
                            AlertDialog alert = AlertDialog(
                              title: Text("Delete"),
                              content: Text("Are You want to delete",style: TextStyle(color: Colors.white),),
                              actions: [
                                noButton, okButton,
                              ],
                            );

                            // show the dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              },
                            );

                        },
                        challanId: data["id"],
                        status: "Complete",
                        pickupLocation: data["pickUpAddress"]["address"],
                        dropOffLocation: data["dropAddress"]["address"],
                        totalDistance: '10.3km',
                        startDate:  DateFormat('dd-MM-yyyy').format(data['startDate'].toDate()).toString(),
                        endDate:  DateFormat('dd-MM-yyyy').format(data['endDate'].toDate()).toString(),
                        pickUpTime: (data['startTime']).toString(),
                        dropOffTime: data['endTime'].toString(),
                        availabeSeats: data['seats'],
                      bookedSeats: data["bookedSeats"],
                    );
                  })
                      :Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Text("No Data Found",style:
                  FontAssets.largeText.copyWith(color: AppColor.whiteColor, ),),
                      )
                      :Center(child: CircularProgressIndicator(),);
                }
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget CustomText(text,double fontSize,FontWeight fontWeight){
  return  Padding(
    padding: const EdgeInsets.only(top: 8.0,bottom: 8.0),
    child: Text("$text",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: AppColor.whiteColor
    ),),
  );
}
