import 'dart:convert';

import 'package:edudrive/services/firestore_services.dart';

import '../helpers/firebase_utils.dart';
import 'package:http/http.dart' as http;

class DriverRepo{
  Future<Map<String, dynamic>> fetchDriverDetails(driverId) async {
    try {
      // final url = '${DBUrls.drivers}/${driverId}.json?';
      final response = await FirestoreServices().getDriver(driverId);
      final data = response.data();

      if (data == null) {
        return {};
      }
      return data;

    } catch (error) {

      print(error);
      return {};
    }
  }

}