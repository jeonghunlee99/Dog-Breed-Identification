import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../widget/custom_circular.dart';
import 'helath_hospital_controller.dart';
import 'helath_hospital_data.dart';

class HospitalMap extends ConsumerStatefulWidget {
  const HospitalMap({super.key});

  @override
  ConsumerState<HospitalMap> createState() => _HospitalMapState();
}

class _HospitalMapState extends ConsumerState<HospitalMap> {
  final Completer<GoogleMapController> mapControllerCompleter = Completer();
  late final HospitalMapController controller;
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = HospitalMapController(ref);
    addressController.text = '동물병원';
    controller.getCurrentLocation();
    controller.searchAddress('동물병원', mapControllerCompleter);
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final latitude = ref.watch(latitudeProvider);
    final longitude = ref.watch(longitudeProvider);
    final markers = ref.watch(markersProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);

    final controller = HospitalMapController(ref);

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
                onPressed: () {
                  controller.searchAddress(
                      addressController.text, mapControllerCompleter);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Stack(
              children: [
                if (latitude != null && longitude != null)
                  GoogleMap(
                    mapType: MapType.terrain,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latitude, longitude),
                      zoom: 15,
                    ),
                    markers: markers,
                    onMapCreated: (GoogleMapController mapController) {
                      mapControllerCompleter.complete(mapController);
                    },
                    onTap: (point) {
                      controller.handleMapTap(point);
                    },
                  ),
                if (latitude == null || longitude == null)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomCircularIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          '로딩 중입니다...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
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
