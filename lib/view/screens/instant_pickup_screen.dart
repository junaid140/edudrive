import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edudrive/res/app_color/app_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Assistents/geoFireAssistant.dart';
import '../../helpers/platform_keys.dart';
import '../../main.dart';
import '../../models/near_by_available_drivers.dart';
import '../../providers/ride_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/maps_provider.dart';
import '../../helpers/pricing_helper.dart';
import '../../helpers/http_exception.dart';
import '../../helpers/direction_helper.dart';
import '../../models/address.dart';
import '../../models/direction_details.dart';
import '../../res/font_assets/font_assets.dart';
import '../../services/fcmServices/firebase_messaging.dart';
import '../../utils/utils.dart';
import '../base/noDriverAvailableDailog.dart';
import '../widgets/collect_fare_dailog.dart';
import '../widgets/request_complete_dailog.dart';
import '../widgets/search_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/add_new_address.dart';
import '../widgets/decorated_wrapper.dart';
import '../widgets/address_list_by_type.dart';
import '../widgets/floating_appbar_wrapper_with_textfield.dart';
import 'search_screen.dart';

class InstantPickUpScreen extends StatefulWidget {
  const InstantPickUpScreen({Key? key}) : super(key: key);

  static const routeName = '/instant_pickup_screen';

  @override
  _InstantPickUpScreenState createState() => _InstantPickUpScreenState();
}

