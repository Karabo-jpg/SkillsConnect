import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<User?> signIn(String email, String password);
  Future<User?> signUp(
    String email,
    String password,
    String name, {
    String? userType,
    String? businessName,
    String? category,
    double? baseRate,
    String? bio,
    String? profileImageBase64,
  });
  Future<String?> getUserType(String uid);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Stream<User?> get user;
}
