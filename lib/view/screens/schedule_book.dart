import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/view/screens/request_schedule_book.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../repository/driver_repo.dart';
import '../base/schedule_book_shimmer.dart';
import '../widgets/schedule_book_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleBook extends StatefulWidget {
  const ScheduleBook({Key? key}) : super(key: key);

  @override
  State<ScheduleBook> createState() => _ScheduleBookState();
}

class _ScheduleBookState extends State<ScheduleBook> {
  getAllBooking(){
    return FirebaseFirestore.instance.collection("scheduleBooks").snapshots();
  }
  final scheduleReference = FirebaseFirestore.instance.collection("scheduleBooks");
  bool isLoading = false;
  List<Map<String, dynamic>> scheduleData = [];
  _getData() async {
    setState(() {
      isLoading = true;
    });
    scheduleReference
    // .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((doc) async{
      scheduleData.clear();
      for (var item in doc.docs) {
      var driverData =  await DriverRepo().fetchDriverDetails(item["uid"]);
      print(driverData);
       scheduleData.add({
         "schedule":item.data(),
         "driver":driverData,
       });
      }
      setState(() {
        isLoading = false;
      });
      if (mounted) setState(() {});
    });
  }
  @override
  void initState() {
    _getData();
    getAllBooking();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 20,),
      !isLoading? Expanded(
            child:ListView.builder(
                itemCount: scheduleData.length,
                itemBuilder: (BuildContext context, int index) {
                  final data=scheduleData[index]["schedule"];
                  final driverData = scheduleData[index]["driver"];
                  return  ScheduleBookContainer(
                      onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestScheduleBook(data: data)));},
                      onEdit: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestScheduleBook(data: data)));
                      },
                      onDelete: (){},
                      challanId: data["id"],
                      status: 0,
                      amount: "",
                      driverName: "${driverData["name"]}",
                      driverNumber: "${driverData["mobile"]}",
                      pickupLocation: data["pickUpAddress"]["address"],
                      dropOffLocation: data["dropAddress"]["address"],
                      totalDistance: '10.3km',
                      startDate:  DateFormat('dd-MM-yyyy').format(data['startDate'].toDate()).toString(),
                      endDate:  DateFormat('dd-MM-yyyy').format(data['endDate'].toDate()).toString(),
                      pickUpTime: (data['startTime']).toString(),
                      dropOffTime: data['endTime'].toString(),
                      availabeSeats: data['seats']-(data["bookedSeats"]??0)
                  );
                })

          ):ScheduleBookShimmer(isEnabled: true,),
        ],
      ),
    );
  }
}