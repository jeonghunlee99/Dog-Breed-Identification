import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// WalkStats 상태 관리
class WalkStatsNotifier extends StateNotifier<Map<DateTime, Duration>> {
  WalkStatsNotifier() : super({});

  Future<void> fetchWalkStats() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("로그인된 사용자가 없습니다.");
      final uid = user.uid;

      final firestore = FirebaseFirestore.instance;
      final userDoc = await firestore.collection('dogs').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data?['walkStats'] != null) {
          final fetchedStats = (data!['walkStats'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(DateTime.parse(key), Duration(seconds: value as int)));

          state = fetchedStats;
        }
      }
    } catch (e) {
      print("Firestore WalkStats 가져오기 오류: $e");
    }
  }

  Future<void> updateWalkStatsToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("로그인된 사용자가 없습니다.");
      final uid = user.uid;

      final firestore = FirebaseFirestore.instance;
      final userDocRef = firestore.collection('dogs').doc(uid);

      final statsForFirestore = state.map((date, duration) =>
          MapEntry(date.toIso8601String(), duration.inSeconds));

      await userDocRef.set({'walkStats': statsForFirestore}, SetOptions(merge: true));
    } catch (e) {
      print("Firestore WalkStats 업데이트 오류: $e");
    }
  }

  void addWalkTime(DateTime date, Duration duration) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    state = {
      ...state,
      normalizedDate: (state[normalizedDate] ?? Duration.zero) + duration,
    };
    updateWalkStatsToFirestore();
  }
}

/// WalkEvents 상태 관리
class WalkEventsNotifier extends StateNotifier<Map<DateTime, List<String>>> {
  WalkEventsNotifier() : super({});

  Future<void> fetchWalkEvents() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("로그인된 사용자가 없습니다.");
      final uid = user.uid;

      final firestore = FirebaseFirestore.instance;
      final userDoc = await firestore.collection('dogs').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data?['walkEvents'] != null) {
          final fetchedEvents = (data!['walkEvents'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(DateTime.parse(key), List<String>.from(value)));

          state = fetchedEvents;
        }
      }
    } catch (e) {
      print("Firestore WalkEvents 가져오기 오류: $e");
    }
  }

  Future<void> updateWalkEventsToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("로그인된 사용자가 없습니다.");
      final uid = user.uid;

      final firestore = FirebaseFirestore.instance;
      final userDocRef = firestore.collection('dogs').doc(uid);

      final eventsForFirestore = state.map((date, events) =>
          MapEntry(date.toIso8601String(), events));

      await userDocRef.set({'walkEvents': eventsForFirestore}, SetOptions(merge: true));
    } catch (e) {
      print("Firestore WalkEvents 업데이트 오류: $e");
    }
  }

  void addWalkRecord(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    state = {
      ...state,
      normalizedDate: [...(state[normalizedDate] ?? []), '산책 ${state[normalizedDate]?.length ?? 0 + 1}회'],
    };
    updateWalkEventsToFirestore();
  }
}

/// Provider 선언
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