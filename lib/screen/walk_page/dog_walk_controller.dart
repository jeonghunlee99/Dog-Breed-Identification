import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widget/custom_snackbar.dart';
import 'dog_walk_data.dart';

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
    final currentCount = (state[normalizedDate]?.length ?? 0);
    final newCount = currentCount + 1;
    state = {
      ...state,
      normalizedDate: [...(state[normalizedDate] ?? []), '산책 $newCount 회'],
    };

    updateWalkEventsToFirestore();
  }

}

class TimerController {
  static void checkLoginStatus(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // 로그인되지 않은 경우 에러 메시지를 표시
      CustomSnackBar.show(
        context,
        message: '로그인 후 해당 기능을 사용할 수 있습니다.',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }

  static void startTimer(BuildContext context, WidgetRef ref) {
    checkLoginStatus(context);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      ref.read(isRunningProvider.notifier).state = true;
      updateTimer(context, ref);
    }
  }

  static void stopTimer(WidgetRef ref) {
    ref.read(isRunningProvider.notifier).state = false;
    ref.read(isWalkCompletedProvider.notifier).state = true;
  }

  static void resetTimer(BuildContext context, WidgetRef ref) {
    checkLoginStatus(context);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      ref.read(durationProvider.notifier).state = Duration.zero;
      ref.read(isWalkCompletedProvider.notifier).state = false;
    }
  }

  static Future<void> updateTimer(BuildContext context, WidgetRef ref) async {
    if (ref.read(isRunningProvider)) {
      final stopwatch = Stopwatch()..start();
      await Future.delayed(const Duration(milliseconds: 100));
      ref.read(durationProvider.notifier).state += stopwatch.elapsed;
      stopwatch.stop();
      updateTimer(context, ref);
    }
  }

  static void completeWalk(BuildContext context, WidgetRef ref, void Function(Duration duration) onWalkComplete) {
    final duration = ref.read(durationProvider);
    onWalkComplete(duration);
    ref.read(isWalkCompletedProvider.notifier).state = false;
    resetTimer(context, ref);
    CustomSnackBar.show(
      context,
      message: '산책이 완료되었습니다!',
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }
}

class LoginStatus {
  static void checkLoginStatus(BuildContext context, Function onSuccess) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackBar.show(
        context,
        message: '로그인 후 산책 기록을 추가할 수 있습니다.',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    } else {
      onSuccess();
    }
  }
}


