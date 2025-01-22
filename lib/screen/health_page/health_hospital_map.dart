import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

final latitudeProvider = StateProvider<double?>((ref) => null);
final longitudeProvider = StateProvider<double?>((ref) => null);

class HospitalMap extends ConsumerStatefulWidget {
  const HospitalMap({super.key});

  @override
  ConsumerState<HospitalMap> createState() => _HospitalMapState();
}

class _HospitalMapState extends ConsumerState<HospitalMap> {

  final Completer<GoogleMapController> mapControllerCompleter = Completer();
  double? latitude;
  double? longitude;
  String selectedAddress = '';

  TextEditingController addressController = TextEditingController();

  // 초기 마커를 빈 세트로 설정
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    addressController.text = '동물병원';
    _searchAddress();  // 앱 시작 시 바로 검색되도록 호출
    _getCurrentLocation();
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      ref.read(latitudeProvider.notifier).state = position.latitude;
      ref.read(longitudeProvider.notifier).state = position.longitude;
    }
  }

  Future<void> _searchAddress() async {
    try {
      final coordinatesList = await getCoordinatesFromPlaceName(addressController.text);
      setState(() {
        markers.clear();  // 기존 마커를 지우고 새로 추가
        for (var location in coordinatesList) {
          markers.add(Marker(
            markerId: MarkerId(location['place_name']),
            position: LatLng(location['latitude'], location['longitude']),
            infoWindow: InfoWindow(
              title: location['place_name'],  // 병원 이름을 표시
              snippet: '병원 위치',  // 선택적으로 설명 추가
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),  // 검색 마커를 주황색으로 설정
            onTap: () {
              _animateToLocation(location['latitude'], location['longitude']);
            },
          ));
        }
      });

      final GoogleMapController controller = await mapControllerCompleter.future;
      // 첫 번째 위치로 카메라 이동
      if (coordinatesList.isNotEmpty) {
        controller.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(coordinatesList[0]['latitude'], coordinatesList[0]['longitude']),
          15,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('장소를 찾을 수 없습니다: $e')));
    }
  }


  void _animateToLocation(double latitude, double longitude) async {
    final GoogleMapController controller = await mapControllerCompleter.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 17));
  }

  void _handleTap(LatLng point) async {
    try {
      final address = await getAddressFromCoordinates(point.latitude, point.longitude);
      setState(() {
        selectedAddress = address;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('주소를 가져올 수 없습니다: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final latitude = ref.watch(latitudeProvider);
    final longitude = ref.watch(longitudeProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: addressController,
            decoration: InputDecoration(
              labelText: '장소명 입력',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: _searchAddress,
              ),
            ),
          ),
          const SizedBox(height: 16),
          latitude == null || longitude == null
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: GoogleMap(
              mapType: MapType.terrain,
              myLocationEnabled: true,  // 내 위치 표시 활성화
              myLocationButtonEnabled: true,  // 내 위치 버튼 활성화
              initialCameraPosition: CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: 15,
              ),
              markers: markers,  // 검색된 마커들만 지도에 표시
              onMapCreated: (GoogleMapController controller) {
                mapControllerCompleter.complete(controller);
              },
              onTap: _handleTap, // 지도에서 위치를 탭하면 주소 표시
            ),
          ),
          if (selectedAddress.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('선택된 주소: $selectedAddress'),
            ),
        ],
      ),
    );
  }
}

// 장소명으로 좌표 검색
Future<List<Map<String, dynamic>>> getCoordinatesFromPlaceName(String placeName) async {
  final apiKey = dotenv.env['apiKey'];//  // 자신의 Google Places API 키를 입력하세요.
  final encodedPlaceName = Uri.encodeComponent(placeName);
  final url = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$encodedPlaceName&key=$apiKey';

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

// 좌표로 주소 가져오기
Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
  final apiKey = dotenv.env['apiKey'];  // 자신의 Google API 키를 입력하세요.
  final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final decodedResponse = json.decode(response.body);
    if (decodedResponse['status'] == 'OK') {
      return decodedResponse['results'][0]['formatted_address'];
    } else {
      throw Exception('Reverse geocoding failed: ${decodedResponse['status']}');
    }
  } else {
    throw Exception('Failed to load reverse geocoding data');
  }
}
