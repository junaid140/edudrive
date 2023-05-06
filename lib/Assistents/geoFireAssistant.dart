
import 'package:edudrive/models/near_by_available_drivers.dart';

class GeoFireAssistant {

  static List <NearByAvailableDrivers> nearByAvailableDriversList = [];

  static void removeDriverFromList(String key)
  {
    int index =  nearByAvailableDriversList.indexWhere((element) => element.key == key);
    nearByAvailableDriversList.removeAt(index);
  }

  static void updateDiversNearByLocation(NearByAvailableDrivers drivers)
  {
    int index =  nearByAvailableDriversList.indexWhere((element) => element.key == drivers.key);
    nearByAvailableDriversList[index].latitude = drivers.latitude;
    nearByAvailableDriversList[index].longitude = drivers.longitude;


  }

}