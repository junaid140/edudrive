
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'fcmServices/firebase_messaging.dart';

class FirestoreServices{
  User? user = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String,dynamic>>> getParent(parentId)async{
    return await  FirebaseFirestore.instance.collection("parent").doc(parentId).get();
  }
  addDriver(driverId,driverData)async{
    await FirebaseFirestore.instance.collection("driver").doc(driverId).set(driverData);
  }
  Future<DocumentSnapshot<Map<String,dynamic>>> getDriver(driverId)async{
    return await  FirebaseFirestore.instance.collection("driver").doc(driverId).get();
  }Future<DocumentSnapshot<Map<String,dynamic>>> getInstantRequest(requestId)async{
    return await FirebaseFirestore.instance.collection("rideRequest").doc(requestId).get();
  }
  Future updateDriver(driverId,data)async{
     await  FirebaseFirestore.instance.collection("driver").doc(driverId).update(data);
  }
  Future addDriverVan(vanData)async{
   return await FirebaseFirestore.instance.collection("driverVan").doc().set(vanData);
  }
  Future updateFCMToken()async{
    String? fcmToken = await PushNotificationServices().getToken();
    await  FirebaseFirestore.instance.collection("driver").doc(user!.uid).update(
        {"fcmToken":fcmToken});

  }
  Future<QuerySnapshot<Map<String,dynamic>>> getDriverVans()async{
    return await  FirebaseFirestore.instance.collection("driverVan").where("uid",isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
  }


  Future<void> addScheduleBook({
    Map<String, dynamic>? pickUpAddress,
    Map<String, dynamic>? dropAddress,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    int? seat ,
  }) async {
    try {
      String bookingId = "BID${DateTime.now().microsecondsSinceEpoch}";
      print(bookingId);
      await FirebaseFirestore.instance.collection("scheduleBooks").doc(bookingId).set(
          {
            "id":bookingId,
            "pickUpAddress":pickUpAddress,
            "dropAddress":dropAddress,
            "startDate":startDate,
            "endDate":endDate,
            "startTime":startTime,
            "endTime":endTime,
            "seats":seat,
            "bookedSeats":0,
            "uid":FirebaseAuth.instance.currentUser!.uid,
            "create_at":DateTime.now(),
          });

    } catch (error) {
      print(error);
    }
  }

  Future updateRequestData(requestId, Map<String,dynamic> requestData)async{
   await FirebaseFirestore.instance.collection("requestsScheduleBooks").doc(requestId).update(requestData);
  }
  Future addNotification({String? text, int? type,String? uid})async{
    await FirebaseFirestore.instance.collection("notification").doc().set(
        {
          "text" : "$text",
          "type":type,
          "created_at":DateTime.now(),
          "uid":uid
        }
    );
  }

}