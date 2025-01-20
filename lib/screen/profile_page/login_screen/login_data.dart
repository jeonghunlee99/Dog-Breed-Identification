import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../api/google_login.dart';
import '../../../api/kakao_login.dart';


class LoginModel {
  final GoogleLogin _googleLogin = GoogleLogin();
  final KakaoLogin _kakaoLogin = KakaoLogin();

  // Google 로그인 처리
  Future<bool> signInWithGoogle() async {
    return await _googleLogin.login();
  }

  // Kakao 로그인 처리
  Future<bool> signInWithKakao() async {
    return await _kakaoLogin.login();
  }

  // Firestore에서 사용자 프로필 확인
  Future<bool> checkUserProfile(String uid) async {
    final docRef = FirebaseFirestore.instance.collection('dogs').doc(uid);
    final docSnapshot = await docRef.get();
    return docSnapshot.exists;
  }
}
