import 'dart:async';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edudrive/helpers/http_exception.dart';
import 'package:edudrive/driver/res/app_color/app_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../helpers/direction_helper.dart';
import '../helpers/platform_keys.dart';
import '../services/fcmServices/firebase_messaging.dart';
import '../../driver/services/firestore_services.dart';

class OrderTrackingPage extends StatefulWidget {
  LatLng driverLatLng;
  Map<String,dynamic> data;
  bool isJustAccepted;
   OrderTrackingPage({Key? key,required this.data,this.isJustAccepted =false,required this.driverLatLng}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
   LatLng? sourse ;
  LatLng? destination ;
  List<LatLng> polylineCoordinates = [];
  Position? currentLocation;
  bool isLoading = false;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  Future<bool> _handleLocationPermission() async {
    bool? serviceEnabled;
    LocationPermission? permission;

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
    setState(() {
      isLoading =true;
    });
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    // if(widget.isJustAccepted){
    //   sourse = LatLng(
    //     widget.driverLatLng.latitude,widget.driverLatLng.longitude, );
    //   destination = LatLng(
    //     widget.data["pickup"]["latitude"],widget.data["pickup"]["longitude"], );
    //   if (mounted) setState((){});
    //
    // }
    // else{
    //   sourse = LatLng(
    //     widget.data["pickup"]["latitude"],widget.data["pickup"]["longitude"], );
    //   destination = LatLng(
    //     widget.data["dropoff"]["latitude"],widget.data["dropoff"]["longitude"], );
    //   if (mounted) setState((){});
    //
    // }
    //
    //

    Position position = await Geolocator.getCurrentPosition(
      forceAndroidLocationManager: true,
      desiredAccuracy: LocationAccuracy.high,
    );
    currentLocation = position;
    print(position.latitude);
    setState(() {
      isLoading =false;
    });


    if (mounted) setState((){});
    // await  location.getLocation().then((location) => {
    //   currentLocation = location,
    //   if (mounted) setState((){})
    // });

    setState(() {
      isLoading =false;
    });

    getPlaceDirections();

    GoogleMapController googleMapController = await _controller.future;



    // location.onLocationChanged.listen((newLoc) {
    //     currentLocation = newLoc;
    //     if (mounted) setState((){});
    //   googleMapController.animateCamera(CameraUpdate.newCameraPosition(
    //       CameraPosition(
    //           zoom: 16.5,
    //           target: LatLng(newLoc.latitude!, newLoc.longitude!))));
    //   setState(() {});
    // });

    // location.getLocation().then((location) => {currentLocation = location});

    // location.onLocationChanged.listen((newLoc) {
    //   currentLocation = newLoc;
    //
    //   if (mounted) setState(() {});
    // });
  }

  // void getPolyPoints() async {
  //   PolylinePoints polylinePoints = PolylinePoints();
  //
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //       mapsAPI,
  //       PointLatLng(
  //         widget.driverLatLng.latitude,widget.driverLatLng.longitude, ),
  //       PointLatLng(widget.data["pickup"]["latitude"],widget.data["pickup"]["longitude"],),
  //   travelMode: TravelMode.driving);
  //
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach((PointLatLng point) =>
  //         polylineCoordinates.add(LatLng(point.latitude, point.longitude)));
  //     setState(() {});
  //   }
  // }
  // double _originLatitude = 26.48424, _originLongitude = 50.04551;
  // double _destLatitude = 26.46423, _destLongitude = 50.06358;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates1 = [];
  Set<Circle> circles = {};
  Set<Polyline> polylineSet = {};
  PolylinePoints polylinePoints = PolylinePoints();
  void setCustomMarkerIcon(){
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/images/pinIcon.png").then((icon){
      sourceIcon = icon;
      destinationIcon = icon;
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/images/carIcon.png").then((icon){
      currentLocationIcon = icon;
    });
  }

  Set<Marker> _markers = {};
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController mapController;