class _InstantPickUpScreenState extends State<InstantPickUpScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController newMapController;
  final _currentLocationInputController = TextEditingController();
  DirectionDetails tripDetails = DirectionDetails();
  Position? currentPosition;
  List<LatLng> plineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  bool _loading = false;
  bool driversLoaded = false;
  int _state = 1;
  String statusRide="";
  String driverName="";
  String driverPhone="";
  String rideStatus="Driver is Coming";

  StreamSubscription? rideStreamSubscription ;
  bool isRequestingPositionDetails = false ;

  void _snackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: FontAssets.mediumText,
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
        backgroundColor: AppColor.redColor,
      ),
    );
  }

  Future<bool> _checkDialog() async => await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text('Are you sure?'),
          content: Text(
            'Do you want to delete this address?',
          ),
          actions: [
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () {
                Navigator.of(ctx).pop(false);
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () {
                Navigator.of(ctx).pop(true);
              },
            ),
          ],
        ),
      );

  Future<void> updateAvailableDriversOnMap() async {
    if(mounted)setState(() {
      markers.clear();
    });
    final tMarkers = await Provider.of<MapsProvider>(
      context,
      listen: false,
    ).getAvailableDriverMarkers(
      createLocalImageConfiguration(
        context,
        size: Size(2, 2),
      ),
    );
    setState(() {
      markers = tMarkers;
    });
  }

  Future<void> locateOnMap() async {
    try {
      print("---");
      final mapProvider = Provider.of<MapsProvider>(context, listen: false);
      print("---1");
      await mapProvider.locatePosition(
        newMapController,
        _currentLocationInputController,
      );
      print("---2");
       currentPosition = mapProvider.currentPosition;
       setState(() {

       });
      print("---3");
      Address pickupAddress = Address(
        longitude: currentPosition!.longitude,
        latitude: currentPosition!.latitude,
        address: _currentLocationInputController.text,
      );
      print("---4");
      print("====="+pickupAddress.address!);
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).updatePickUpLocationAddress(pickupAddress);
      await mapProvider.initGeofire(updateAvailableDriversOnMap, driversLoaded);
    } on HttpException catch (error) {
      var errorMessage = 'Request Failed';
      print(error);
      _snackbar(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not locate you. Please try again later.';
      print(error);
      _snackbar(errorMessage);
    }
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    newMapController = controller;
    await locateOnMap();
  }

  void onLocationInput(String value) async {
    try {
      final mapProvider = Provider.of<MapsProvider>(context, listen: false);
      await mapProvider.getLatLng(value, newMapController);
      final geocodedAddress = mapProvider.geocodedAddress;
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).updateDropOffLocationAddress(geocodedAddress);
    } on HttpException catch (error) {
      var errorMessage = 'Request Failed';
      print(error);
      _snackbar(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not locate address. Please try again later.';
      print(error);
      _snackbar(errorMessage);
    }
  }



  Future<void> getPlaceDirections() async {
    try {
      final user = Provider.of<UserProvider>(context, listen: false);
      final initialPosition = user.pickupLocation!;
      final finalPosition = user.dropOffLocation!;

      final pickupLatLng = LatLng(
        initialPosition.latitude!,
        initialPosition.longitude!,
      );
      final dropoffLatLng = LatLng(
        finalPosition.latitude!,
        finalPosition.longitude!,
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

      newMapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          screenBounds,
          120,
        ),
      );

      Marker pickupMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: initialPosition.name,
          snippet: 'My Location',
        ),
        position: pickupLatLng,
        markerId: MarkerId('Pick Up'),
      );

      Marker dropoffMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: finalPosition.name,
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
        tripDetails = details;
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
        markers.add(pickupMarker);
        markers.add(dropoffMarker);
        circles.add(pickupCircle);
        circles.add(dropoffCircle);
      });
    } on HttpException catch (error) {
      var errorMessage = 'Request Failed';
      print(error);
      _snackbar(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not get directions. Please try again later.';
      print(error);
      _snackbar(errorMessage);
    }
  }

  Future<void> obtainDirection(dynamic value) async {
    if (value == 'obtainDirection') {
      setState(() {
        _loading = true;
      });
      await getPlaceDirections();
      setState(() {
        _loading = false;
        _state = 2;
      });
    }
  }

  Future<void> _resetApp() async {
    setState(() {
      _loading = true;
    });
    if (_state == 3) {
      try {
        await Provider.of<RideProvider>(
          context,
          listen: false,
        ).cancelRideRequest();
      } on HttpException catch (error) {
        var errorMessage = 'Request Failed';
        print(error);
        _snackbar(errorMessage);
      } catch (error) {
        const errorMessage = 'Could not cancel request.';
        print(error);
        _snackbar(errorMessage);
      }
    }
    Provider.of<UserProvider>(context, listen: false).clearLocation();
    setState(() {
      polylineSet.clear();
      markers.clear();
      circles.clear();
      plineCoordinates.clear();
      _currentLocationInputController.clear();
      newMapController.dispose();
      _state = 1;
      statusRide = "";
      driverName = "";
      driverPhone = "";
      rideStatus="Driver is Coming";
    });
    await locateOnMap();
    setState(() {
      _loading = false;
    });
  }
  List<NearByAvailableDrivers> availabledriver=[];

  Future<void> _requestRide() async {
    setState(() {
      _state = 3;
    });
    bool isPayed = false;

    // await    Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (BuildContext context1) => UsePaypal(
    //         sandboxMode: true,
    //         clientId:
    //         paypalClientId,
    //         secretKey:
    //         paypalSecretKey,
    //         returnURL: "https://samplesite.com/return",
    //         cancelURL: "https://samplesite.com/cancel",
    //         transactions:  [
    //           {
    //             "amount": {
    //               "total": '${3.75}',
    //               "currency": "USD",
    //               "details": {
    //                 "subtotal": '${3.75}',
    //                 "shipping": '0',
    //                 "shipping_discount": 0
    //               }
    //             },
    //             "description":
    //             "Deposit Payment in EduDrive",
    //             // "payment_options": {
    //             //   "allowed_payment_method":
    //             //       "INSTANT_FUNDING_SOURCE"
    //             // },
    //             "item_list": {
    //
    //             }
    //           }
    //         ],
    //
    //         note: "Contact us for any questions on your order.",
    //
    //         onSuccess: (Map params) async {
    //           //Payment deducted successfully
    //           print("onSuccess: $params");
    //           //Only Deposit amount
    //
    //         },
    //         onError: (error) {
    //           print("onError: $error");
    //           Utils().toastMessage("Error Occur");
    //
    //
    //         },
    //         onCancel: (params) {
    //           print('cancelled: $params');
    //           Utils().toastMessage("Payment not Deposit");
    //
    //
    //         }),
    //   ),
    //
    // );



    Map<String,dynamic> requestData =  await Provider.of<RideProvider>(context, listen: false).saveRideRequest();
    await Provider.of<MapsProvider>(context, listen: false).searchNearestDriver(requestData["id"],context);
    rideStreamSubscription = rideRequestRef.doc(requestData["id"]).snapshots().listen((event) async{
      print("show request");
      if(event.data()==null){
        print("show request null");

        return ;
      }
      if(event.data()!["request_status"]!=null){
        print("show request status not null");

        statusRide = event.data()!["request_status"].toString();

        if(statusRide=="accepted"){
          print("show screen");

          setState(() {
            _state = 4;
            driverName = event.data()!["driver_name"];
            driverPhone = event.data()!["driver_phone"];
          });
          if(event.data()!["fares"]!=null){
            double fare = double.parse(event.data()!["fares"].toString());
            if(isPayed==false){
              var res = await showDialog(context: context, builder: (BuildContext context)=>CollectFareDailog(paymentMethod: "PayPal Method",fareAmount: fare,));
              if(res=="close"){
                await    Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context1) => UsePaypal(
                        sandboxMode: true,
                        clientId:
                        paypalClientId,
                        secretKey:
                        paypalSecretKey,
                        returnURL: "https://samplesite.com/return",
                        cancelURL: "https://samplesite.com/cancel",
                        transactions:  [
                          {
                            "amount": {
                              "total": '${fare}',
                              "currency": "USD",
                              "details": {
                                "subtotal": '${fare}',
                                "shipping": '0',
                                "shipping_discount": 0
                              }
                            },
                            "description":
                            "Deposit Payment in EduDrive",
                            // "payment_options": {
                            //   "allowed_payment_method":
                            //       "INSTANT_FUNDING_SOURCE"
                            // },
                            "item_list": {

                            }
                          }
                        ],

                        note: "Contact us for any questions on your order.",

                        onSuccess: (Map params) async {
                          //Payment deducted successfully
                          print("onSuccess: $params");
                          //Only Deposit amount
                          Utils().toastMessage("Payment Done");

                        },
                        onError: (error) {
                          print("onError: $error");
                          Utils().toastMessage("Error Occur");


                        },
                        onCancel: (params) {
                          print('cancelled: $params');
                          Utils().toastMessage("Payment not Deposit");


                        }),
                  ),
                );
                setState(() {
                  isPayed = true;
                });
              }
            }
            }

          Geofire.stopListener();
          deleteGeoFireMarkers();
        }

        else if(statusRide=="onride"){
          double driverLat = double.parse(event.data()!["driver_location"]["lat"].toString());
          double driverlng= double.parse(event.data()!["driver_location"]["lng"].toString());
          LatLng driverCurrentLocation = LatLng(driverLat, driverlng);
          updateRideTimeToDropOffLoc(driverCurrentLocation);
        }
        else if(statusRide=="arrived"){
          setState(() {
            rideStatus = "Driver has Arrived";
          });
        }
        else if(statusRide=="ended"){
          if(event.data()!["fares"]!=null){
            double fare = double.parse(event.data()!["fares"].toString());
            var res = await showDialog(context: context, builder: (BuildContext context)=>ResquestCompleteDailog(paymentMethod: "cash",fareAmount: fare,));
            if(res=="close"){
             rideStreamSubscription!.cancel();
             rideStreamSubscription = null;
             _resetApp();
            }
          }
        }
        if(event.data()!["driver_location"]!=null){
          double driverLat = double.parse(event.data()!["driver_location"]["lat"].toString());
          double driverlng= double.parse(event.data()!["driver_location"]["lng"].toString());
          LatLng driverCurrentLocation = LatLng(driverLat, driverlng);
          if(statusRide =="accepted" ){
            updateRideTimeToPickUpLoc(driverCurrentLocation);

          }
        }


      }
      else{

      }
    });

    if(isPayed){
      print("Payment Paid");
    }else{
      print("Payment Not Paid");
    }


    // QuerySnapshot getAllDriver = await FirebaseFirestore.instance.collection("driver").get();
    // for(var data in getAllDriver.docs ){
    //   await PushNotificationServices.sendNotification(title: "Instent Booking",body: "Instent Booking Notification received",
    //       type: 0,request_id: "",token: data["fcmToken"]);
    // }
    //
    // availableDriver= GeoFireAssistant.nearByAvailableDriversList;
    // searchNearestDriver();
  }

  void deleteGeoFireMarkers(){
    setState(() {
      markers.removeWhere((element) => element.markerId.value.contains("driver"));
    });
  }
  updateRideTimeToPickUpLoc(LatLng driverCurrentLocation)async{

    var positionUserLatLng = LatLng(currentPosition!.latitude, currentPosition!.longitude);
    if(isRequestingPositionDetails ==false){
      // setState(() {
      isRequestingPositionDetails = true;
      // });
      var details = await DirectionHelper.obtainPlaceDirectionDetails(driverCurrentLocation, positionUserLatLng);
      if(details == null){
        return;
      }
      else{
        setState(() {
          rideStatus="Driver is Coming - " + details.durationText!;
        });
      }
      isRequestingPositionDetails = false;

    }

  }
  updateRideTimeToDropOffLoc(LatLng driverCurrentLocation)async{

    var positionUserLatLng = LatLng(currentPosition!.latitude, currentPosition!.longitude);


    var dropoff = Provider.of<RideProvider>(context, listen: false).dropOffLocation;
    var dropOffLatLng = LatLng(dropoff!.latitude!, dropoff.longitude!);
    if(isRequestingPositionDetails ==false){
      // setState(() {
      isRequestingPositionDetails = true;
      // });
      var details = await DirectionHelper.obtainPlaceDirectionDetails(driverCurrentLocation, dropOffLatLng);
      if(details == null){
        return;
      }
      else{
        setState(() {
          rideStatus="Going to Destination - " + details.durationText!;
        });
      }
      isRequestingPositionDetails = false;

    }

  }

  Future<void> _addAddress(String address, String tag, String name) async {
    try {
      final addressProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );
      final pickupLocation = addressProvider.pickupLocation;
      if (address == pickupLocation!.address) {
        final newAddress = Address(
          address: pickupLocation.address,
          latitude: pickupLocation.latitude,
          longitude: pickupLocation.longitude,
          tag: tag,
          name: name,
        );
        // await addressProvider.addAddress(newAddress);
      } else {
        final mapProvider = Provider.of<MapsProvider>(context, listen: false);
        await mapProvider.geocode(address);
        final geocodedAddress = mapProvider.geocodedAddress;
        final newAddress = Address(
          id: geocodedAddress.id,
          address: geocodedAddress.name,
          name: name,
          latitude: geocodedAddress.latitude,
          longitude: geocodedAddress.longitude,
          tag: tag,
        );
        // addressProvider.addAddress(newAddress);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Request Failed';
      print(error);
      _snackbar(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not save address. Please try again later.';
      print(error);
      _snackbar(errorMessage);
    }
  }

  void addAddressModalSheet(String label) {
    final pickupLocation = Provider.of<UserProvider>(
      context,
      listen: false,
    ).pickupLocation;
    showModalBottomSheet(
      context: context,
      shape: modalSheetShape,
      isScrollControlled: true,
      builder: (_) => AddNewAddress(
        addAddress: _addAddress,
        label: label,
        getLocationAddress: pickupLocation?.address ?? '',
      ),
    );
  }

  Future<void> _deleteAddress(String id) async {
    try {
      bool confirm = await _checkDialog();
      if (confirm) {
        // await Provider.of<UserProvider>(context, listen: false)
        //     .deleteAddress(id);
      } else {
        return;
      }
    } catch (error) {
      _snackbar(error.toString());
    }
  }

  void showAddressesByType(String label, double height) async {
    final res = await showModalBottomSheet(
      context: context,
      shape: modalSheetShape,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
          minHeight: height * 0.5,
          maxHeight: height * 0.7,
        ),
        child: AddressListByType(
          label: label,
          addAddress: () {
            Navigator.of(context).pop();
            addAddressModalSheet(label);
          },
          deleteAddress: _deleteAddress,
        ),
      ),
    );
    await obtainDirection(res);
  }

  double mapBottomPadding(double queryHeight) {
    double bottomPad = 70;
    if (_state == 1) {
      bottomPad = queryHeight * 0.32;
    } else if (_state == 2) {
      bottomPad = queryHeight * 0.44;
    } else if (_state == 3) {
      bottomPad = queryHeight * 0.25;
    }
    return bottomPad;
  }

  final modalSheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
  );



  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );


  @override
  void dispose() {
    _currentLocationInputController.dispose();
    newMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Consumer<MapsProvider>(
            builder: (ctx, maps, _) => FutureBuilder(
              future: maps.checkPermissions(),
              builder: (ctx, snapshot) => maps.isPermissionsInit
                  ? CircularProgressIndicator(
                      color: AppColor.whiteColor,
                    )
                  : GoogleMap(
                      myLocationEnabled: true,
                      padding: EdgeInsets.only(
                          bottom: mapBottomPadding(size.height)),
                      polylines: polylineSet,
                      markers: markers,
                      circles: circles,
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: onMapCreated,
                    ),
            ),
          ),
          Positioned(
            top: 20,
            child: FloatingAppBarWrapperWithTextField(
              height: size.height * 0.072,
              width: size.width,
              leadingIcon: SvgPicture.asset("assets/icon/pickup.svg"),
              hintLabel: 'Pickup Location',
              controller: _currentLocationInputController,
              onSubmitted: onLocationInput,
            ),
          ),
          //Hi where to go,
          Positioned(
            bottom: 0,
            child: AnimatedSize(
              duration: Duration(milliseconds: 360),
              curve: Curves.easeOut,
              child: Container(
                constraints:
                    _state == 1 ? null : BoxConstraints(maxHeight: 0.0),
                width: size.width,
                // padding: const EdgeInsets.symmetric(
                //   horizontal: 16,
                //   vertical: 20,
                // ),
                child: DecoratedWrapper(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          'Hi There',
                          style: FontAssets.mediumText.copyWith(
                            color: AppColor.whiteColor
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Where to?',
                          style: FontAssets.largeText.copyWith(
                            color: AppColor.whiteColor
                          ),
                        ),
                        SizedBox(height: 22),
                        GestureDetector(
                          onTap: () async {
                            final res = await Navigator.pushNamed(context,  SearchScreen.routeName);
                            await obtainDirection(res);
                          },
                          child: SearchButton(),
                        ),
                        SizedBox(height: 32),
                        CustomButton(label: "Continue", onTap: (){}),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          //Request for Ride
          Positioned(
            bottom: 0,
            child: AnimatedSize(
              duration: Duration(milliseconds: 240),
              curve: Curves.bounceInOut,
              child: Container(
                constraints:
                    _state == 2 ? null : BoxConstraints(maxHeight: 0.0),
                width: size.width,
                margin: _state == 2
                    ? EdgeInsets.zero
                    : null,
                child: DecoratedWrapper(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          'Request for Ride',
                          style: FontAssets.largeText.copyWith(
                              fontSize: 22,
                              color: AppColor.whiteColor
                          )
                        ),
                        SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            minLeadingWidth: 20,
                            leading: SvgPicture.asset(
                              'assets/icon/van.svg',
                              fit: BoxFit.fitHeight,
                              width: 50,
                              color: AppColor.whiteColor,
                              ),
                            title: Text(
                              'Van',
                              style: FontAssets.mediumText.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColor.whiteColor,
                              ),
                            ),
                            subtitle: Text(
                              tripDetails.distanceText ?? '-- km',
                              style: FontAssets.smallText.copyWith(
                                color: AppColor.whiteColor,
                              ),
                            ),
                            trailing: Text(
                              '\$${PricingHelper.calculateFares(tripDetails.durationValue ?? 0, tripDetails.distanceValue ?? 0).toStringAsFixed(2)}',
                              style: FontAssets.mediumText.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColor.whiteColor
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            selectedTileColor: AppColor.blackColor.withOpacity(0.3),
                            selected: true,
                            onTap: () {
                              print('Change Payment Method');
                            },
                            leading: Icon(
                              Icons.money,
                              color: AppColor.whiteColor,
                              size: 30,
                            ),
                            trailing: Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColor.whiteColor,
                            ),
                            title: Text(
                              'Payment through Paypal',
                              style: FontAssets.smallText.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColor.whiteColor
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        CustomButton(
                          label: 'Request Ride',
                          onTap: (){
                           // if(kDebugMode) print();
                            _requestRide();
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          //Request || Cancel UI
          Positioned(
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                )
              ),
              constraints:
                  _state == 3 ? null : BoxConstraints(maxHeight: 0.0),
              width: size.width,
              margin: _state == 3
                  ? EdgeInsets.zero
                  : null,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Finding a Driver",
                    style: FontAssets.largeText,
                  ),
                  SizedBox(height: 20,),
                  CustomButton(label: "Cancel", onTap: _resetApp,color: AppColor.redColor,),
                ],
              ),
            ),
          ),
          //get data
          Positioned(
            bottom: 0,
            child: Container(
              // height: 290,
              decoration: BoxDecoration(
                color: AppColor.scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                )
              ),
              constraints:
                  _state == 4 ? null : BoxConstraints(maxHeight: 0.0),
              width: size.width,
              margin: _state == 4
                  ? EdgeInsets.zero
                  : null,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 6.0,),
                  Row(children: [
                    Text("$rideStatus", textAlign: TextAlign.center,style: FontAssets.largeText,)


                  ],),
                  SizedBox(height: 22.0,),
                  Divider(color: Colors.white.withOpacity(0.8),),
                  Text("Driver Name: $driverName",style: FontAssets.mediumText,),
                  Text("Driver Phone: $driverPhone",style: FontAssets.mediumText,),
                  SizedBox(height: 15.0,),
                  Divider(color: Colors.white.withOpacity(0.8),),
                  SizedBox(height: 15.0,),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
                    GestureDetector(
                      onTap: (){
                        launchUrl(Uri.parse("tel:$driverPhone"));
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        decoration: BoxDecoration(color: AppColor.primaryButtonColor,),
                        child: Row(
                          children: [Text("Call Driver",style: FontAssets.mediumText.copyWith(color: AppColor.whiteColor),),Icon(Icons.call,color: AppColor.whiteColor),],
                        ),
                      ),
                    ),

                  ],)
                  ],
              ),
            ),
          ),
          if (_loading)
            Container(
              height: size.height,
              width: size.width,
              color: Colors.black26,
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // void searchNearestDriver(){
  //   if(availableDriver.length == 0){
  //     print("------------------------=========helloo no driver found-------------");
  //     noDriverFound(context);
  //     return;
  //   }
  //   else{
  //     var driver = availableDriver[0];
  //     // notifyDriver(driver);
  //     availableDriver.removeAt(0);
  //   }
  //   print( availableDriver);
  //   var driver = availableDriver[0];
  //
  //   FirebaseFirestore.instance.collection("driver").doc(driver.key).get().then((value) {
  //     if(value["newAppointment"]=="searching"){
  //       // notifyDriver(driver);
  //       // availableDriver.removeAt(0);
  //     }
  //     else{
  //       availableDriver.removeAt(0);
  //       searchNearestDriver();
  //     }
  //   });
  //
  // }

  // void notifyDriver(NearByAvailableDrivers driver){
  //   String token;
  //   FirebaseFirestore.instance.collection("driver").doc(driver.key).update({
  //     "newAppointment":
  //   });
  //   FirebaseFirestore.instance.collection("drivers").doc(driver.key).get().then((DocumentSnapshot<Map<String, dynamic>> snap) {
  //     if(snap.data()!["token"]!=null){
  //       token =snap.data()!["token"];
  //       print(token);
  //       AssistantMethods.sendNotificationToDriver(token, clientRequestRef!.key);
  //     }
  //     else{
  //       return;
  //     }
  //
  //     const oneSecondPassed= Duration(seconds: 1);
  //     var timer = Timer.periodic(oneSecondPassed, (timer) {
  //       if(state !="requesting"){
  //         FirebaseFirestore.instance.collection("drivers").doc(driver.key).update({
  //           "newAppointment":"cancelled"
  //         });
  //         FirebaseFirestore.instance.collection("drivers").doc(driver.key).get().timeout(oneSecondPassed);
  //         driverRequestTimeout = 60;
  //         timer.cancel();
  //       }
  //       driverRequestTimeout = driverRequestTimeout - 1;
  //
  //       FirebaseFirestore.instance.collection("drivers").doc(driver.key).get().then((value) {
  //         if(value["newAppointment"]=="accepted"){
  //           FirebaseFirestore.instance.collection("drivers").doc(driver.key).get().timeout(oneSecondPassed);
  //           driverRequestTimeout = 60;
  //           timer.cancel();
  //         }
  //       }
  //       );
  //
  //       if(driverRequestTimeout == 0){
  //         clientRequestRef!.onValue.listen((DatabaseEvent event) {
  //           Map<String, dynamic> data = jsonDecode(jsonEncode(event.snapshot.value))  as Map<String, dynamic>;
  //
  //           if(data["status"] == "cancelled"){
  //             // FirebaseFirestore.instance.collection("drivers").doc(driver.key).update({
  //             //   "newAppointment":"timeout"
  //             // });
  //             FirebaseFirestore.instance.collection("drivers").doc(driver.key).get().timeout(oneSecondPassed);
  //             driverRequestTimeout = 60;
  //             timer.cancel();
  //             availableDoctor.removeAt(0);
  //             searchNearestDoctor();
  //           }
  //         });
  //
  //
  //       }
  //
  //     });
  //
  //   });
  //
  //
  // }

}
void noDriverFound(context){
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)=>NoDriverAvailableDialog());
}