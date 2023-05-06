import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edudrive/models/instant_ride_request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../main.dart';
import '../res/app_color/app_color.dart';
import '../res/font_assets/font_assets.dart';
import '../widgets/instant_book_container.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({Key? key}) : super(key: key);
  static const routeName = '/earnings-screen';
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
            ListTile(
              title: Text(
                'History',
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
                  stream: rideRequestRef.where("driver_id",isEqualTo: FirebaseAuth.instance.currentUser!.uid).where("request_status",isEqualTo: "ended").snapshots(),
                  builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot) {
                    return snapshot.hasData? snapshot.data!.docs.length>0?
                    ListView.builder(
                      // primary: false,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context,index){
                          var data = snapshot.data!.docs[index];
                          InstantRideRequest instantRideRequest=InstantRideRequest.fromJson(data.data());
                          return InstantBookContainer(
                            status: instantRideRequest.requestStatus!,
                            challanId: instantRideRequest.id!,
                            pickupLocation: instantRideRequest.pickupAddress!,
                            dropOffLocation: instantRideRequest.dropoffAddress!,
                            fare: data["fares"],
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