  googleMapSetting(){
    // markers: {
// Marker(
// icon: currentLocationIcon,
// markerId: MarkerId("currentLocation"),
// position: LatLng(
// currentLocation!.latitude!, currentLocation!.longitude!),
// ),
// Marker(
// icon: sourceIcon,
// markerId: MarkerId("source"),
// position: sourse!,
// ),
// Marker(
// icon: destinationIcon,
// markerId: MarkerId("destination"),
// position: destination!,
// ),
// },
//     _markers.add(
//         Marker(
//           // icon: ,
//           markerId: MarkerId("id-1"),
//           position: LatLng(widget.lat!, widget.lng!),
//
//         )
//     );
  }
  @override
  void initState() {
    // TODO: implement initState
    getCurrentLocation();
    // getServiceManData();

      // getPolyPoints();
    /// origin marker


    // _addMarker(LatLng(widget.data["pickup"]["latitude"], widget.data["pickup"]["longitude"]), "origin",
    //     BitmapDescriptor.defaultMarker);
    //
    // /// destination marker
    // _addMarker(LatLng(widget.data["dropoff"]["latitude"], widget.data["dropoff"]["longitude"]), "destination",
    //     BitmapDescriptor.defaultMarkerWithHue(90));
    // _getPolyline();

    setCustomMarkerIcon();

    super.initState();
  }
  // DocumentSnapshot<Map<String,dynamic>>? snapshot;
  //
  // getServiceManData()async{
  //   snapshot = await FirebaseFirestore.instance.collection("blanguser").doc(widget.data["userUid"]).get();
  //   setState((){});
  // }
  List<LatLng> plineCoordinates = [];

