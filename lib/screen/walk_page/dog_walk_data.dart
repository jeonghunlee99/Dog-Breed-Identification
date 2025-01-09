import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dog_walk_controller.dart';

final walkStatsProvider =
StateNotifierProvider<WalkStatsNotifier, Map<DateTime, Duration>>(
        (ref) => WalkStatsNotifier());
final walkEventsProvider =
StateNotifierProvider<WalkEventsNotifier, Map<DateTime, List<String>>>(
        (ref) => WalkEventsNotifier());
final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
final durationProvider = StateProvider<Duration>((ref) => Duration.zero);
final isRunningProvider = StateProvider<bool>((ref) => false);
final isWalkCompletedProvider = StateProvider<bool>((ref) => false);




