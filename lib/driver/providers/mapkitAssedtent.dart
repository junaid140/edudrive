// import 'package:google_maps_flutter/google_maps_flutter.dart' as map;
import 'package:maps_toolkit/maps_toolkit.dart' ;
class MapKitAssestent {
  static double getMarkerRotation(sLat,sLng, dLat,dLng){
    var  rot = SphericalUtil.computeHeading(LatLng(sLat, sLng),LatLng(dLat, dLng));
        return rot.toDouble();
  }
}