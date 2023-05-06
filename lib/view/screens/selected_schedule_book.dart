import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/view/screens/edit_schedul_book.dart';
import 'package:edudrive/view/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../res/font_assets/font_assets.dart';
import '../widgets/schedule_book_container.dart';
import 'history.dart';

class SelectedScheduleBook extends StatefulWidget {
  const SelectedScheduleBook({Key? key}) : super(key: key);

  @override
  State<SelectedScheduleBook> createState() => _SelectedScheduleBookState();
}

class _SelectedScheduleBookState extends State<SelectedScheduleBook> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Schedule Book"),

      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: ScheduleBookContainer(

                challanId: "ID#74788734876",
                driverName: "Name",
                driverNumber: "6715236",
                pickupLocation: "complete address in details",
                dropOffLocation: "complete address in details",
                totalDistance: "10.3km",
                startDate: "15/04/2023",
                endDate: "15/06/2023",
                pickUpTime: "07:00 am",
                dropOffTime: "02:00 pm",
                amount: "",
                availabeSeats: 3,
                onTap: (){},
                onEdit: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>EditScheduleBookScreen(data: null,)));
                },
                onDelete: (){ },
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: CustomButton(label: 'Confirm', onTap: () {

                },),
              ),
            ),
          )
        ],
      ),
    );
  }
}
