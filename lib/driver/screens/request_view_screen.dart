import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:edudrive/services/firestore_services.dart';
import 'package:edudrive/utils/utils.dart';
import 'package:edudrive/driver/widgets/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../res/app_color/app_color.dart';
import '../services/fcmServices/firebase_messaging.dart';
import '../widgets/history_key_value_pair.dart';
import 'create_schedule_book.dart';

class RequestViewScreen extends StatefulWidget {
  RequestViewScreen({Key? key,required this.bookingId}) : super(key: key);
  String bookingId;
  @override
  State<RequestViewScreen> createState() => _RequestViewScreenState();
}

class _RequestViewScreenState extends State<RequestViewScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController fairAmount = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Requests"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("requestsScheduleBooks").where("bookingId",isEqualTo: widget.bookingId)
                      .where("driver_id",isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
                  builder: (context,AsyncSnapshot<QuerySnapshot> snapshot) {
                    return snapshot.hasData?
                    ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context,index){
                          var data = snapshot.data!.docs[index];
                          print("Length is :${snapshot.data!.docs.length}");
                          return GestureDetector(
                            onTap: (){
                              if(data["status"]==0){
                                showDialog(context: context, builder: (context){
                                  return AlertDialog(title: Text("Are you want to Accept or Decline ",style: FontAssets.mediumText.copyWith(color: AppColor.whiteColor),)
                                    ,
                                    content:Form(
                                      key: formKey,
                                      child: Container(
                                        child:     CustomTextField(
                                          controller: fairAmount,
                                          hint: 'Enter Fair Amount',
                                          textInputAction: TextInputAction.next,
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Field is empty';
                                            }
                                            else{
                                              return null;
                                            }
                                          },
                                          onSaved: (value) {
                                          },
                                        ),
                                      ),
                                    ),
                                    actions: [ElevatedButton(
                                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                                        onPressed: ()async{

                                          await FirestoreServices()
                                              .updateRequestData(
                                              data["id"],
                                              {"status": 3,
                                              }).then((value) {
                                            Navigator.pop(context);
                                            fairAmount.text="";
                                          });
                                        var parentData=  await FirestoreServices().getParent(data["parentId"]);

                                          await PushNotificationServices.sendNotification(title: "Schedule Booking",body: "New Schedule Booking Request received",type: 0,request_id: data["id"],token: parentData["fcmToken"]);

                                          await FirestoreServices().addNotification(type: 0,text: "Decline a request",uid: FirebaseAuth.instance.currentUser!.uid);
                                          await FirestoreServices().addNotification(type: 0,text: "Decline your request",uid: data["parentId"]);


                                        }, child: Text("Decline")),
                                      ElevatedButton(
                                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                                          onPressed: ()async{
                                            if(formKey.currentState!.validate()){
                                              await FirestoreServices()
                                                  .updateRequestData(
                                                  data["id"],
                                                  {"status": 1,
                                                    "amount":int.parse(fairAmount.text)}).then((value) async{
                                                var parentData=  await FirestoreServices().getParent(data["parentId"]);

                                                await PushNotificationServices.sendNotification(title: "Schedule Booking",body: "New Schedule Booking Request received",type: 0,request_id: data["id"],token: parentData["fcmToken"]);

                                                await FirestoreServices().addNotification(type: 0,text: "Accept a request",uid: FirebaseAuth.instance.currentUser!.uid);
                                                await FirestoreServices().addNotification(type: 0,text: "Your request Accept, now pay payment to active",uid: data["parentId"]);

                                                Navigator.pop(context);
                                                fairAmount.text="";
                                              });
                                            }
                                            else{
                                              Utils().toastMessage("Please Enter Fair Amount");
                                            }
                                          }, child: Text("Accept"))],);
                                });
                              }
                              else{
                                Utils().toastMessage("Request Status Already Updated");
                              }

                            },
                            child: Container(

                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.73), blurRadius: 8,offset: Offset(3,3))
                                  ],
                                  color: AppColor.primaryColor
                              ),
                              margin: EdgeInsets.all(16),
                              width: double.infinity,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: data['status']==0?Colors.orange:data['status']==1?Colors.blue.shade400:data['status']==2?Colors.green:Colors.red
                                        ),
                                        margin: EdgeInsets.only(top: 10,right: 16),
                                        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                        child: Text("${data['status']==0?"Pending":data['status']==1?"On Payment":data['status']==2?"Active":"Decline"}")
                                        // 0-> pending, 1-> on Payment, 2-> Active, 3-> Decline
                                    )],
                                  ),
                                  ListTile(
                                    title:Text("${snapshot.data!.docs[index]["id"]}",style: TextStyle(
                                        color: Colors.white
                                    ),),

                                     ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 16,right: 16),
                                    child: Column(

                                      children: [
                                        HistoryKeyValuePair(title: "Pickup Location",value: "${snapshot.data!.docs[index]["pickup"]["address"]}",),
                                        HistoryKeyValuePair(title: "Drop Off Location",value:"${snapshot.data!.docs[index]["dropoff"]["address"]}" ,),
                                        HistoryKeyValuePair(title: "Total Distance",value: "${snapshot.data!.docs[index]["distance"]}",),
                                        HistoryKeyValuePair(title: "Start Date",value: "${DateFormat.yMd().format(snapshot.data!.docs[index]["startDate"].toDate())}",),
                                        HistoryKeyValuePair(title: "End Date",value:"${DateFormat.yMd().format(snapshot.data!.docs[index]["endDate"].toDate())}" ,),
                                        HistoryKeyValuePair(title: "Pickup Time",value: "${snapshot.data!.docs[index]["startTime"]}",),
                                        HistoryKeyValuePair(title: "Drop Time", value: "${snapshot.data!.docs[index]["endTime"]}",),
                                        HistoryKeyValuePair(title: "Requested seats",value: "${snapshot.data!.docs[index]["seats"]}",),
                                        HistoryKeyValuePair(title: "Fair Amount",value: "\$ ${snapshot.data!.docs[index]["amount"]}",),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }):
                    Center(child: CircularProgressIndicator(),);
                  }
              ),
            )
          ],
        ),
      ),
    );
  }
}
