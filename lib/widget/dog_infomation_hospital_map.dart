import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class HospitalMap extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final Completer<NaverMapController> mapControllerCompleter;

  const HospitalMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.mapControllerCompleter,
  });

  @override
  Widget build(BuildContext context) {
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
            ? const Center(child: CircularProgressIndicator())
            : NaverMap(
          options: const NaverMapViewOptions(
            indoorEnable: true,
            locationButtonEnable: false,
            consumeSymbolTapEvents: false,
          ),
          onMapReady: (controller) async {
            mapControllerCompleter.complete(controller);

            final cameraPosition = NCameraPosition(
              target: NLatLng(latitude!, longitude!),
              zoom: 15,
              bearing: 45,
              tilt: 30,
            );

            await controller.updateCamera(
                NCameraUpdate.fromCameraPosition(cameraPosition));

            final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
              target: NLatLng(latitude!, longitude!),
              zoom: 18,
            );

            cameraUpdate.setAnimation(
              animation: NCameraAnimation.fly,
              duration: const Duration(seconds: 2),
            );

            await controller.updateCamera(cameraUpdate);
          },
        ),
      ),
    );
  }
}
