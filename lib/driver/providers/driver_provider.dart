import 'dart:convert';

import 'package:edudrive/driver/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/firebase_utils.dart';
import '../helpers/http_exception.dart';

import '../../driver/models/driver.dart';
import '../../driver/models/car.dart';

import 'auth.dart';

class DriverProvider with ChangeNotifier {
  void update(Auth auth) {
    authToken = auth.token;
    driverId = auth.driverId;
    fetchDriverDetails();
    cars;
  }
  FirestoreServices firestoreServices = FirestoreServices();

  late String? authToken;
  late String? driverId;

  late String _name;
  late String _email;
  late String _mobile;
  late String _wallet;

  String get name => _name;
  String get email => _email;
  String get mobile => _mobile;
  String get wallet => _wallet;

  List<Car> _cars = [];

  List<Car> get cars {
    return [..._cars];
  }

  Driver _driver = Driver();

  Driver get driver => _driver;

  bool _status = true;

  bool get status => _status;

  Future<void> fetchDriverDetails() async {
    try {
      // final url = '${DBUrls.drivers}/${FirebaseAuth.instance.currentUser!.uid}.json?auth=$authToken';
      final response = await firestoreServices.getDriver(FirebaseAuth.instance.currentUser!.uid);
      final data = response.data();

      if (data == null) {
        return;
      }
      _name = data['name'];
      _email = data['email'];
      _mobile = data['mobile'];
      _wallet=data['wallet'].toString();


      final carsResponse = await firestoreServices.getDriverVans();
    final carsData = carsResponse.docs;
      final List<Car> loadedCars = [];
      if (carsData != null) {
        carsData.forEach(( carData) {
          loadedCars.insert(
            0,
            Car(
              id: carData.id,
              carMake: carData.data()['car_make'],
              carModel: carData.data()['car_model'],
              carNumber: carData.data()['car_number'],
              carColor: carData.data()['car_color'],
            ),
          );
        });
      }
      _cars = loadedCars;
      _driver = Driver(
        id: driverId,
        name: name,
        email: email,
        mobile: int.tryParse(mobile),
        cars: cars,
      );
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Car findAddressById(String id) {
    return _cars.firstWhere((car) => car.id == id);
  }

  Future<void> addCar({
    String? carMake,
    String? carModel,
    String? carNumber,
    String? carColor,
  }) async {
    try {

      // final url = '${DBUrls.drivers}/$driverId/cars.json?auth=$authToken';

      final response = await
      firestoreServices.addDriverVan({
        'car_make': carMake,
        'car_model': carModel,
        'car_number': carNumber,
        'car_color': carColor,
        "uid":FirebaseAuth.instance.currentUser!.uid,
        "created_at":DateTime.now()
      }).then((value){
        print(value.id);
        final newCar = Car(
          id: value.id,
          carMake: carMake,
          carModel: carModel,
          carNumber: carNumber,
          carColor: carColor,
          driverId: FirebaseAuth.instance.currentUser!.uid

        );
        _cars.insert(0, newCar);
        notifyListeners();
      });

      final newCar = Car(
        id: json.decode(response.body)['name'],
        carMake: carMake,
        carModel: carModel,
        carNumber: carNumber,
        carColor: carColor,
      );
      _cars.insert(0, newCar);
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  // Future<void> deleteCar(String id) async {
  //
  //   final url = '${DBUrls.drivers}/$driverId/cars/$id.json?auth=$authToken';
  //   final existingCarIndex = _cars.indexWhere((car) => car.id == id);
  //   Car? existingCar = _cars[existingCarIndex];
  //   _cars.removeAt(existingCarIndex);
  //   notifyListeners();
  //   final response = await http.delete(Uri.parse(url));
  //   if (response.statusCode >= 400) {
  //     _cars.insert(existingCarIndex, existingCar);
  //     notifyListeners();
  //     throw HttpException('Could not delete car.');
  //   }
  //   existingCar = null;
  // }

  void changeWorkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _status = value;
    await prefs.setBool('$driverId-status', _status);
    notifyListeners();
  }

  Future<void> tryStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('$driverId-status')) {
      _status = true;
    }
    final extractedValue = prefs.getBool('$driverId-status')!;
    _status = extractedValue;
    notifyListeners();
  }
}
