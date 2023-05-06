import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edudrive/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../helpers/http_exception.dart';
import '../helpers/firebase_utils.dart';

import '../models/user.dart';
import '../models/address.dart';

import 'auth.dart';
import 'user_provider.dart';

class RideProvider with ChangeNotifier {
  void update(Auth auth, UserProvider userData) {
    print("====");
    authToken = auth.token;
    userId = auth.userId;

    pickupLocation = userData.pickupLocation;
    dropOffLocation = userData.dropOffLocation;
    print(dropOffLocation);
    // user = userData.user;
  }

  late String? authToken;
  late String? userId;

  late String? rideId;

  late User user;

  late Address? pickupLocation;
  late Address? dropOffLocation;

  Future<Map<String,dynamic>> saveRideRequest() async {
    try {
      String requestId = "RID${DateTime.now().microsecondsSinceEpoch}";
      print(requestId);
      Map<String,dynamic> requestData = {
        'id':requestId,
        'driver_id': null,
        'request_status': 'waiting',
        'payment_method': 'Cash',
        'pickup': {
          'latitude': pickupLocation?.latitude,
          'longitude': pickupLocation?.longitude,
        },
        'dropoff': {
          'latitude': dropOffLocation?.latitude,
          'longitude': dropOffLocation?.longitude,
        },
        'created_at': DateTime.now().toIso8601String(),
        // 'rider_name': user.name,
        // 'rider_mobile': user.mobile,
        'parentId':firebase.FirebaseAuth.instance.currentUser!.uid,
        'pickup_address': pickupLocation?.address,
        'dropoff_address': dropOffLocation?.address,
      };
   return  await FirestoreServices().addRequest(requestId,requestData ,).then((value) {
        rideId= requestId;
        notifyListeners();

        return requestData;
     });


      notifyListeners();
    } catch (error) {
      print(error);
      throw error;

    }
  }

  Future<void>  cancelRideRequest()async{
    try {
      await FirestoreServices().deleteRequest(rideId!, ).then((value) {

        notifyListeners();

      });

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
    }



}


