
import 'package:edudrive/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'fcmServices/firebase_messaging.dart';
final user=FirebaseAuth.instance.currentUser;

class FirestoreServices{

  Future addParent(parentId,parentData)async{
    await FirebaseFirestore.instance.collection("parent").doc(parentId).set(parentData);
  }
  Future updateFCMToken()async{
    String? fcmToken = await PushNotificationServices().getToken();
    await  FirebaseFirestore.instance.collection("parent").doc(user!.uid).update(
        {"fcmToken":fcmToken});

  }
  Future updateDriver(driverId,Map<String, dynamic>data)async{
    await  FirebaseFirestore.instance.collection("driver").doc(driverId).update(
        data);
  }
  Future updateParent(parentId,Map<String, dynamic>data)async{
    await  FirebaseFirestore.instance.collection("parent").doc(parentId).update(
        data);
  } Future addComplain(parentId,Map<String, dynamic>data)async{
    await  FirebaseFirestore.instance.collection("complain").add(
        data);
  }
  Future updateRequestData(requestId, Map<String,dynamic> requestData)async{
    await FirebaseFirestore.instance.collection("requestsScheduleBooks").doc(requestId).update(requestData);
  }
  Future updateScheduleBookData(bookId, Map<String,dynamic> requestData)async{
    await FirebaseFirestore.instance.collection("scheduleBooks").doc(bookId).update(requestData);
  }
 Future<DocumentSnapshot<Map<String,dynamic>>> getParent(parentId)async{
  return await  FirebaseFirestore.instance.collection("parent").doc(parentId).get();
  }
  Future<DocumentSnapshot<Map<String,dynamic>>> getDriver(driverId)async{
    return await  FirebaseFirestore.instance.collection("driver").doc(driverId).get();
  }
  Future<void> requestScheduleBook({
    String? requestId,
    Map<String, dynamic>? data,
  }) async {
    try {

      // String bookingId = "BID${DateTime.now().microsecondsSinceEpoch}";
      //
      // print(bookingId);
      await FirebaseFirestore.instance.collection("requestsScheduleBooks").doc(requestId).set(
          data!);

    } catch (error) {
      Utils().toastMessage(error.toString());
      print(error);
    }
  }

  Future addRequest(String requestId, Map<String, dynamic> requestData)async{

    await FirebaseFirestore.instance.collection("rideRequest").doc(requestId).set(requestData);
  }
  Future deleteRequest(String requestId,)async{

    await FirebaseFirestore.instance.collection("rideRequest").doc(requestId).delete();
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