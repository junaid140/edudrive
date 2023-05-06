import 'dart:io';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edudrive/main.dart';
import 'package:edudrive/driver/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';

import 'package:edudrive/driver/helpers/platform_keys.dart';
import 'package:edudrive/driver/models/instant_ride_request.dart';
import 'package:edudrive/driver/screens/home_screen.dart';





class PushNotificationServices {

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;


  Future<String?> getToken() async {

    String? token = await firebaseMessaging.getToken();

    print('--------------token: $token');
    return token;

  }

  Map<String, dynamic> getClientRequestId(Map<String, dynamic> message) {
    String roomId = "";
    if (Platform.isAndroid) {
      roomId = message['roomId'];
      print('-------request id $roomId');
      return message;


    } else {
      roomId = message['roomId'];
      return message;

      // print('0000000------0000000-----client request id $clientRequestId');
    }
  }

  retrieveClientRequestData(Map<String,dynamic> requestId,context ) {
    print("fjjjj"+requestId["roomId"]);
      Map callInfo = {
        'requestId': requestId["roomId"],
        // 'senderName': value.get("channel_id"),
        // 'senderPicture': "",
      };



      print("---------0000-------information");
      print("---------0000-------${requestId["type"].runtimeType}");
      if(requestId["type"]=="1"){
        print("----- instent booking notification");
        rideRequestRef.doc(requestId["roomId"]).get().then(( value) async{
          InstantRideRequest instantRideRequest = InstantRideRequest.fromJson(value.data() as Map<String,dynamic>);

          DocumentSnapshot<Map<String,dynamic>> parentData = await FirestoreServices().getParent(instantRideRequest.parentId);

          instantRideRequest.parentName = parentData["name"];
          instantRideRequest.parentPhone = parentData["mobile"];

         requestNotification(context,requestId["roomId"], instantRideRequest, parentData.data()!);
        });


      }




      // } else {
      //   print("++++++++++++++++++error-____________________");
      // }
    }


  static sendNotification(
      {String? token, String? request_id, type, String? title,String? body, }) async {
    Map<String, String>headerMap = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $fcmServerKey',
      "apns-push-type": "background",
      "apns-priority": "5", // Must be `5` when `contentAvailable` is set to true.
      "apns-topic": "io.flutter.plugins.firebase.messaging",
    };
    Map notification = {
      'title': "$title",
      "body": "$body"
    };
    Map dataMap = {
      'click_action': 'EduDrive',
      'id': "1",
      'status': 'done',
      'roomId': request_id,
      'type': "$type",
    };
    Map sendNotificationMap = {
      "notification": notification,
      'data': dataMap,
      "android": {
        "priority": "high"
      },
      "apns":{
        "payload":{
          "aps":{
            "contentAvailable": true,
            "alert" : {
              "body" : "$body",
              "title" : "$title",
            },
          },
        },
      },
      "to": token,
    };
    var res = await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: headerMap,
        body: jsonEncode(sendNotificationMap)
    );

    print(res);
  }

}

