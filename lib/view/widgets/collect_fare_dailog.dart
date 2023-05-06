import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../res/font_assets/font_assets.dart';


class CollectFareDailog extends StatelessWidget {
  final String paymentMethod ;
  final double fareAmount;
   CollectFareDailog({Key? key, required this.fareAmount, required this.paymentMethod}) : super(key: key);



  @override
  Widget build(BuildContext context) {
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
                    "Collect Fare",
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
                  // ListTile(
                  //
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   tileColor: Theme.of(context).primaryColorDark.withOpacity(0.6),
                  //   contentPadding: const EdgeInsets.symmetric(
                  //     vertical: 8,
                  //     horizontal: 16,
                  //   ),
                  //   leading: parentData["profile"]==null||parentData["profile"]==""?Image.asset('assets/images/user_icon.png'):Image.network(parentData["profile"]),
                  //   title: Text(
                  //     "${parentData["name"]}",
                  //     style: FontAssets.largeText,
                  //   ),
                  //   subtitle: Text(
                  //     "${parentData["mobile"]}",
                  //     style: FontAssets.smallText,
                  //   ),
                  //
                  // ),

                  Text("Onilne Payment",style: FontAssets.mediumText.copyWith(color: Colors.black),),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: Text("\$ ${fareAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 55,color: Colors.black))),
                  // ListTile(title: Text("Pick Up",style: FontAssets.largeText,),
                  //   subtitle: Text("${instantRideRequest.pickupAddress}",style: FontAssets.smallText,),),
                  // ListTile(title: Text("Drop Off",style: FontAssets.largeText,),
                  //   subtitle: Text("${instantRideRequest.dropoffAddress}",style: FontAssets.smallText,),),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  Padding(padding:EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text("This is the total Trip amount that is charge to the Parent",textAlign: TextAlign.center,),),
                  SizedBox(height: 10,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      ElevatedButton(

                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                          onPressed: ()async{
                            Navigator.pop(context,"close");
                            // await Provider.of<MapsProvider>(context, listen: false).goOnline();

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
                          }, child:  Padding(
                            padding: const EdgeInsets.fromLTRB(20,8,20,8),
                            child: Text("Pay Cash"),
                          )),
                    ],
                  ),
                ],
              ) ,
            ),
          ),
        )
    );
  }
}
