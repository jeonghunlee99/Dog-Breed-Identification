import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart'; // geolocator 추가

import '../widget/navigator.dart';

class DogInformationPage extends StatefulWidget {
  const DogInformationPage({super.key});

  @override
  State<DogInformationPage> createState() => _DogInformationPageState();
}

class _DogInformationPageState extends State<DogInformationPage> {
  int _currentIndex = 1;
  final Completer<NaverMapController> mapControllerCompleter = Completer();
  double? latitude;  // 위도 값을 nullable로 변경
  double? longitude; // 경도 값을 nullable로 변경

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // 초기 위치 가져오기
  }

  // 현재 위치를 가져오는 함수
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화되어 있으면 예외 처리
      return;
    }

    // 위치 권한을 요청
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 권한이 거부된 경우 예외 처리
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 권한이 영구적으로 거부된 경우 예외 처리
      return;
    }

    // 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('강아지 건강')),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 여백을 주어 지도와 화면 경계를 띄움
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), // 둥근 모서리 설정
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2), // 그림자 위치 설정
              ),
            ],
          ),
          child: latitude == null || longitude == null // 위치 정보가 없으면 로딩 화면
              ? const Center(child: CircularProgressIndicator())
              : NaverMap(
            options: const NaverMapViewOptions(
              indoorEnable: true, // 실내 맵 사용 가능 여부 설정
              locationButtonEnable: false, // 위치 버튼 표시 여부 설정
              consumeSymbolTapEvents: false, // 심볼 탭 이벤트 소비 여부 설정
            ),
            onMapReady: (controller) async {
              // 지도 준비 완료 시 호출되는 콜백 함수
              mapControllerCompleter.complete(controller); // Completer에 지도 컨트롤러 완료 신호 전송

              // 서울특별시청을 중심으로 설정한 카메라 위치
              final cameraPosition = NCameraPosition(
                target: NLatLng(latitude!, longitude!), // 서울특별시청 위치
                zoom: 15, // 줌 레벨 15
                bearing: 45, // 방향 45도
                tilt: 30, // 기울기 30도
              );

              // 카메라 위치 업데이트
              await controller.updateCamera(NCameraUpdate.fromCameraPosition(cameraPosition));

              // 애니메이션을 이용해 카메라 이동
              final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
                target: NLatLng(latitude!, longitude!), // 서울특별시청 위치로 이동
                zoom: 18, // 줌 레벨 18로 설정
              );

              // 애니메이션 설정 후 카메라 업데이트
              cameraUpdate.setAnimation(animation: NCameraAnimation.fly, duration: Duration(seconds: 2));

              await controller.updateCamera(cameraUpdate); // 애니메이션을 이용한 카메라 이동
            },
          )

        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
