import 'dart:async';

import 'package:edudrive/helpers/platform_keys.dart';
import 'package:edudrive/driver/models/instant_ride_request.dart';
import 'package:edudrive/driver/providers/mapkitAssedtent.dart';
import 'package:edudrive/res/font_assets/font_assets.dart';
import 'package:edudrive/driver/services/firestore_services.dart';
import 'package:edudrive/driver/widgets/collect_fare_dailog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../helpers/direction_helper.dart';
import '../helpers/http_exception.dart';
import '../helpers/pricing_helper.dart';
import '../main.dart';
import '../providers/maps_provider.dart';

class NewRideScreen extends StatefulWidget {
  final InstantRideRequest rideDetails;
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  NewRideScreen({Key? key, required this.rideDetails}) : super(key: key);

  @override
  State<NewRideScreen> createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();
  Position? currentPosition;
  Position? myPosition;

  Set<Marker> markersSet = Set<Marker>();
  Set<Circle> circlesSet = Set<Circle>();
  Set<Polyline> ployLineSet = Set<Polyline>();
  List<LatLng> polylineCorOrdinates =  [];
  PolylinePoints polylinePoints = PolylinePoints();
  GoogleMapController? newGoogleMapController;
  String status = "accepted";
  String? durationRide = "";
  bool isRequestingDirection = false;
  String btnTitle = "Arrived";
  Color btnColor = Colors.blueAccent;
  Timer? timer;
  int durationCounter = 0;

  var geolocator = Geolocator();
  BitmapDescriptor? animatingMarkerIcon;
  // var locationOption = LocationO
  double mapPaddingFromBottom = 0.0;
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
  LatLng? sourse ;
  LatLng? destination ;
  StreamSubscription<Position>? rideStreamSubscription;
  void getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    // if (!hasPermission) return;
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState((){
        currentPosition = position;
        destination = LatLng(
    widget.rideDetails.dropoff!.latitude!,
    widget.rideDetails.dropoff!.longitude!,
    );
    sourse = LatLng(
      widget.rideDetails.pickup!.latitude!,
      widget.rideDetails.pickup!.longitude!,
    );
  });
    if (mounted) setState((){});



