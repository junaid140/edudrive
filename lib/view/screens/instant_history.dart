import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/instant_ride_request.dart';
import '../../res/app_color/app_color.dart';
import '../../res/font_assets/font_assets.dart';
import '../widgets/instant_book_container.dart';



class InstantHistory extends StatelessWidget {
  const InstantHistory({Key? key}) : super(key: key);
  static const routeName = '/instant-history';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){Navigator.pop(context);},
          icon: Icon(Icons.arrow_back,color: Colors.white,),
        ),
        centerTitle: true,
        title: Text("Instant Booking History",style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
        ),),
      ),
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
                  stream: rideRequestRef.where("parentId",isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
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
                          return GestureDetector(onTap: (){

                          },
                            child: InstantBookContainer(
                              status: instantRideRequest.requestStatus!,
                              challanId: instantRideRequest.id!,
                              pickupLocation: instantRideRequest.pickupAddress!,
                              dropOffLocation: instantRideRequest.dropoffAddress!,
                              fare: data.data()["fares"]??"0.0",
                            ),
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
