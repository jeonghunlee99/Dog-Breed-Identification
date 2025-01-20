import 'package:firebase_auth/firebase_auth.dart';
import 'login_data.dart';

class LoginController {
  final LoginModel _loginModel = LoginModel();

  // Google 로그인
  Future<void> signInWithGoogle(Function onSuccess, Function onFailure) async {
    bool success = await _loginModel.signInWithGoogle();
    if (success) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        bool hasProfile = await _loginModel.checkUserProfile(user.uid);
        if (hasProfile) {
          onSuccess();
        } else {
          onFailure();
        }
      }
    } else {
      onFailure();
    }
  }

  // Kakao 로그인
  Future<void> signInWithKakao(Function onSuccess, Function onFailure) async {
    bool success = await _loginModel.signInWithKakao();
    if (success) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        bool hasProfile = await _loginModel.checkUserProfile(user.uid);
        if (hasProfile) {
          onSuccess();
        } else {
          onFailure();
        }
      }
    } else {
      onFailure();
    }
  }
}
