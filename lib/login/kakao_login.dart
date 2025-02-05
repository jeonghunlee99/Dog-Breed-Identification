import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao_user;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'social_login.dart';

class KakaoLogin implements SocialLogin {
  @override
  Future<bool> login() async {
    try {
      var provider = firebase_auth.OAuthProvider("oidc.dogbreedidentification");
      OAuthToken token = await kakao_user.UserApi.instance.loginWithKakaoAccount();
      var credential = provider.credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );
      firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
      return true;
    } catch (e) {
      print("Kakao 로그인 실패: $e");
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await kakao_user.UserApi.instance.unlink();
      return true;
    } catch (error) {
      print("Kakao 로그아웃 실패: $error");
      return false;
    }
  }

  Future<String?> getUserName() async {
    try {
      // 사용자 닉네임 가져오기
      kakao_user.User user = await kakao_user.UserApi.instance.me();
      return user.kakaoAccount?.profile?.nickname;
    } catch (error) {
      print("Kakao 사용자 정보 가져오기 실패: $error");
      return null;
    }
  }
}
