import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_breed_identification/screen/profile_page/profile_screen/profile_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../album_page/album_screen/album_data.dart';






class ProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchDogProfile(WidgetRef ref, BuildContext context) async {
    final user = _auth.currentUser;

    // user가 null인 경우는 로그아웃된 상태이므로, 데이터 가져오지 않음
    if (user == null) {
      if (context.mounted) {
        ref.read(dogNameProvider.notifier).state = '정보 없음';
        ref.read(dogBreedProvider.notifier).state = '정보 없음';
        ref.read(dogAgeProvider.notifier).state = '정보 없음';
      }
      return; // 로그아웃 상태라면 fetchDogProfile 호출을 종료
    }

    try {
      final doc = await _firestore.collection('dogs').doc(user.uid).get();
      if (doc.exists) {
        // 위젯이 아직 화면에 있는지 확인
        if (context.mounted) {
          ref.read(dogNameProvider.notifier).state = doc['name'] ?? '알 수 없음';
          ref.read(dogBreedProvider.notifier).state = doc['breed'] ?? '알 수 없음';
          ref.read(dogAgeProvider.notifier).state = doc['age'] ?? '알 수 없음';
        }
      } else {
        if (context.mounted) {
          ref.read(dogNameProvider.notifier).state = '정보 없음';
          ref.read(dogBreedProvider.notifier).state = '정보 없음';
          ref.read(dogAgeProvider.notifier).state = '정보 없음';
        }
      }
    } catch (e) {
      print('Firestore 데이터 가져오기 실패: $e');
    }
  }


  Future<void> logout(WidgetRef ref, Function onLogoutSuccess, Function onLogoutError) async {
    try {
      await _auth.signOut();
      ref.invalidate(dogNameProvider);
      ref.invalidate(dogBreedProvider);
      ref.invalidate(dogAgeProvider);
      ref.read(photoListProvider.notifier).reset();
      onLogoutSuccess();
    } catch (error) {
      onLogoutError(error);
    }
  }
}