  // void _onMapCreated(GoogleMapController controller) async {
  //   mapController = controller;
  // }
  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    mapController = controller;
    setState(() {

    });
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
    Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        mapsAPI,
        PointLatLng(widget.data["pickup"]["latitude"], widget.data["pickup"]["longitude"]),
        PointLatLng(widget.data["dropoff"]["latitude"], widget.data["dropoff"]["longitude"]),
        travelMode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  Future<void> getPlaceDirections() async {
    try {
      // final user = Provider.of<UserProvider>(context, listen: false);
      // final initialPosition = user.pickupLocation!;
      // final finalPosition = user.dropOffLocation!;

      final pickupLatLng = LatLng(
        widget.data["pickup"]["latitude"], widget.data["pickup"]["longitude"],
      );
      final dropoffLatLng = LatLng(
          widget.data["dropoff"]["latitude"], widget.data["dropoff"]["longitude"]
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

      // mapController.animateCamera(
      //   CameraUpdate.newLatLngBounds(
      //     screenBounds,
      //     120,
      //   ),
      // );

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:
       Scaffold(
      // child: widget.data["request_status"]=="GPS"? Scaffold(

        body:
        // isLoading
        //     ? const Center(child: Text("Loaction")):
        Stack(
          children: [

            Container(
              height: MediaQuery.of(context).size.height ,
              child: GoogleMap(
                  padding: EdgeInsets.only(top: 40.0,),

                  rotateGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  mapToolbarEnabled: true,
                  // polylines: ,
                  markers: _markers,
                  polylines: polylineSet,
                  circles: circles,

                  // markers: {
                  // // Marker(
                  // // icon: currentLocationIcon,
                  // // markerId: MarkerId("currentLocation"),
                  // // position: LatLng(
                  // // currentLocation!.latitude!, currentLocation!.longitude!),
                  // // ),
                  // // Marker(
                  // // icon: sourceIcon,
                  // // markerId: MarkerId("source"),
                  // // position: sourse!,
                  // // ),
                  // // Marker(
                  // // icon: destinationIcon,
                  // // markerId: MarkerId("destination"),
                  // // position: destination!,
                  // // ),
                  // },
                  mapType: MapType.normal,
                  myLocationButtonEnabled: true,
                  tiltGesturesEnabled: false,
                  minMaxZoomPreference: MinMaxZoomPreference(13,17),
                  initialCameraPosition:CameraPosition(
                    target:  LatLng(widget.driverLatLng.latitude, widget.driverLatLng.longitude),
                    zoom:  15.6,
                  ),
                  myLocationEnabled: true,
                  // circles: circles,
                  zoomGesturesEnabled: true,

                  zoomControlsEnabled: true,
                  onMapCreated: _onMapCreated
              ),
            ),
            Positioned(
                bottom: 55,
                left: 10,right: 10,
                child: Container(

                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width ,
                  height: MediaQuery.of(context).size.height*.32,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0,left: 10),
                        child: Row(
                          children: [
                            Text("Ride Detail",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                // color: ConstColors.backgroundColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      ListTile(
                        title: Text("PickUp Address",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColor.whiteColor,
                          ),
                        ),subtitle:  Text("${widget.data["pickup"]}",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: AppColor.whiteColor,
                        ),
                      ),
                      ),
                      ListTile(
                        title: Text("DropOff Address",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColor.whiteColor,
                          ),
                        ),subtitle:  Text("${widget.data["pickup"]}",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: AppColor.whiteColor,
                        ),
                      ),
                      ),

                      // Padding(
                      //   padding: const EdgeInsets.only(top: 10.0,left: 20,right: 40),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //
                      //
                      //     ],
                      //   ),
                      // ),
                      ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                          onPressed: ()async{

                            await FirebaseFirestore.instance.collection("rideRequest").doc(widget.data["id"]).update(
                                {"request_status": "onJurney",}).then((value) async{
                              var parentData=  await FirestoreServices().getParent(widget.data!["parentId"]);
                              await FirestoreServices().updateDriver(FirebaseAuth.instance.currentUser!.uid,
                                  {"instantBooking":"onJurney",});

                              await PushNotificationServices.sendNotification(title: "Schedule Booking",body: "New Schedule Booking Request received",type: 0,request_id: widget.data["id"],token: parentData["fcmToken"]);

                              await FirestoreServices().addNotification(type: 0,text: "Accept a request",uid: FirebaseAuth.instance.currentUser!.uid);
                              await FirestoreServices().addNotification(type: 0,text: "Your request Accept, now pay payment to active",uid: widget.data!["parentId"]);

                              Map<String,dynamic> data = widget.data;
                              data.update("request_status", (value) => "onJurney");
                              setState(() {

                              });
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>OrderTrackingPage(driverLatLng: LatLng(
                                  currentLocation!.latitude!, currentLocation!.longitude!),isJustAccepted: false,data: data,)));
                            });


                          }, child: Text("Reached Pickup Location Start Jurney")),

                    ],
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        offset: Offset(0, 7),
                        blurRadius: 20,),],
                  ),
                )
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: GestureDetector(
                onTap: (){
                  // MapUtils.openMap(widget.lat!, widget.lng!);

                },
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.fromLTRB(20, 8,20,8),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Text('Open in Google Map',),
                ),
              ),
            )
          ],
        )

            // : Stack(
            //   children: [
            //     Align(
            //       alignment: Alignment.bottomCenter,
            //       child: Container(
            //         height: MediaQuery.of(context).size.height * 0.6,
            //         child: GoogleMap(
            //             initialCameraPosition: CameraPosition(
            //                 target: LatLng(
            //                     currentLocation!.latitude!, currentLocation!.longitude!),
            //                 zoom: 14.5),
            //
            //             onMapCreated: (mapController) {
            //               _controller.complete(mapController);
            //             },
            //           ),
            //       ),
            //     ),
            //     Positioned(
            //       top: 55,
            //       child: Container(
            //         alignment: Alignment.center,
            //         width: MediaQuery.of(context).size.width *.95,
            //         height: MediaQuery.of(context).size.height*.32,
            //         child: Column(
            //           children: [
            //             Padding(
            //               padding: const EdgeInsets.only(top: 10.0,left: 10),
            //               child: Row(
            //                 children: [
            //                   Text("Ride Detail",
            //                     style: TextStyle(
            //                       fontWeight: FontWeight.w700,
            //                       fontSize: 18,
            //                       // color: ConstColors.backgroundColor,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //
            //             Padding(
            //               padding: const EdgeInsets.only(top: 10.0,left: 20,right: 40),
            //               child: Row(
            //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                 children: [
            //                   Text("PickUp Address",
            //                     style: TextStyle(
            //                       fontWeight: FontWeight.w600,
            //                       fontSize: 16,
            //                       color: AppColor.whiteColor,
            //                     ),
            //                   ),
            //                   Text("${widget.data["pickup"]["pickup_address"]}",
            //                     style: TextStyle(
            //                       fontWeight: FontWeight.w400,
            //                       fontSize: 12,
            //                       color: AppColor.whiteColor,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //             ElevatedButton(
            //                 style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
            //                 onPressed: ()async{
            //
            //                   await FirebaseFirestore.instance.collection("rideRequest").doc(widget.data["id"]).update(
            //                       {"request_status": "onJurney",}).then((value) async{
            //                     var parentData=  await FirestoreServices().getParent(widget.data!["parentId"]);
            //                     await FirestoreServices().updateDriver(FirebaseAuth.instance.currentUser!.uid,
            //                         {"instantBooking":"onJurney",});
            //
            //                     await PushNotificationServices.sendNotification(title: "Schedule Booking",body: "New Schedule Booking Request received",type: 0,request_id: widget.data["id"],token: parentData["fcmToken"]);
            //
            //                     await FirestoreServices().addNotification(type: 0,text: "Accept a request",uid: FirebaseAuth.instance.currentUser!.uid);
            //                     await FirestoreServices().addNotification(type: 0,text: "Your request Accept, now pay payment to active",uid: widget.data!["parentId"]);
            //
            //                     Map<String,dynamic> data = widget.data;
            //                     data.update("request_status", (value) => "onJurney");
            //                     setState(() {
            //
            //                     });
            //                     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>OrderTrackingPage(driverLatLng: LatLng(
            //                         currentLocation!.latitude!, currentLocation!.longitude!),isJustAccepted: false,data: data,)));
            //                   });
            //
            //
            //                 }, child: Text("Reached Pickup Location Start Jurney")),
            //
            //           ],
            //         ),
            //         decoration: BoxDecoration(
            //           color: AppColor.primaryColor,
            //           borderRadius: BorderRadius.circular(14),
            //           boxShadow: [
            //             BoxShadow(
            //               color: Colors.black38,
            //               offset: Offset(0, 7),
            //               blurRadius: 20,),],
            //         ),
            //       )
            //     ),
                // Container(
                //   margin: EdgeInsets.all(4),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Container(
                //         child: InkWell(
                //             onTap: (){
                //               Navigator.pop(context);
                //             },
                //             child: CustomNotificationContainer(child: Center(child: Icon(CupertinoIcons.back,color: ConstColors.primaryColor,).paddingAll(3)),height: 40,).paddingAll(2)),
                //       ).paddingAll(4),
                //       Spacer(),
                //       Text(
                //         "Booking Confirmation",
                //         style: TextStyle(
                //           color: ConstColors.primaryColor,
                //           fontSize: 26,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       Spacer(flex: 2,),
                //
                //     ],
                //   ),
                // ),
                //
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: GestureDetector(
                //       onTap: ()async{
                //         if(widget.data["request_status"]=="Confirmed") {
                //           setState((){
                //             isLoading = true;
                //           });
                //           var settingData = await FirebaseFirestore.instance.collection("setting").doc("setting").get();
                //           var serviceManData = await FirebaseFirestore.instance.collection("blang_service_users").doc(FirebaseAuth.instance.currentUser!.uid).get();
                //           // int totalOrders = settingData.data()!["totalOrders"] + 1;
                //           await FirebaseFirestore.instance
                //               .collection("placeRequest")
                //               .doc(widget.data["docId"])
                //               .get().then((value)async {
                //             if(value.data()!["request_status"]=="Completed"){
                //
                //             }else{
                //               await FirebaseFirestore.instance.collection("setting").doc("setting").update(
                //                   {
                //                     "totalOrders":settingData.data()!["totalOrders"] + 1
                //                   });
                //               await FirebaseFirestore.instance.collection("blang_service_users").doc(FirebaseAuth.instance.currentUser!.uid).update(
                //                   {
                //                     "orders_done":serviceManData.data()!["orders_done"] + 1
                //                   });
                //             }
                //
                //           });
                //
                //           await FirebaseFirestore.instance
                //               .collection("placeRequest")
                //               .doc(widget.data["docId"])
                //               .update({
                //             "request_status": "Completed",
                //             "serviceManLat": currentLocation!.latitude,
                //             "serviceManLng": currentLocation!.longitude,
                //           });
                //
                //           await FirebaseFirestore.instance.collection("appNotification").doc().set(
                //               {
                //                 "title":"Your Order has been Completed",
                //                 "des":"Your Order Has been Completed, thanks for using our service.",
                //                 "date":DateTime.now(),
                //                 "userUid":widget.data["userUid"],
                //               });
                //           await FirebaseFirestore.instance.collection("appNotification").doc().set(
                //               {
                //                 "title":"Order has been Completed",
                //                 "des":"Your Order Has been Completed, thanks for using our service.",
                //                 "date":DateTime.now(),
                //
                //                 "userUid":FirebaseAuth.instance.currentUser!.uid,
                //               });
                //           var userData = await FirebaseFirestore.instance.collection("blanguser").doc(widget.data["userUid"]).get();
                //           setState((){
                //             isLoading = false;
                //           });
                //           var sendSms =   await DatabaseServices().send("A Order Completed", 'A Order Completed of User ${userData.data()!["email"]} , ${userData.data()!["email"]} Order Server Date ${widget.data["requestDate"]} ,\n'
                //               ' and Selected Time is  ${widget.data["time"]} by a service man ', "jackblang.se@gmail.com");
                //           var sendSms1 =   await DatabaseServices().send("Order Completed", "Your Order has been Completed, remember us for your next service", userData.data()!["email"]);
                //
                //
                //           snapshot = await FirebaseFirestore.instance.collection("placeRequest").doc(widget.data["docId"]).get();
                //
                //
                //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                //
                //
                //         }
                //       },
                //       child: CustomLeadingContainer1(
                //           child: Container(
                //             height: 50,
                //             width: 250,
                //             child: Center(
                //               child: Container(
                //                 child: !isLoading? LocaleText(
                //                   "complete",
                //                   style: TextStyle(
                //                       fontSize: 18,
                //                       color: ConstColors.primaryColor,
                //                       fontWeight: FontWeight.w700),
                //                 ):CircularProgressIndicator(),
                //               ),
                //             ),
                //           ),
                //           height: 50,
                //           radius: 18),
                //     ),
                //   ),
                // ),

              // ],
            // ),
      )
    );
  }
}
//
// polylines: {
// Polyline(
// polylineId: PolylineId("route"),
// points: polylineCoordinates,
// color: AppColor.primaryColor,
// width: 6)
// },
// markers: {
// Marker(
// icon: currentLocationIcon,
// markerId: MarkerId("currentLocation"),
// position: LatLng(
// currentLocation!.latitude!, currentLocation!.longitude!),
// ),
// Marker(
// icon: sourceIcon,
// markerId: MarkerId("source"),
// position: sourse!,
// ),
// Marker(
// icon: destinationIcon,
// markerId: MarkerId("destination"),
// position: destination!,
// ),
// },