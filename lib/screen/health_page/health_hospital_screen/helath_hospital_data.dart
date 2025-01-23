import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final latitudeProvider = StateProvider<double?>((ref) => null);
final longitudeProvider = StateProvider<double?>((ref) => null);
final markersProvider = StateProvider<Set<Marker>>((ref) => {});
final selectedAddressProvider = StateProvider<String>((ref) => '');
