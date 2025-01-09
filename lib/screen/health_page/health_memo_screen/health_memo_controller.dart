import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widget/custom_snackbar.dart';
import 'health_memo_data.dart';

class HealthMemoController{
  WidgetRef ref;

  HealthMemoController({required this.ref});

  Future<void> loadHealthRecords() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('dogs').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final healthRecords = data?['health'] as List<dynamic>? ?? [];
        final parsedRecords = healthRecords.map<HealthRecordState>((record) {
          return HealthRecordState(
            date: record['date'].toString(),
            memo: record['memo'].toString(),
          );
        }).toList();
        ref.read(healthRecordProvider.notifier).state = parsedRecords;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading health records: $e');
      }
    }
  }

  Future<void> deleteHealthRecord({required BuildContext context, required String date, required String memo}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackBar.show(context, message: '로그인이 필요합니다.', backgroundColor: Colors.red, icon: Icons.error);
      return;
    }

    try {
      final userDocRef = FirebaseFirestore.instance.collection('dogs').doc(user.uid);

      await userDocRef.update({
        'health': FieldValue.arrayRemove([
          {'date': date, 'memo': memo},
        ]),
      });

      ref.read(healthRecordProvider.notifier).state = ref
          .read(healthRecordProvider)
          .where((record) => record.date != date || record.memo != memo)
          .toList();

      CustomSnackBar.show(context, message: '건강 기록이 삭제되었습니다.', backgroundColor: Colors.red, icon: Icons.check_circle);
    } catch (e) {
      CustomSnackBar.show(context, message: '오류가 발생했습니다: $e', backgroundColor: Colors.red, icon: Icons.error);
    }
  }
}