import 'package:google_maps_webservice/places.dart';
import 'package:project_teachers/utils/constants/constants.dart';

class GooglePlaces {

  static GooglePlaces _instance;
  GooglePlaces._privateConstructor();
  GoogleMapsPlaces _places;
  GoogleMapsPlaces get Places => _places;

  static GooglePlaces get instance {
    if (_instance == null) {
      _instance = GooglePlaces._privateConstructor();
      _instance._places =  GoogleMapsPlaces(apiKey: Constants.API_KEY);
    }
    return _instance;
  }

}