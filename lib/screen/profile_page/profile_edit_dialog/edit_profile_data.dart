import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveProfile(String name, String breed, String age) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }

    final String uid = currentUser.uid;
    final data = {
      'name': name,
      'breed': breed,
      'age': age,
    };

    try {
      await _firestore.collection('dogs').doc(uid).get().then((doc) {
        if (doc.exists) {
          _firestore.collection('dogs').doc(uid).update(data);
        } else {
          _firestore.collection('dogs').doc(uid).set(data);
        }
      });
    } catch (e) {
      throw Exception('저장 실패: $e');
    }
  }
}