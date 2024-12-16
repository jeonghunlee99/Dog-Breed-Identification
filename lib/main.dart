import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screen/homepage.dart';
import 'dart:developer';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: 'asset/config/.env');

  // 네이버맵 SDK 초기화
  await NaverMapSdk.instance.initialize(
    clientId: dotenv.env['clientId']!, // 클라이언트 ID 설정
    onAuthFailed: (e) => log("네이버맵 인증오류: $e", name: "onAuthFailed"),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('ko', 'KR'), // 기본 로케일 설정
        supportedLocales: const [
          Locale('en', 'US'), // 영어
          Locale('ko', 'KR'), // 한국어
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(), // 홈 페이지 연결
      ),
    );
  }
}
