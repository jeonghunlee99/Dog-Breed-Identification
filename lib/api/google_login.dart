import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../class/social_login.dart';

class GoogleLogin implements SocialLogin {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<bool> login() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // 사용자가 로그인 취소
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final firebase_auth.AuthCredential credential =
      firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase_auth.UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      final firebase_auth.User? user = userCredential.user;

      if (user != null) {
        print("Google 로그인 성공: ${user.displayName}");
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print("Google 로그인 실패: $error");
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _googleSignIn.signOut();
      return true;
    } catch (e) {
      print("Google 로그아웃 실패: $e");
      return false;
    }
  }
}
