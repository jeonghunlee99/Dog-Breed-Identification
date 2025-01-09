import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDateProvider = StateProvider<String>((ref) => '');
final memoProvider = StateProvider<String>((ref) => '');
final errorTextProvider = StateProvider<String?>((ref) => null);