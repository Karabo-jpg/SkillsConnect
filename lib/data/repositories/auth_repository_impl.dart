import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillconnect/data/datasources/firebase_remote_datasource.dart';
import 'package:skillconnect/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseRemoteDataSource remoteDataSource;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User?> signIn(String email, String password) {
    return remoteDataSource.signInWithEmail(email, password);
  }

  @override
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
  }) {
    return remoteDataSource.signUpWithEmail(
      email,
      password,
      name,
      userType: userType ?? 'client',
      businessName: businessName,
      category: category,
      baseRate: baseRate,
      bio: bio,
      profileImageBase64: profileImageBase64,
    );
  }

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<String?> getUserType(String uid) {
    return remoteDataSource.getUserType(uid);
  }

  @override
  Stream<User?> get user => _firebaseAuth.authStateChanges();
}