    GoogleMapController googleMapController = await _controller.future;


    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            zoom: 15.5,
            target: LatLng(currentPosition!.latitude!, currentPosition!.longitude!))));
    setState(() {});

    await  getPlaceDirections(LatLng(currentPosition!.latitude!, currentPosition!.longitude!), sourse!);
    await acceptRideRequestId();
      // await Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid!);

    // getPlaceDirections();
    // });

  }
  void createIcon(){
    if(animatingMarkerIcon==null){
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
        size: Size(2, 2),
      );
          BitmapDescriptor.fromAssetImage(
            imageConfiguration,
    'assets/images/car_ios.png',
    ).then((value) {
      animatingMarkerIcon = value;
          });
    }

  }
  void getRideLiveLocationUpdate()async{
    LatLng oldPos = LatLng(0, 0);
    rideStreamSubscription = Geolocator.getPositionStream().listen((Position position) async{
      currentPosition = position;
      myPosition = position;
      LatLng myLatlng =LatLng(position.latitude, position.longitude);
      var rot = MapKitAssestent.getMarkerRotation(oldPos.latitude, oldPos.longitude, myPosition!.latitude!, myPosition!.longitude);
     Marker animatedMaker = Marker(markerId: MarkerId("animated"),
         position: myLatlng,icon: animatingMarkerIcon!,
         rotation: rot,
         infoWindow: InfoWindow(title: "Current Location"));
     setState(() {
       CameraPosition newCameraPosition =new CameraPosition(target: myLatlng,zoom: 17);
       newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
       markersSet.removeWhere((marker)=>marker.markerId.value=="animated");
       markersSet.add(animatedMaker);
     });
     oldPos = myLatlng;
      updateRideDetails();
      String rideRequestId = widget.rideDetails.id!;

      Map locMap = {
        "lat":currentPosition!.latitude,
        "lng":currentPosition!.longitude
      };
      await  rideRequestRef.doc(rideRequestId).update(
          {
            "driver_location":locMap,
          }
      );
    });

  }
  @override
  void initState() {
    // TODO: implement initState
    getCurrentLocation();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    createIcon();
    return Scaffold(
      appBar: AppBar(
        title: Text("New Ride"),
      ),
      body: Container(
        child: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: mapPaddingFromBottom),
              mapType: MapType.normal,
              myLocationButtonEnabled:true ,
              myLocationEnabled: true,
              markers: markersSet,
              circles: circlesSet,
              polylines: ployLineSet,

              initialCameraPosition: NewRideScreen._kGooglePlex,
              onMapCreated: (GoogleMapController controller)async {
                _controller.complete(controller);
                newGoogleMapController = controller;
                setState(() {
                  mapPaddingFromBottom= 265.0;
                });
                print("----");
                Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );
                currentPosition = position;

                // var currentLatLng=   LatLng(currentPosition!.latitude,currentPosition!.longitude);
             //    print("----=");
             //
             //    var pickUpLatLng = LatLng(widget.rideDetails.pickup!.latitude!,widget.rideDetails.pickup!.longitude!);
                print("----==");
                await  getPlaceDirections(LatLng(currentPosition!.latitude!, currentPosition!.longitude!), sourse!);

                getRideLiveLocationUpdate();
                // await  getPlaceDirections(currentLatLng, pickUpLatLng);
                // locatePosition();
              },
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0 ,
              child: Container(
                height: 260.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(16.0),topLeft: Radius.circular(16.0),),
                  boxShadow: [
                    BoxShadow(color: Colors.black38,
                    blurRadius: 16.0,spreadRadius: 0.5,
                    offset: Offset(0.7,0.7),),

                  ]
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Estimated Time Required: $durationRide",style: FontAssets.mediumText.copyWith(color: Colors.black),),
                    ),
                    // SizedBox(height: 10,),
                    ListTile(

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: Theme.of(context).primaryColorDark.withOpacity(0.6),
                      // contentPadding: const EdgeInsets.symmetric(
                      //   vertical: 8,
                      //   horizontal: 16,
                      // ),
                      leading: Image.asset('assets/images/user_icon.png'),
                      title: Text(
                        "${widget.rideDetails.parentName}",
                        style: FontAssets.largeText.copyWith(color: Colors.black),
                      ),
                      subtitle: Text(
                        "${widget.rideDetails.parentPhone}",
                        style: FontAssets.smallText.copyWith(color: Colors.black),
                      ),

                    ),
                    ListTile(dense: true,leading: Icon(Icons.pin_drop_outlined),title: Text("${widget.rideDetails.pickupAddress}",style: FontAssets.smallText.copyWith(color: Colors.black),),
                      ),
                    ListTile(dense:true,leading: Icon(Icons.pin_drop_outlined),title:Text("${widget.rideDetails.dropoffAddress}",style: FontAssets.smallText.copyWith(color: Colors.black),)),
                    ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(btnColor),

                        ),
                        onPressed: ()async{
                          String rideRequestId = widget.rideDetails.id!;

                          if(status=="accepted"){
                            setState(() {
                              status = "arrived";
                            });
                            await  rideRequestRef.doc(rideRequestId).update(
                                {
                                  "request_status":status,
                                });
                            setState(() {
                              btnTitle = "Start Trip";
                              btnColor = Colors.purple;
                            });
                            await getPlaceDirections(LatLng(widget.rideDetails.pickup!.latitude!, widget.rideDetails.pickup!.longitude!),
                                LatLng(widget.rideDetails.dropoff!.latitude!, widget.rideDetails.dropoff!.longitude!));
                          }
                          else if(status=="arrived"){
                            setState(() {
                              status = "onride";
                            });
                            await  rideRequestRef.doc(rideRequestId).update(
                                {
                                  "request_status":status,
                                });
                            setState(() {
                              btnTitle = "End Trip";
                              btnColor = Colors.redAccent;
                            });
                            initTimer();
                            // await getPlaceDirections(LatLng(widget.rideDetails.pickup!.latitude!, widget.rideDetails.pickup!.longitude!),
                            //     LatLng(widget.rideDetails.dropoff!.latitude!, widget.rideDetails.dropoff!.longitude!));
                          }
                          else if(status=="onride") {
                            endTheTrip();

                          }
                          }, child: Text("$btnTitle"))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  getPlaceDirections(LatLng pickupLatLng,LatLng dropoffLatLng) async {
    // try {
      // final user = Provider.of<UserProvider>(context, listen: false);
      // final initialPosition = user.pickupLocation!;
      // final finalPosition = user.dropOffLocation!;
      //
      // final pickupLatLng = LatLng(
      //   widget.data["pickup"]["lat"],widget.data["pickup"]["lng"],
      // );
      // final dropoffLatLng = LatLng(
      //   widget.data["dropoff"]["latitude"],widget.data["dropoff"]["longitude"],
      // );
    print("----1");
      showDialog(context: context, builder: (BuildContext context)=>AlertDialog(backgroundColor: Colors.white,content: Text("Please Wait"),));

      final details = await DirectionHelper.obtainPlaceDirectionDetails(
        pickupLatLng,
        dropoffLatLng,
      );

      final polylinePoints = PolylinePoints();
      List<PointLatLng> decodedPolylinePointsResult =
      polylinePoints.decodePolyline(details.encodedPoints!);

      polylineCorOrdinates.clear();
      if (decodedPolylinePointsResult.isNotEmpty) {
        decodedPolylinePointsResult.forEach((PointLatLng point) {
          polylineCorOrdinates.add(LatLng(point.latitude, point.longitude));
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
       newGoogleMapController = await _controller.future;

      newGoogleMapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          screenBounds,
          70,
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
          title: widget.rideDetails.dropoffAddress,
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

      Navigator.pop(context);
      ployLineSet.clear();
      setState(() {
        // tripDetails = details;
        final polyline = Polyline(
          color: Theme.of(context).colorScheme.secondary,
          polylineId: PolylineId('Place Directions'),
          jointType: JointType.round,
          points: polylineCorOrdinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );
        ployLineSet.add(polyline);
        markersSet.add(pickupMarker);
        markersSet.add(dropoffMarker);
        circlesSet.add(pickupCircle);
        circlesSet.add(dropoffCircle);
      });
    // } on HttpException catch (error) {
    //   var errorMessage = 'Request Failed';
    //   print(error);
    //   // _snackbar(errorMessage);
    // } catch (error) {
    //   const errorMessage = 'Could not get directions. Please try again later.';
    //   print(error);
    //   // _snackbar(errorMessage);
    // }
  }
   acceptRideRequestId()async{
    String rideRequestId = widget.rideDetails.id!;

    await FirestoreServices().getDriver(FirebaseAuth.instance.currentUser!.uid).then((value)async {
      Map locMap = {
        "lat":currentPosition!.latitude,
        "lng":currentPosition!.longitude
      };
      var directionDetails = await DirectionHelper.obtainPlaceDirectionDetails(
          LatLng(widget.rideDetails.pickup!.latitude!,widget.rideDetails.pickup!.longitude!),
          LatLng(widget.rideDetails.dropoff!.latitude!,widget.rideDetails.dropoff!.longitude! ));

      double fareAmount =  PricingHelper.calculateFares(directionDetails.durationValue ?? 0, directionDetails.distanceValue ?? 0);

      String rideRequestId = widget.rideDetails.id!;
     await  rideRequestRef.doc(rideRequestId).update(
         {
           "request_status":"accepted",
           "driver_id":value.data()!["uid"],
           "driver_name":value.data()!["name"],
           "driver_phone":value.data()!["mobile"],
           "driver_email":value.data()!["email"],
           "driver_location":locMap,
           "fares":fareAmount.toString(),

         }
     );


     });

  }

  updateRideDetails()async{
    if(isRequestingDirection ==false){
      setState(() {
        isRequestingDirection = true;
      });
      if(myPosition==null){
        return ;
      }
      var posLateLng = LatLng(myPosition!.latitude,myPosition!.longitude);
      LatLng destinationLatLng;
      if(status == "accepted"){
        destinationLatLng = LatLng(widget.rideDetails.pickup!.latitude!, widget.rideDetails.pickup!.longitude!);
      }
      else{
        destinationLatLng = LatLng(widget.rideDetails.dropoff!.latitude!, widget.rideDetails.dropoff!.longitude!);

      }
      var directionDetails = await DirectionHelper.obtainPlaceDirectionDetails(posLateLng, destinationLatLng);
      if(directionDetails !=null){
        setState(() {
          durationRide= directionDetails.durationText;
        });
      }
      setState(() {
        isRequestingDirection = false;
      });

    }

  }
  initTimer(){
    const  interval= Duration(seconds: 1);
    timer = Timer.periodic( interval, (timer) {
      durationCounter = durationCounter+1;
    });
  }
  endTheTrip()async{
    timer!.cancel();
    showDialog(context: context, builder: (BuildContext context)=>
        AlertDialog(backgroundColor: Colors.white,content: Text("Please Wait"),));
    var currentLatLng = LatLng(myPosition!.latitude, myPosition!.longitude);
    var directionDetails = await DirectionHelper.obtainPlaceDirectionDetails(
        LatLng(widget.rideDetails.pickup!.latitude!,widget.rideDetails.pickup!.longitude!),
        LatLng(widget.rideDetails.dropoff!.latitude!,widget.rideDetails.dropoff!.longitude! ));
    Navigator.pop(context);
    double fareAmount =  PricingHelper.calculateFares(directionDetails.durationValue ?? 0, directionDetails.distanceValue ?? 0);

    String rideRequestId = widget.rideDetails.id!;
    await  rideRequestRef.doc(rideRequestId).update(
        {
          "request_status":"ended",
          "fares":fareAmount.toString(),
        });
    rideStreamSubscription!.cancel();
    showDialog(context: context, builder: (BuildContext context)=>
        CollectFareDailog(fareAmount:fareAmount ,paymentMethod: widget.rideDetails.paymentMethod!,));

    saveEarning(fareAmount);
  }

  saveEarning(double fareAmount){
    driverRef.get().then((value)async{
      if(value!=null){
        double oldEarning = double.parse(value.data()!["wallet"].toString());
        double totalEarning = fareAmount + oldEarning;
        await FirestoreServices().updateDriver(FirebaseAuth.instance.currentUser!.uid, {"wallet":totalEarning});
      }
    });
  }
}
