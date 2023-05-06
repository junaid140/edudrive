import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../driver/services/firestore_services.dart';
import 'driver_provider.dart';

class MapsProvider1 with ChangeNotifier {
  void update(DriverProvider driver) {
    driverId = driver.driverId;
    status = driver.status;
  }

  late String? driverId;

  late bool status;

  late Position _currentPosition;

  Position get currentPosition => _currentPosition;

  late GoogleMapController _newMapController;

  GoogleMapController get newMapController => _newMapController;

  Future<void> setMapController(GoogleMapController controller) async {
    try {
      Completer<GoogleMapController> _controller = Completer();
      _controller.complete(controller);
      _newMapController = await _controller.future;
      notifyListeners();
      await locatePosition();
    } catch (error) {
      rethrow;
    }
  }

  // ignore: cancel_subscriptions
  StreamSubscription<Position>? liveLocationStream;

  bool isPermissionsInit = true;

  // Future<bool> checkPermissions() async {
  //   // print("----");
  //   LocationPermission permission;
  //
  // return Geolocator.checkPermission().then((permission) async {
  //  // print(permission);
  //      if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied ||
  //         permission == LocationPermission.deniedForever) {
  //       return false;
  //     }
  //     isPermissionsInit = false;
  //     notifyListeners();
  //     return true;
  //   }
  //   else {
  //   isPermissionsInit = false;
  //   notifyListeners();
  //   return false;
  //   }
  //   });
  //
  // }
  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text(
      //         'Location services are disabled. Please enable the services')));
      isPermissionsInit = false;
      notifyListeners();
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Location permissions are denied')));
        isPermissionsInit = false;
        notifyListeners();
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text(
      //         'Location permissions are permanently denied, we cannot request permissions.')));
      isPermissionsInit = false;
      notifyListeners();
      return false;
    }
    isPermissionsInit = false;
    notifyListeners();
    return true;
  }

  Future<void> geolocate() async {
    final check = await checkPermissions();
    if (check) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position;
    }
    notifyListeners();
  }

  Future<void> locatePosition() async {
    try {
      await geolocate();
      LatLng latLngPosition =
          LatLng(_currentPosition.latitude, _currentPosition.longitude);
      CameraPosition cameraPosition = new CameraPosition(
        target: latLngPosition,
        zoom: 14,
      );
      _newMapController.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
      await goOnline();
      await getLiveLocationUpdates();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> goOffline() async {
    try {
      await Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid!);
      await FirestoreServices().updateDriver(FirebaseAuth.instance.currentUser!.uid, {"instantBooking":"","onlineStatus":false});

      // _controller = null;
      // liveLocationStream = null;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> goOnline() async {
    try {
      print("--online status");
      await geolocate();
      await Geofire.initialize('available-drivers');
      await FirestoreServices().updateDriver(FirebaseAuth.instance.currentUser!.uid, {"instantBooking":"searching","onlineStatus":true});

      await Geofire.setLocation(
        FirebaseAuth.instance.currentUser!.uid,
        _currentPosition.latitude,
        _currentPosition.longitude,
      );

    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> getLiveLocationUpdates() async {
    liveLocationStream = Geolocator.getPositionStream().listen(
      (Position position) {
        _currentPosition = position;
        if (status)
          Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid!, position.latitude, position.longitude);
        LatLng latLng = LatLng(position.latitude, position.longitude);
        CameraPosition cameraPosition = new CameraPosition(
          target: latLng,
          zoom: 14,
        );
        _newMapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      },
    );
    notifyListeners();
  }
}
