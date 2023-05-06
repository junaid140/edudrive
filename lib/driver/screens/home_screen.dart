import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edudrive/driver/models/instant_ride_request.dart';
import 'package:edudrive/res/app_color/app_color.dart';
import 'package:edudrive/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../driver/providers/maps_provider.dart';
import '../providers/driver_provider.dart';
import '../widgets/floating_appbar_wrapper.dart';
import '../widgets/requestDailog.dart';
import 'order_tracking_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = '/home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _snackbar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
        backgroundColor: Theme.of(context).accentColor,
      ),
    );
  }
  bool isLoading=false;

  Position? _currentPosition;

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

  Future<void> _getCurrentPosition() async {
    setState(() {
      isLoading =true;
    });
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {

        _currentPosition = position;
        isLoading = false;
      });

      // _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }
  @override
  void initState() {
    _getCurrentPosition();
    super.initState();
  }

  // @override
  // void dispose() {
  //
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     onPressed: (){},
      //     icon: Icon(Icons.menu,color: Colors.white,),
      //   ),
      //   centerTitle: true,
      //   title: Text("eduDrive",style: TextStyle(
      //     fontSize: 20,
      //     fontWeight: FontWeight.bold
      //   ),),
      // ),
      body: Consumer<DriverProvider>(
        builder: (ctx, driver, _) => !isLoading? Consumer<MapsProvider1>(
          builder: (ctx, maps, _) => FutureBuilder(
            future: driver.tryStatus(),
            builder: (ctx, snapshot) => Stack(
              children: [
                driver.status
                    ? FutureBuilder(
                        future: maps.checkPermissions(),
                        builder: (ctx,AsyncSnapshot snapshot) => !snapshot.hasData
                            ? CircularProgressIndicator(
                                color: Theme.of(context).accentColor,
                              )
                            : !snapshot.data!?
                        Center(child: Text("No Location Permision"),):
                        Stack(
                          children: [
                            GoogleMap(
                              myLocationEnabled: true,
                              padding: EdgeInsets.all(12),

                              // initialCameraPosition: _kGooglePlex,
                              initialCameraPosition:CameraPosition(
                                target: LatLng(_currentPosition!.latitude,_currentPosition!.longitude),
                                zoom:  15.6,
                              ),
                              onMapCreated:
                                  (GoogleMapController controller) async {
                                try {
                                  await maps.setMapController(controller);
                                } catch (error) {
                                  const errorMessage =
                                      'Could not locate you. Please try again later.';
                                  print(error);
                                  _snackbar(errorMessage +
                                      '    ' +
                                      error.toString());
                                }
                              },
                            ),
                            // snapshot.data!.data()!["instantBooking"]!="searching"?Align(
                            //   alignment: Alignment.bottomCenter,
                            //   child: GestureDetector(
                            //     onTap: ()async{
                            //       if(snapshot.data!.data()!["instantBooking"]=="accepted"){
                            //         DocumentSnapshot<Map<String,dynamic>> requestData = await FirestoreServices().getInstantRequest(snapshot.data!["instantBookingId"]);
                            //         print("---");
                            //         print("${_currentPosition!.latitude}"+"${_currentPosition!.longitude}");
                            //         Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderTrackingPage(driverLatLng:
                            //         LatLng(_currentPosition!.latitude,_currentPosition!.longitude),data: requestData.data()!,isJustAccepted: true,)));
                            //       }
                            //       else{
                            //         DocumentSnapshot<Map<String,dynamic>> requestData = await FirestoreServices().getInstantRequest(snapshot.data!["instantBookingId"]);
                            //         Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderTrackingPage(driverLatLng: LatLng(_currentPosition!.latitude,_currentPosition!.longitude),data: requestData.data()!,isJustAccepted: false,)));
                            //
                            //       }
                            //     },
                            //     child: Container(
                            //       height: 50,
                            //       padding: EdgeInsets.all(8),
                            //       margin: EdgeInsets.all(20),
                            //       width: double.infinity,
                            //       decoration: BoxDecoration(
                            //         color: AppColor.primaryColor,
                            //         borderRadius: BorderRadius.circular(16),
                            //
                            //       ),
                            //       child: Text("New Instant Booking active"),
                            //     ),
                            //   ),
                            // )
                            //     :SizedBox.shrink()
                          ],
                        )
                        // StreamBuilder(
                        //   stream: FirebaseFirestore.instance.collection("driver").doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
                        //   builder: (context,AsyncSnapshot<DocumentSnapshot<Map<String,dynamic>>> snapshot) {
                        //     return snapshot.hasData? :Center(child: CircularProgressIndicator(),);
                        //   }
                        // ),
                      )
                    : Center(
                        child: Icon(
                          Icons.offline_bolt_rounded,
                          size: query.width * 0.6,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                Positioned(
                  top: 5,
                  child: FloatingAppBarWrapper(
                    height: query.height * 0.072,
                    width: query.width,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          driver.status ? 'Online Now' : 'Offline',
                          style:TextStyle(
                            color:Colors.black
                          )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Switch.adaptive(
                          value: driver.status,
                          onChanged: (value) async {
                            driver.changeWorkMode(value);
                            value
                                ? await maps.goOnline()
                                : await maps.goOffline();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ):Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}


 requestNotification(context,requestId,InstantRideRequest requestData, Map<String, dynamic> parentData){

   return showDialog(
      context: context,
      useRootNavigator: true,
      // barrierDismissible: false,
      builder: ( context)=>NewRequestDailog(requestId:requestId ,instantRideRequest: requestData, parentData: parentData,context: context));
}