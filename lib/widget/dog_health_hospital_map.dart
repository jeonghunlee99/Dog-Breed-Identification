import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final latitudeProvider = StateProvider<double?>((ref) => null);
final longitudeProvider = StateProvider<double?>((ref) => null);

class HospitalMap extends ConsumerStatefulWidget {
  const HospitalMap({super.key});

  @override
  ConsumerState<HospitalMap> createState() => _HospitalMapState();
}

class _HospitalMapState extends ConsumerState<HospitalMap> {
  final Completer<NaverMapController> mapControllerCompleter = Completer();
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();
  }

  @override
  void dispose() {
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

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      ref.read(latitudeProvider.notifier).state = position.latitude;
      ref.read(longitudeProvider.notifier).state = position.longitude;
    }
  }

  @override
  Widget build(BuildContext context) {
    final latitude = ref.watch(latitudeProvider);
    final longitude = ref.watch(longitudeProvider);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: latitude == null || longitude == null
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              //     : NaverMap(
              //   options: const NaverMapViewOptions(
              //     indoorEnable: true,
              //     locationButtonEnable: false,
              //     consumeSymbolTapEvents: false,
              //   ),
              //   onMapReady: (controller) async {
              //     mapControllerCompleter.complete(controller);
              //
              //     final cameraPosition = NCameraPosition(
              //       target: NLatLng(latitude!, longitude!),
              //       zoom: 15,
              //       bearing: 45,
              //       tilt: 30,
              //     );
              //
              //     await controller.updateCamera(
              //         NCameraUpdate.fromCameraPosition(cameraPosition));
              //
              //     final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
              //       target: NLatLng(latitude!, longitude!),
              //       zoom: 18,
              //     );
              //
              //     cameraUpdate.setAnimation(
              //       animation: NCameraAnimation.fly,
              //       duration: const Duration(seconds: 2),
              //     );
              //
              //     await controller.updateCamera(cameraUpdate);
              //   },
              // ),
              : Text('data')),
    );
  }
}
