import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../api/google_login.dart';
import '../api/kakao_login.dart';
import 'dog_start_profile.dart';
import 'homepage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleLogin _googleLogin = GoogleLogin();
  final KakaoLogin _kakaoLogin = KakaoLogin();

  Future<void> _signInWithGoogle() async {
    bool success = await _googleLogin.login();
    if (success) {
      // Firebase에서 로그인한 사용자 확인
      User? user = FirebaseAuth.instance.currentUser; // Firebase 인증을 통해 현재 사용자 가져오기
      if (user != null) {
        await _checkUserProfile(user.uid); // Firestore에서 사용자 프로필 확인
      }
    } else {
      print("Google 로그인 실패");
    }
  }


  // Kakao 로그인 처리
  Future<void> _signInWithKakao() async {
    bool success = await _kakaoLogin.login();
    if (success) {
      // Firebase에서 로그인한 사용자 확인
      User? user = FirebaseAuth.instance.currentUser; // Firebase 인증을 통해 현재 사용자 가져오기
      if (user != null) {
        await _checkUserProfile(user.uid); // Firestore에서 사용자 프로필 확인
      }
    } else {
      print("Kakao 로그인 실패");
    }
  }

  Future<void> _checkUserProfile(String uid) async {
    final docRef = FirebaseFirestore.instance.collection('dogs').doc(uid); // Firestore에서 uid 문서 확인
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // 프로필이 있으면 홈 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // 프로필이 없으면 프로필 작성 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DogStartProfilePage()), // 회원가입 페이지
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/dog.gif'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 40,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 30),
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '간편로그인으로 더 다양한,\n서비스를 이용하세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _signInWithGoogle,
                      child: Image.asset('asset/google_sign.png',
                          width: 200, height: 45, fit: BoxFit.cover),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: _signInWithKakao,
                      child: Image.asset('asset/kakao_login.png',
                          width: 200, height: 45, fit: BoxFit.cover),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






