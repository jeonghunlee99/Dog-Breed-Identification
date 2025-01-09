import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SortOption { byAdded, byNewest, byOldest }

final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.byAdded);
final healthRecordProvider = StateProvider<List<HealthRecordState>>((ref) => []);

class HealthRecordState {
  final String date;
  final String memo;

  HealthRecordState({required this.date, required this.memo});
}