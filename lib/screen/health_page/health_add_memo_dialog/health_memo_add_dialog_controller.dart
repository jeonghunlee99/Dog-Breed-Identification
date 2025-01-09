import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widget/custom_snackbar.dart';
import '../health_memo_screen/health_memo_data.dart';

class HealthMemoAddDialogController {
  WidgetRef ref;

  HealthMemoAddDialogController({required this.ref});


  Future<void> saveHealthRecord({required BuildContext parentContext, required String date, required String memo}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackBar.show(
        parentContext,
        message: '로그인이 필요합니다.',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
      return;
    }

    try {
      final userDocRef = FirebaseFirestore.instance.collection('dogs').doc(user.uid);

      await userDocRef.update({
        'health': FieldValue.arrayUnion([
          {'date': date, 'memo': memo},
        ]),
      });
      ref
          .read(healthRecordProvider.notifier)
          .state = [
        ...ref.read(healthRecordProvider),
        HealthRecordState(date: date, memo: memo),
      ];

      CustomSnackBar.show(
        parentContext,
        message: '건강 기록이 저장되었습니다.',
        backgroundColor: Colors.green,
        icon: Icons.check_circle,
      );
    } catch (e) {
      CustomSnackBar.show(
        parentContext,
        message: '오류가 발생했습니다: $e',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }
}