import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edudrive/main.dart';
import 'package:edudrive/providers/maps_provider.dart';
import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:edudrive/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../driver/models/instant_ride_request.dart';
import '../../driver/screens/newRideScreen.dart';
import '../main.dart';
import '../services/fcmServices/firebase_messaging.dart';
import '../services/firestore_services.dart';

// class NewRequestDailog extends StatelessWidget {
//   String requestId;
//   InstantRideRequest instantRideRequest;
//   Map<String,dynamic> parentData;
//    NewRequestDailog({Key? key,required this.requestId, required this.instantRideRequest, required this.parentData}) : super(key: key);
//
//   bool isLoading= false;
//
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   @override
//   Widget build(BuildContext context) {
//     return
//   }
//
//    checkAvailableForRide(context)async{
//
//   }
// }

NewRequestDailog(
    {required requestId, required instantRideRequest, required parentData, required context}){
  return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  "New Request",
                  maxLines: 1,
                  style: FontAssets.mediumText.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                ListTile(

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // tileColor: Theme.of(context).primaryColorDark.withOpacity(0.6),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  leading: parentData["profile"]==null||parentData["profile"]==""?Image.asset('assets/images/user_icon.png'):Image.network(parentData["profile"]),
                  title: Text(
                    "${parentData["name"]}",
                    style: FontAssets.largeText.copyWith(color: Colors.black),
                  ),
                  subtitle: Text(
                    "${parentData["mobile"]}",
                    style: FontAssets.smallText.copyWith(color: Colors.black),
                  ),

                ),
                ListTile(title: Text("Pick Up",style: FontAssets.largeText.copyWith(color: Colors.black),),
                  subtitle: Text("${instantRideRequest.pickupAddress}",style: FontAssets.smallText.copyWith(color: Colors.black),),),
                ListTile(title: Text("Drop Off",style: FontAssets.largeText,),
                  subtitle: Text("${instantRideRequest.dropoffAddress}",style: FontAssets.smallText.copyWith(color: Colors.black),),),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                        onPressed: ()async{

                          // await FirebaseFirestore.instance.collection("rideRequest").doc(requestId).update(
                          //     {"status": 3,
                          //     }).then((value) {
                          //   Navigator.pop(context);
                          //   fairAmount.text="";
                          // });
                          // var parentData=  await FirestoreServices().getParent(data["parentId"]);
                          //
                          // await PushNotificationServices.sendNotification(title: "Schedule Booking",body: "New Schedule Booking Request received",type: 0,request_id: data["id"],token: parentData["fcmToken"]);
                          //
                          // await FirestoreServices().addNotification(type: 0,text: "Decline a request",uid: FirebaseAuth.instance.currentUser!.uid);
                          // await FirestoreServices().addNotification(type: 0,text: "Decline your request",uid: data["parentId"]);


                        }, child: Text("Decline")),
                    ElevatedButton(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                        onPressed: ()async{
                          // if(!isLoading) {
                          //   setState(() {
                          //     isLoading = true;
                          //   });
                          //   await FirebaseFirestore.instance
                          //       .collection("rideRequest")
                          //       .doc(widget.requestId)
                          //       .update({
                          //     "request_status": "accepted",
                          //     "driver_id": FirebaseAuth
                          //         .instance.currentUser!.uid,
                          //   }).then((value) async {
                          //     var parentData =
                          //     await FirestoreServices()
                          //         .getParent(widget.instantRideRequest.parentId);
                          //     await FirestoreServices()
                          //         .updateDriver(
                          //         FirebaseAuth.instance
                          //             .currentUser!.uid,
                          //         {
                          //           "instantBooking": "accepted",
                          //           "instantBookingId":
                          //           widget.requestId
                          //         });
                          //
                          //     await PushNotificationServices
                          //         .sendNotification(
                          //         title: "Schedule Booking",
                          //         body:
                          //         "New Schedule Booking Request received",
                          //         type: 0,
                          //         request_id: widget.requestId,
                          //         token:
                          //         parentData["fcmToken"]);
                          //
                          //     await FirestoreServices()
                          //         .addNotification(
                          //         type: 0,
                          //         text: "Accept a request",
                          //         uid: FirebaseAuth.instance
                          //             .currentUser!.uid);
                          //     await FirestoreServices().addNotification(
                          //         type: 0,
                          //         text:
                          //         "Your request Accept, now pay payment to active",
                          //         uid: widget.instantRideRequest.parentId);
                          //
                          //     Navigator.pop(context);
                          //   });
                          //   setState(() {
                          //     isLoading = false;
                          //   });
                          // }
                          // else{
                          //
                          // }
                          // await checkAvailableForRide(context);
                          await driverRef.get().then((DocumentSnapshot documentSnapshot) async{
                            print("------==");


                            String rideId = "";
                            if(documentSnapshot.exists){
                              print("--1");
                              rideId = documentSnapshot["instantBooking"];
                              print(instantRideRequest.id);
                              print(documentSnapshot["instantBooking"] ==instantRideRequest.id);
                            }
                            else{
                              Utils().toastMessage("Ride Not Exist");
                              Navigator.pop(context);
                            }
                            if(documentSnapshot["instantBooking"] ==instantRideRequest.id){
                              print("---2");
                              driverRef.update({"instantBooking":"accepted"}).then((value)async{

                                Navigator.of(context).pushReplacement( MaterialPageRoute(builder: (context)=>NewRideScreen(rideDetails:instantRideRequest)));
                              });

                            }
                            else if(rideId=="cancelled"){
                              Navigator.pop(context);
                              Utils().toastMessage("Ride Request Cancelled");

                            }
                          });
                        }, child:Text("Accept")),
                  ],
                ),
              ],
            ) ,
          ),
        ),
      )
  );
}
