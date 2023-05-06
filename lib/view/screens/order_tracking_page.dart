import 'dart:async';
import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edudrive/helpers/platform_keys.dart';
import 'package:edudrive/res/app_color/app_color.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../helpers/direction_helper.dart';
// import 'package:location/location.dart';


class OrderTrackingPage extends StatefulWidget {
  Map<String,dynamic> data;
   OrderTrackingPage({Key? key,required this.data}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
   LatLng? sourse ;
  LatLng? destination ;
  List<LatLng> polylineCoordinates = [];
  Position? currentLocation;
  DocumentSnapshot<Map<String,dynamic>>? snapshot;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates1 = [];
  Set<Circle> circles = {};
  Set<Polyline> polylineSet = {};
  List<LatLng> plineCoordinates = [];
  Set<Marker> _markers = {};
  BitmapDescriptor? animatingMarkerIcon;

  LatLng? _vanLocation;

  DatabaseReference _vanLocationRef =
  FirebaseDatabase.instance.reference().child('available-drivers');

  getServiceManData()async{
    snapshot = await FirebaseFirestore.instance.collection("driver").doc(widget.data["driver_id"]).get();
    setState((){});
  }
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
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

  void getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentLocation = position;    destination = LatLng(
        widget.data["dropoff"]["latitude"],widget.data["dropoff"]["longitude"], );
    sourse = LatLng(
        widget.data["pickup"]["lat"],widget.data["pickup"]["lng"], );
    if (mounted) setState((){});


    // Map<String, dynamic> response =
    // await Geofire.getLocation("${widget.data["driver_id"]}");
    //
    // print(response);


    GoogleMapController googleMapController = await _controller.future;


      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              zoom: 15.5,
              target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!))));
      setState(() {});
    getPlaceDirections();

    // _vanLocationRef.child("${widget.data["driver_id"]}").onValue.listen(( event) {
    //   var snapshot = event.snapshot;
    //   var latitude = snapshot.value!['latitude'];
    //   var longitude = snapshot.value['longitude'];
    //   var vanLocation = LatLng(latitude, longitude);
    //   if (event.snapshot.value != null) {
    //     Map<dynamic, dynamic> map =Map<String, dynamic>.from( event.snapshot.value!);
    //     double latitude = map['latitude'];
    //     double longitude = map['longitude'];
    //     setState(() {
    //       _vanLocation = LatLng(latitude, longitude);
    //     });
    //   }
    // });
    // });

  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    // print("${sourse!.latitude}  ${sourse!.longitude}");
    // print("${destination!.latitude}  ${destination!.longitude}");
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        mapsAPI,
        PointLatLng(widget.data["pickup"]["lat"],widget.data["pickup"]["lng"],),
        PointLatLng(widget.data["dropoff"]["latitude"],widget.data["dropoff"]["longitude"]),
    travelMode: TravelMode.driving);

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) =>
          polylineCoordinates.add(LatLng(point.latitude, point.longitude)));
      setState(() {});
    }
  }

  void setCustomMarkerIcon(){
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/images/pinIcon.png").then((icon){
      sourceIcon = icon;
      destinationIcon = icon;
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/images/carIcon.png").then((icon){
      currentLocationIcon = icon;
    });
  }
 getPlaceDirections() async {
    try {
      // final user = Provider.of<UserProvider>(context, listen: false);
      // final initialPosition = user.pickupLocation!;
      // final finalPosition = user.dropOffLocation!;

      final pickupLatLng = LatLng(
          widget.data["pickup"]["lat"],widget.data["pickup"]["lng"],
      );
      final dropoffLatLng = LatLng(
        widget.data["dropoff"]["latitude"],widget.data["dropoff"]["longitude"],
      );

      final details = await DirectionHelper.obtainPlaceDirectionDetails(
        pickupLatLng,
        dropoffLatLng,
      );

      final polylinePoints = PolylinePoints();
      List<PointLatLng> decodedPolylinePointsResult =
      polylinePoints.decodePolyline(details.encodedPoints!);

      plineCoordinates.clear();
      if (decodedPolylinePointsResult.isNotEmpty) {
        decodedPolylinePointsResult.forEach((PointLatLng point) {
          plineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }

      late LatLngBounds screenBounds;
      if (pickupLatLng.latitude > dropoffLatLng.latitude &&
          pickupLatLng.longitude > dropoffLatLng.longitude) {
        screenBounds = LatLngBounds(
          southwest: dropoffLatLng,
          northeast: pickupLatLng,
        );
      } else if (pickupLatLng.latitude > dropoffLatLng.latitude) {
        screenBounds = LatLngBounds(
          southwest: LatLng(dropoffLatLng.latitude, pickupLatLng.longitude),
          northeast: LatLng(pickupLatLng.latitude, dropoffLatLng.longitude),
        );
      } else if (pickupLatLng.longitude > dropoffLatLng.longitude) {
        screenBounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, dropoffLatLng.longitude),
          northeast: LatLng(dropoffLatLng.latitude, pickupLatLng.longitude),
        );
      } else {
        screenBounds = LatLngBounds(
          southwest: pickupLatLng,
          northeast: dropoffLatLng,
        );
      }
      GoogleMapController googleMapController = await _controller.future;

      googleMapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          screenBounds,
          120,
        ),
      );

      Marker pickupMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: "My Location",
          snippet: 'My Location',
        ),
        position: pickupLatLng,
        markerId: MarkerId('Pick Up'),
      );

      Marker dropoffMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: widget.data["dropoff"]["dropoff_address"],
          snippet: 'Drop Off Location',
        ),
        position: dropoffLatLng,
        markerId: MarkerId('Drop Off'),
      );
      // Marker animatedMaker = Marker(markerId: MarkerId("animated"),
      //     position: _vanLocation!,icon: animatingMarkerIcon!,
      //
      //     infoWindow: InfoWindow(title: "Current Location"));
      Circle pickupCircle = Circle(
        fillColor: Colors.cyan,
        center: pickupLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.cyanAccent,
        circleId: CircleId('Pick Up circle'),
      );
      Circle dropoffCircle = Circle(
        fillColor: Colors.lime,
        center: dropoffLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.limeAccent,
        circleId: CircleId('Drop Off circle'),
      );

      polylineSet.clear();
      setState(() {
        // tripDetails = details;
        final polyline = Polyline(
          color: Theme.of(context).colorScheme.secondary,
          polylineId: PolylineId('Place Directions'),
          jointType: JointType.round,
          points: plineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );
        polylineSet.add(polyline);
        _markers.add(pickupMarker);
        _markers.add(dropoffMarker);
        // _markers.removeWhere((marker)=>marker.markerId.value=="animated");
        // _markers.add(animatedMaker);
        circles.add(pickupCircle);
        circles.add(dropoffCircle);
      });
    } on HttpException catch (error) {
      var errorMessage = 'Request Failed';
      print(error);
      // _snackbar(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not get directions. Please try again later.';
      print(error);
      // _snackbar(errorMessage);
    }
  }
  // void createIcon(){
  //   if(animatingMarkerIcon==null){
  //     ImageConfiguration imageConfiguration = createLocalImageConfiguration(
  //       context,
  //       size: Size(2, 2),
  //     );
  //     BitmapDescriptor.fromAssetImage(
  //       imageConfiguration,
  //       'assets/images/car_ios.png',
  //     ).then((value) {
  //       animatingMarkerIcon = value;
  //     });
  //   }
  //
  // }
  @override
  void initState() {
    // TODO: implement initState
    getCurrentLocation();

    setCustomMarkerIcon();
    getServiceManData();


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

        body: currentLocation == null
            ? const Center(child: Text("Loaction"))
            : Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: GoogleMap(

                        initialCameraPosition: CameraPosition(
                            target: LatLng(
                                currentLocation!.latitude!, currentLocation!.longitude!),
                            zoom: 14.5),
                        polylines: polylineSet,
                        markers:_markers,
                      myLocationEnabled: true,
                      zoomGesturesEnabled: true,
                      buildingsEnabled: true,
                        onMapCreated: (mapController) {
                          _controller.complete(mapController);
                        },
                      ),
                  ),
                ),
                // Positioned(
                //   top: 55,
                //   child: Container(
                //     alignment: Alignment.center,
                //     width: MediaQuery.of(context).size.width *.95,
                //     height: MediaQuery.of(context).size.height*.23,
                //     child: Column(
                //       children: [
                //         Padding(
                //           padding: const EdgeInsets.only(top: 10.0,left: 10),
                //           child: Row(
                //             children: [
                //               Text("Your Service Man Details",
                //                 style: TextStyle(
                //                   fontWeight: FontWeight.w700,
                //                   fontSize: 18,
                //                   color: Colors.black,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(top: 10.0,left: 20,right: 40),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               Text("Driver Name",
                //                 style: TextStyle(
                //                   fontWeight: FontWeight.w600,
                //                   fontSize: 14,
                //                   color: Colors.black,
                //                 ),
                //               ),
                //               Text(snapshot!.data()!["username"]??"",
                //                 style: TextStyle(
                //                   fontWeight: FontWeight.w400,
                //                   fontSize: 12,
                //                   color: Colors.black,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(top: 10.0,left: 20,right: 40),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               Text("Contact Details",
                //                 style: TextStyle(
                //                   fontWeight: FontWeight.w600,
                //                   fontSize: 14,
                //                   color: Colors.black,
                //                 ),
                //               ),
                //               Text("${snapshot!.data()!["countryCode"]}${snapshot!.data()!["phoneNumber"]}",
                //                 style: TextStyle(
                //                   fontWeight: FontWeight.w400,
                //                   fontSize: 12,
                //                   color: Colors.black,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //         // Padding(
                //         //   padding: const EdgeInsets.only(top: 10.0,left: 20,right: 40),
                //         //   child: Row(
                //         //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         //     children: [
                //         //       Text("Car Company Name",
                //         //         style: TextStyle(
                //         //           fontWeight: FontWeight.w600,
                //         //           fontSize: 14,
                //         //           color: ConstColors.backgroundColor,
                //         //         ),
                //         //       ),
                //         //       Text(widget.data["carCompany"],
                //         //         style: TextStyle(
                //         //           fontWeight: FontWeight.w400,
                //         //           fontSize: 12,
                //         //           color: ConstColors.backgroundColor,
                //         //         ),
                //         //       ),
                //         //     ],
                //         //   ),
                //         // ),
                //         // Padding(
                //         //   padding: const EdgeInsets.only(top: 10.0,left: 20,right: 40),
                //         //   child: Row(
                //         //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         //     children: [
                //         //       Text("Car Type",
                //         //         style: TextStyle(
                //         //           fontWeight: FontWeight.w600,
                //         //           fontSize: 14,
                //         //           color: ConstColors.backgroundColor,
                //         //         ),
                //         //       ),
                //         //       Text(widget.data["carType"],
                //         //         style: TextStyle(
                //         //           fontWeight: FontWeight.w400,
                //         //           fontSize: 12,
                //         //           color: ConstColors.backgroundColor,
                //         //         ),
                //         //       ),
                //         //     ],
                //         //   ),
                //         // ),
                //         // Padding(
                //         //   padding: const EdgeInsets.only(top: 10.0,left: 20,right: 40),
                //         //   child: Row(
                //         //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         //     children: [
                //         //       Text("Address",
                //         //         style: TextStyle(
                //         //           fontWeight: FontWeight.w600,
                //         //           fontSize: 14,
                //         //           color: ConstColors.backgroundColor,
                //         //         ),
                //         //       ),
                //         //       Text(widget.data["address"],
                //         //         style: TextStyle(
                //         //           fontWeight: FontWeight.w400,
                //         //           fontSize: 12,
                //         //           color: ConstColors.backgroundColor,
                //         //         ),
                //         //       ),
                //         //     ],
                //         //   ),
                //         // ),
                //         // Padding(
                //         //   padding: const EdgeInsets.only(top: 10.0,left: 20,right: 40),
                //         //   child: Row(
                //         //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         //     children: [
                //         //       Text("City",
                //         //         style: TextStyle(
                //         //           fontWeight: FontWeight.w600,
                //         //           fontSize: 14,
                //         //           color: ConstColors.backgroundColor,
                //         //         ),
                //         //       ),
                //         //       Text(widget.data["city"],
                //         //         style: TextStyle(
                //         //           fontWeight: FontWeight.w400,
                //         //           fontSize: 12,
                //         //           color: ConstColors.backgroundColor,
                //         //         ),
                //         //       ),
                //         //     ],
                //         //   ),
                //         // ),
                //         Padding(
                //           padding: const EdgeInsets.only(top: 10.0,left: 20,right: 40),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               Text("Date",
                //                 style: TextStyle(
                //                   fontWeight: FontWeight.w600,
                //                   fontSize: 14,
                //                   color:Colors.black,
                //                 ),
                //               ),
                //               Text(widget.data["requestDate"],
                //                 style: TextStyle(
                //                   fontWeight: FontWeight.w400,
                //                   fontSize: 12,
                //                   color: Colors.black,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(top: 10.0,left: 20,right: 40),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               Text("Time",
                //                 style: TextStyle(
                //                   fontWeight: FontWeight.w600,
                //                   fontSize: 14,
                //                   color: Colors.black,
                //                 ),
                //               ),
                //               Text(widget.data["time"],
                //                 style: TextStyle(
                //                   fontWeight: FontWeight.w400,
                //                   fontSize: 12,
                //                   color: Colors.black,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //     decoration: BoxDecoration(
                //       color: Colors.blue,
                //       borderRadius: BorderRadius.circular(14),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.black38,
                //           offset: Offset(0, 7),
                //           blurRadius: 20,),],
                //     ),
                //   ),
                // ),
                Container(
                  margin: EdgeInsets.all(4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: InkWell(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: Container(child: Center(child: Icon(CupertinoIcons.back,color: Colors.blue,)),height: 40,)),
                      ),
                      Spacer(),
                      Text(
                        "Live Tracking",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(flex: 2,),

                    ],
                  ),
                ),

                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: GestureDetector(
                //       onTap: ()async{
                //         if(widget.data["request_status"]=="is_coming") {
                //           await FirebaseFirestore.instance
                //               .collection("placeRequest")
                //               .doc(widget.data["docId"])
                //               .update({
                //             "request_status": "reached",
                //             "serviceManLat": currentLocation!.latitude,
                //             "serviceManLng": currentLocation!.longitude,
                //           });
                //           DocumentSnapshot<Map<String,dynamic>> snapshot;
                //
                //           snapshot = await FirebaseFirestore.instance.collection("placeRequest").doc(widget.data["docId"]).get();
                //           setState((){});
                //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LetsComplete(data: snapshot.data(),)));
                //         }
                //       },
                //       child: CustomLeadingContainer1(
                //           child: Container(
                //             height: 50,
                //             width: 250,
                //             child: Center(
                //               child: Container(
                //                 child: Text(
                //                   "Reached At Destination",
                //                   style: TextStyle(
                //                       fontSize: 18,
                //                       color: ConstColors.primaryColor,
                //                       fontWeight: FontWeight.w700),
                //                 ),
                //               ),
                //             ),
                //           ),
                //           height: 50,
                //           radius: 18),
                //     ),
                //   ),
                // ),

              ],
            ),
      ),
    );
  }
}
