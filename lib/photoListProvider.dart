import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 사진 리스트 관리 (StateNotifierProvider)
final photoListProvider = StateNotifierProvider<PhotoListNotifier, List<String>>((ref) {
  return PhotoListNotifier(ref);
});

// 로딩 상태 관리 (StateProvider)
final isLoadingProvider = StateProvider<bool>((ref) => false);

// 사진 리스트 상태를 관리하는 Notifier
class PhotoListNotifier extends StateNotifier<List<String>> {
  final Ref ref;

  PhotoListNotifier(this.ref) : super([]);

  // 사진 URL 불러오기
  Future<void> loadPhotos() async {
    try {
      ref
          .read(isLoadingProvider.notifier)
          .state = true; // 로딩 시작

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final storageRef = FirebaseStorage.instance.ref().child(
          'dog_photos/${user.uid}');
      final listResult = await storageRef.listAll();

      final urls = await Future.wait(
        listResult.items.map((item) => item.getDownloadURL()),
      );

      state = urls; // 상태 업데이트
    } catch (e) {
      print('Error loading photos: $e');
    } finally {
      ref
          .read(isLoadingProvider.notifier)
          .state = false; // 로딩 종료
    }
  }

  // 사진 추가
  Future<void> addPhoto(String photoUrl) async {
    state = [...state, photoUrl]; // URL을 상태에 추가

    // 추가된 사진을 Firebase에 저장
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final storageRef = FirebaseStorage.instance.ref().child(
          'dog_photos/${user.uid}/${DateTime
              .now()
              .millisecondsSinceEpoch}.jpg');


      // 새로운 사진 추가 후 상태 업데이트
    } catch (e) {
      print('Error adding photo: $e');
    }
  }

  // 사진 삭제
  Future<void> deletePhoto(String photoUrl) async {
    try {
      final storageRef = FirebaseStorage.instance.refFromURL(photoUrl);
      await storageRef.delete();

      // 삭제 후 상태 업데이트
      state = state.where((url) => url != photoUrl).toList();
    } catch (e) {
      print('Error deleting photo: $e');
    }
  }

  void reset() {
    state = []; // 상태 초기화
  }
}