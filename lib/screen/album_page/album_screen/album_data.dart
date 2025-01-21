import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'album_controller.dart';


final photoListProvider = StateNotifierProvider<PhotoListNotifier, List<String>>((ref) {
  return PhotoListNotifier(ref);
});

// 로딩 상태 관리 (StateProvider)
final isLoadingProvider = StateProvider<bool>((ref) => false);
