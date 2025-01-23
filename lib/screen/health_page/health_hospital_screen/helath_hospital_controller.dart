import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'helath_hospital_data.dart';


class HospitalMapController {
  final WidgetRef ref;

  HospitalMapController(this.ref);

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      ref.read(latitudeProvider.notifier).state = position.latitude;
      ref.read(longitudeProvider.notifier).state = position.longitude;
    }
  }

  Future<void> searchAddress(String address,
      Completer<GoogleMapController> mapControllerCompleter) async {
    try {
      final coordinatesList = await getCoordinatesFromPlaceName(address);
      final markers = coordinatesList.map((location) {
        return Marker(
          markerId: MarkerId(location['place_name']),
          position: LatLng(location['latitude'], location['longitude']),
          infoWindow: InfoWindow(
            title: location['place_name'],
            snippet: '병원 위치',
          ),
          icon:
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );
      }).toSet();

      ref.read(markersProvider.notifier).state = markers;

      if (coordinatesList.isNotEmpty) {
        final GoogleMapController controller =
        await mapControllerCompleter.future;
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(coordinatesList[0]['latitude'],
                coordinatesList[0]['longitude']),
            15,
          ),
        );
      }
    } catch (e) {
      throw Exception('장소를 찾을 수 없습니다: $e');
    }
  }

  Future<void> handleMapTap(LatLng point) async {
    try {
      final address =
      await getAddressFromCoordinates(point.latitude, point.longitude);
      ref.read(selectedAddressProvider.notifier).state = address;
    } catch (e) {
      throw Exception('주소를 가져올 수 없습니다: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCoordinatesFromPlaceName(
      String placeName) async {
    final apiKey = dotenv.env['apiKey']; // 자신의 Google Places API 키
    final encodedPlaceName = Uri.encodeComponent(placeName);
    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$encodedPlaceName&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      if (decodedResponse['status'] == 'OK') {
        final List results = decodedResponse['results'];
        return results.map((result) {
          final location = result['geometry']['location'];
          return {
            'place_name': result['name'],
            'latitude': location['lat'],
            'longitude': location['lng'],
          };
        }).toList();
      } else {
        throw Exception('Geocoding failed: ${decodedResponse['status']}');
      }
    } else {
      throw Exception('Failed to load geocoding data');
    }
  }

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    final apiKey = dotenv.env['apiKey']; // 자신의 Google API 키
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      if (decodedResponse['status'] == 'OK') {
        return decodedResponse['results'][0]['formatted_address'];
      } else {
        throw Exception(
            'Reverse geocoding failed: ${decodedResponse['status']}');
      }
    } else {
      throw Exception('Failed to load reverse geocoding data');
    }
  }
}