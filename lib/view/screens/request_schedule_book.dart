import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:edudrive/view/screens/edit_schedul_book.dart';
import 'package:edudrive/utils/utils.dart';
import 'package:edudrive/view/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../helpers/platform_keys.dart';
import '../../repository/driver_repo.dart';
import '../../services/fcmServices/firebase_messaging.dart';
import '../../services/firestore_services.dart';
import '../widgets/decorated_wrapper.dart';
import '../widgets/schedule_book_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RequestScheduleBook extends StatefulWidget {
  RequestScheduleBook({Key? key, this.data}) : super(key: key);
  final data;
  @override
  State<RequestScheduleBook> createState() => _RequestScheduleBookState();
}

class _RequestScheduleBookState extends State<RequestScheduleBook> {
  final user=FirebaseAuth.instance.currentUser;
  bool _isloading=false;
  @override
  Widget build(BuildContext context) {
    if(user==null) {
      print("No user Found");
    }
    // final data=widget.data;
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("requestsScheduleBooks")
          .where("bookingId",isEqualTo: widget.data["id"])
          .where("parentId",isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
      builder: (context,AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          var data={};
          if(snapshot.data!.docs.length > 0) {
                data = snapshot.data!.docs[0].data();
            }

            return  Scaffold(
            appBar: AppBar(
              title: Text("Request Schedule Book"),
            ),
            body: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              child: Column(
                // mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                 snapshot.data!.docs.length > 0 ? Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: ScheduleBookContainer(
                        onTap: () {
                         if(data["status"]==0){
                           Utils().toastMessage("Request Still Pending, Please Wait");
                         }
                         else if(data["status"]==1){
                           Utils().toastMessage("Request is on Payment");
                           showModalBottomSheet(context: context,
                               backgroundColor: AppColor.scaffoldBackgroundColor,
                               builder: (context){return DecoratedWrapper(
                             child: Padding(
                               padding: const EdgeInsets.symmetric(
                                 horizontal: 16,
                                 vertical: 18,
                               ),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   SizedBox(height: 10),
                                   Text(
                                       'Request for Ride',
                                       style: FontAssets.largeText.copyWith(
                                           fontSize: 22,
                                           color: AppColor.whiteColor
                                       )
                                   ),
                                   SizedBox(height: 16),
                                   Container(
                                     decoration: BoxDecoration(
                                       color: AppColor.whiteColor.withOpacity(0.3),
                                       borderRadius: BorderRadius.circular(20),
                                     ),
                                     child: ListTile(
                                       minLeadingWidth: 20,
                                       leading: SvgPicture.asset(
                                         'assets/icon/van.svg',
                                         fit: BoxFit.fitHeight,
                                         width: 50,
                                         color: AppColor.whiteColor,
                                       ),
                                       title: Text(
                                         'Van',
                                         style: FontAssets.mediumText.copyWith(
                                           fontWeight: FontWeight.bold,
                                           color: AppColor.whiteColor,
                                         ),
                                       ),
                                       subtitle: Text(
                                         data["distance"] ?? '-- km',
                                         style: FontAssets.smallText.copyWith(
                                           color: AppColor.whiteColor,
                                         ),
                                       ),
                                       trailing: Text(
                                         '\$ ${data["amount"]}',
                                         style: FontAssets.mediumText.copyWith(
                                             fontWeight: FontWeight.bold,
                                             color: AppColor.whiteColor
                                         ),
                                       ),
                                     ),
                                   ),
                                   SizedBox(height: 20),
                                   Container(
                                     decoration: BoxDecoration(
                                       color: AppColor.whiteColor.withOpacity(0.3),
                                       borderRadius: BorderRadius.circular(20),
                                     ),
                                     child: ListTile(
                                       selectedTileColor: AppColor.blackColor.withOpacity(0.3),
                                       selected: true,
                                       onTap: () {
                                         print('Change Payment Method');
                                       },
                                       leading: Icon(
                                         Icons.money,
                                         color: AppColor.whiteColor,
                                         size: 30,
                                       ),
                                       trailing: Icon(
                                         Icons.keyboard_arrow_down,
                                         color: AppColor.whiteColor,
                                       ),
                                       title: Text(
                                         'Payment through Paypal',
                                         style: FontAssets.smallText.copyWith(
                                             fontWeight: FontWeight.bold,
                                             color: AppColor.whiteColor
                                         ),
                                       ),
                                     ),
                                   ),
                                   SizedBox(height: 20),
                                   CustomButton(
                                     label: 'Pay Payment',
                                     onTap: ()async{
                                       if((widget.data["seats"]-widget.data["bookedSeats"])>=data["seats"]){

                                         await    Navigator.of(context).pushReplacement(
                                           MaterialPageRoute(
                                             builder: (BuildContext context) => UsePaypal(
                                                 sandboxMode: true,
                                                 clientId:
                                                 paypalClientId,
                                                 secretKey:
                                                 paypalSecretKey,
                                                 returnURL: "https://samplesite.com/return",
                                                 cancelURL: "https://samplesite.com/cancel",
                                                 transactions:  [
                                                   {
                                                     "amount": {
                                                       "total": '${data["amount"]}',
                                                       "currency": "USD",
                                                       "details": {
                                                         "subtotal": '${data["amount"]}',
                                                         "shipping": '0',
                                                         "shipping_discount": 0
                                                       }
                                                     },
                                                     "description":
                                                     "Deposit Payment in EduDrive",
                                                     // "payment_options": {
                                                     //   "allowed_payment_method":
                                                     //       "INSTANT_FUNDING_SOURCE"
                                                     // },
                                                     "item_list": {

                                                     }
                                                   }
                                                 ],
                                                 note: "Contact us for any questions on your order.",
                                                 onSuccess: (Map params) async {
                                                   //Payment deducted successfully
                                                   print("onSuccess: $params");
                                                   //Only Deposit amount
                                                   await FirestoreServices()
                                                       .updateRequestData(
                                                       data["id"],
                                                       {"status": 2,"payment_method":"done"
                                                       }).then((value) {

                                                   });
                                                   await FirestoreServices()
                                                       .updateScheduleBookData(
                                                       data["bookingId"],
                                                       {"bookedSeats":data["seats"]
                                                       }).then((value) {
                                                   });
                                                   var driverData =  await DriverRepo().fetchDriverDetails(data["driver_id"]);
                                                  num? wallet =  driverData["wallet"];
                                                  wallet = wallet!+data["amount"];
                                                  await FirestoreServices().updateDriver(data["driver_id"],{"wallet":wallet});
                                                  //send notification to driver on payment paid
                                                   await PushNotificationServices.sendNotification(title: "Schedule Booking",body: "New Schedule Booking actived",
                                                       type: 0,request_id: data["bookingId"],token: driverData["fcmToken"]);
                                                  //save payment notification
                                                   //type 0-> for general 1-> for wallet
                                                  await FirestoreServices().addNotification(type: 0,text: "\$ ${data["amount"]} amount deducted from Paypal",uid: FirebaseAuth.instance.currentUser!.uid);
                                                  await FirestoreServices().addNotification(type: 1,text: "\$ ${data["amount"]} amount Received in Wallet",uid: data["driver_id"]);
                                                  await FirestoreServices().addNotification(type: 0,text: "New Booking Actived",uid: FirebaseAuth.instance.currentUser!.uid);
                                                  await FirestoreServices().addNotification(type: 0,text: "New Booking Actived",uid: data["driver_id"]);



                                                 },
                                                 onError: (error) {
                                                   print("onError: $error");
                                                   Utils().toastMessage("Error Occur");


                                                 },
                                                 onCancel: (params) {
                                                   print('cancelled: $params');
                                                   Utils().toastMessage("Payment not Deposit");


                                                 }),
                                           ),
                                         );

                                       }
                                       else{
                                         Utils().toastMessage("Not Available");
                                       }

                                     },
                                   ),
                                 ],
                               ),
                             ),
                           );});
                         }
                         else if(data["status"]==2){
                           Utils().toastMessage("Request Accepted, Already");

                         }
                         else{
                           Utils().toastMessage("Driver has rejected Your request ");

                         }
                        },
                        onEdit: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) =>
                                  EditScheduleBookScreen(data: data,)));
                        },
                        onDelete: () {
                          Navigator.pop(context);
                        },
                        challanId: data["id"],
                        isStatus: true,
                        isDelete: false,
                        isEdit: false,
                        status: data["status"],

                        isDriverDetail: false,
                        amount: data["amount"].toString(),
                        pickupLocation: data["pickup"]["address"],
                        dropOffLocation: data["dropoff"]["address"],
                        totalDistance: '',
                        startDate: DateFormat('dd-MM-yyyy').format(
                            data['startDate'].toDate()).toString(),
                        endDate: DateFormat('dd-MM-yyyy').format(
                            data['endDate'].toDate()).toString(),
                        pickUpTime: data['startTime'].toString(),
                        dropOffTime: data['endTime'].toString(),
                        availabeSeats: data['seats']
                    ),
                  ) :
                  Center(child: Text("No Request",
                    style: FontAssets.largeText.copyWith(
                        color: Colors.white),)),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: CustomButton(
                loading: _isloading,
                color: AppColor.redColor,
                label: 'Request', onTap: () async {
                if (snapshot.data!.docs.length > 0) {
                  Utils().toastMessage("You already have created Request");
                }
                else {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) =>
                          EditScheduleBookScreen(data: widget.data,)));
                }
              },),
            ),
          );
        }else{return Scaffold(
        appBar: AppBar(
        title: Text("Request Schedule Book"),
        ),body: Center(child: CircularProgressIndicator(),),);}
      }
    );
  }
}
