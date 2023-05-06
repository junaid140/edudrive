import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:edudrive/driver/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:intl/intl.dart';
import '../res/app_color/app_color.dart';
import '../res/app_const/app_const.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/reuseable_title_text.dart';

class CreateScheduleBookScreen extends StatefulWidget {
  const CreateScheduleBookScreen({Key? key}) : super(key: key);
  static const routeName = '/create-schedule-booking-screen';

  @override
  State<CreateScheduleBookScreen> createState() =>
      _CreateScheduleBookScreenState();
}

class _CreateScheduleBookScreenState extends State<CreateScheduleBookScreen> {
  Position? _currentPosition;
  String autocompletePlace = "";
  String address1 = "";
  double lat1 = 0.0;
  double lng1 = 0.0;
  String address2 = "";
  double lat2 = 0.0;
  double lng2 = 0.0;
  bool _isLoading = false;
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  @override
  void initState() {
    // TODO: implement initState
    _getCurrentPosition();
    super.initState();
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        lng1 = _currentPosition!.longitude;
        lat1 = _currentPosition!.latitude;
        lng2 = _currentPosition!.longitude;
        lat2 = _currentPosition!.latitude;
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  TextEditingController startAddress = TextEditingController();
  TextEditingController endAddress = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController startTime = TextEditingController();
  TextEditingController endTime = TextEditingController();
  TextEditingController seats = TextEditingController();
  String? _hour, _minute, _time;

  String? dateTime;

  DateTime date1 = DateTime.now();
  DateTime date2 = DateTime.now();

  TimeOfDay time1 = TimeOfDay(hour: 00, minute: 00);
  TimeOfDay time2 = TimeOfDay(hour: 00, minute: 00);
  Future<DateTime?> _selectDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2015),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.primaryColor, // <-SEE HERE
              onPrimary: Colors.white, // <-- SEE HERE
              onSurface: Colors.white.withOpacity(0.8), // <-- SEE HERE
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Colors.white, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 00, minute: 00),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            cardColor: Colors.black,
            backgroundColor: Colors.black.withOpacity(0.8),
            colorScheme: ColorScheme.dark(
              onBackground: Colors.black.withOpacity(0.8),
              background: Colors.black.withOpacity(0.8),
              primary: AppColor.primaryColor, // <-SEE HERE
              onPrimaryContainer: Colors.blue,

              onPrimary: Colors.black, // <-- SEE HERE
              onSurface: Colors.white.withOpacity(0.8), // <-- SEE HERE
              secondary: Colors.yellow,
            ),
            textTheme: TextTheme().copyWith(),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Colors.white, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Create Schedule Book",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReuseableTitleText(
                        title: "Starting Location",
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlacePicker(
                                apiKey: Platform.isAndroid
                                    ? "${AppConst.mapKey}"
                                    : "YOUR IOS API KEY",

                                onPlacePicked: (result) {
                                  print(result.formattedAddress);
                                  Navigator.of(context).pop();
                                  address1 = result.formattedAddress.toString();
                                  lat1 = result.geometry!.location.lat;
                                  lng1 = result.geometry!.location.lng;
                                  startAddress.text = address1;
                                  setState(() {});
                                },
                                initialPosition: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude),
                                useCurrentLocation: true,
                                resizeToAvoidBottomInset: true,
                                // only works in page mode, less flickery, remove if wrong offsets
                                selectedPlaceWidgetBuilder: (_, selectedPlace,
                                    state, isSearchBarFocused) {
                                  return isSearchBarFocused
                                      ? Container()
                                      // Use FloatingCard or just create your own Widget.
                                      : FloatingCard(
                                          color: AppColor.primaryColor,
                                          bottomPosition:
                                              10.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                                          leftPosition: 20.0,
                                          rightPosition: 20.0,
                                          height: 150,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          child:
                                              // state == SearchingState.Searching ?
                                              // Center(child: CircularProgressIndicator()) :
                                              Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  " ${selectedPlace == null ? "Selected Location" : selectedPlace.formattedAddress!}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    print(
                                                        "do something with [selectedPlace] data");
                                                    address1 = selectedPlace!
                                                        .formattedAddress
                                                        .toString();
                                                    lat1 = selectedPlace
                                                        .geometry!.location.lat;
                                                    lng1 = selectedPlace
                                                        .geometry!.location.lng;
                                                    startAddress.text =
                                                        address1;
                                                    setState(() {});
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius: BorderRadius.circular(16)),
                                                    padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                                                    child: Text("Done",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                },
                              ),
                            ),
                          );
                        },
                        child: CustomTextField(
                          enable: false,
                          controller: startAddress,
                          hint: 'Starting Location',
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Field is empty';
                            }
                          },
                          onSaved: (value) {},
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReuseableTitleText(
                        title: "End Location",
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlacePicker(
                                apiKey: Platform.isAndroid
                                    ? "${AppConst.mapKey}"
                                    : "YOUR IOS API KEY",

                                onPlacePicked: (result) {
                                  print(result.formattedAddress);
                                  Navigator.of(context).pop();
                                  address2 = result.formattedAddress.toString();
                                  lat2 = result.geometry!.location.lat;
                                  lng2 = result.geometry!.location.lng;
                                  startAddress.text = address2;
                                  setState(() {});
                                },
                                initialPosition: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude),

                                useCurrentLocation: true,
                                resizeToAvoidBottomInset: true,
                                // only works in page mode, less flickery, remove if wrong offsets
                                selectedPlaceWidgetBuilder: (_, selectedPlace,
                                    state, isSearchBarFocused) {
                                  return isSearchBarFocused
                                      ? Container()
                                      // Use FloatingCard or just create your own Widget.
                                      : FloatingCard(
                                          color: AppColor.primaryColor,
                                          bottomPosition:
                                              10.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                                          leftPosition: 20.0,
                                          rightPosition: 20.0,
                                          height: 150,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          child:
                                              // state == SearchingState.Searching ?
                                              // Center(child: CircularProgressIndicator()) :
                                              Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  " ${selectedPlace == null ? "Selected Location" : selectedPlace!.formattedAddress!}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    print(
                                                        "do something with [selectedPlace] data");
                                                    address2 = selectedPlace!
                                                        .formattedAddress
                                                        .toString();
                                                    lat2 = selectedPlace
                                                        .geometry!.location.lat;
                                                    lng2 = selectedPlace
                                                        .geometry!.location.lng;
                                                    endAddress.text = address2;
                                                    setState(() {});
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16)),
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            20, 8, 20, 8),
                                                    child: Text(
                                                      "Done",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                },
                              ),
                            ),
                          );
                        },
                        child: CustomTextField(
                          enable: false,
                          controller: endAddress,
                          hint: 'End Location',
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Field is empty';
                            }
                          },
                          onSaved: (value) {},
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReuseableTitleText(
                        title: "Starting Date",
                      ),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await _selectDate(context);

                          if (picked != null) {
                            setState(() {
                              date1 = picked;
                              startDate.text = DateFormat.yMd().format(date1);
                            });
                          }
                        },
                        child: CustomTextField(
                          enable: false,
                          controller: startDate,
                          hint: 'Starting Date',
                          suffixIcon: Icon(Icons.calendar_month_outlined),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Field is empty';
                            }
                          },
                          onSaved: (value) {},
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReuseableTitleText(
                        title: "End Date",
                      ),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await _selectDate(context);
                          if (picked != null) {
                            setState(() {
                              date2 = picked;
                              endDate.text = DateFormat.yMd().format(date2);
                            });
                          }
                        },
                        child: CustomTextField(
                          enable: false,
                          suffixIcon: Icon(Icons.calendar_month_outlined),
                          controller: endDate,
                          hint: 'Select End Date',
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Field is empty';
                            }
                          },
                          onSaved: (value) {},
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReuseableTitleText(
                        title: "PickUp Time",
                      ),
                      GestureDetector(
                        onTap: () async {
                          final TimeOfDay? picked = await _selectTime(context);
                          if (picked != null)
                            setState(() {
                              time1 = picked;
                              _hour = time1.hour.toString();
                              _minute = time1.minute.toString();
                              _time = _hour! + ' : ' + _minute!;
                              String time = _time!;
                              time = formatDate(
                                  DateTime(date1.year, date1.month, date1.day,
                                      time1.hour, time1.minute),
                                  [
                                    yy,
                                    ':',
                                    mm,
                                    ':',
                                    dd,
                                    ':',
                                    hh,
                                    ':',
                                    nn,
                                    " ",
                                    am
                                  ]).toString();
                              startTime.text = time;
                              date1 = DateTime(
                                date1.year,
                                date1.month,
                                date1.day,
                                time1.hour,
                                time1.minute,
                              );
                            });
                        },
                        child: CustomTextField(
                          enable: false,
                          controller: startTime,
                          hint: 'Select PickUp Time',
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Field is empty';
                            }
                          },
                          onSaved: (value) {},
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReuseableTitleText(
                        title: "Drop Time",
                      ),
                      GestureDetector(
                        onTap: () async {
                          final TimeOfDay? picked = await _selectTime(context);
                          if (picked != null)
                            setState(() {
                              time2 = picked;
                              _hour = time2.hour.toString();
                              _minute = time2.minute.toString();
                              _time = _hour! + ' : ' + _minute!;
                              String time = _time!;

                              time = formatDate(
                                  DateTime(date2.year, date2.month, date2.day,
                                      time2.hour, time2.minute),
                                  [
                                    yy,
                                    ':',
                                    mm,
                                    ':',
                                    dd,
                                    ':',
                                    hh,
                                    ':',
                                    nn,
                                    " ",
                                    am
                                  ]).toString();
                              endTime.text = time;
                              date2 = DateTime(
                                date2.year,
                                date2.month,
                                date2.day,
                                time2.hour,
                                time2.minute,
                              );
                            });
                        },
                        child: CustomTextField(
                          enable: false,
                          controller: endTime,
                          hint: 'Select Drop Time',
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Field is empty';
                            }
                          },
                          onSaved: (value) {},
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReuseableTitleText(
                        title: "Total Seats",
                      ),
                      CustomTextField(
                        keyboardType: TextInputType.number,
                        controller: seats,
                        hint: 'Available Seats',
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Field is empty';
                          }
                        },
                        onSaved: (value) {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          margin: EdgeInsets.all(16),
          height: 50,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : CustomButton(
                  label: 'Continue',
                  onTap: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        setState(() {
                          _isLoading = true;
                        });
                        await FirestoreServices().addScheduleBook(
                          pickUpAddress: {
                            "address": "$address1",
                            "lat": lat1,
                            "lng": lng1
                          },
                          dropAddress: {
                            "address": "$address2",
                            "lat": lat2,
                            "lng": lng2
                          },
                          startDate: date1,
                          endDate: date2,
                          startTime: startTime.text,
                          endTime: endTime.text,
                          seat: int.parse(seats.text),
                        ).then((value) {
                          Navigator.pop(context);
                        });
                        setState(() {
                          _isLoading = false;
                        });

                        // _submit(context);
                      } catch (e) {
                        print(e);
                      }
                    }
                  },
                ),
        ));
  }
}

Widget CustomText(text, double fontSize, FontWeight fontWeight) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
    child: Text(
      "$text",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontWeight: fontWeight,
          fontSize: fontSize,
          color: AppColor.whiteColor),
    ),
  );
}
