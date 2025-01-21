import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final photosProvider = StateProvider<List<File>>((ref) => []);
final backgroundImageProvider = StateProvider<File?>((ref) => null);


