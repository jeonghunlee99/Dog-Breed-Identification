import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isLoggedInProvider = StreamProvider<bool>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((user) => user != null);
});

final dogNameProvider = StateProvider<String>((ref) => '');
final dogBreedProvider = StateProvider<String>((ref) => '');
final dogAgeProvider = StateProvider<String>((ref) => '');
