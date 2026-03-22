import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillconnect/data/models/provider_model.dart';

abstract class FirebaseRemoteDataSource {
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signUpWithEmail(
    String email,
    String password,
    String name, {
    String userType = 'client',
    String? businessName,
    String? category,
    double? baseRate,
    String? bio,
  });
  Future<String?> getUserType(String uid);
  Future<void> signOut();
  Future<List<ProviderModel>> getProvidersByCategory(String category);
  Future<void> createBooking(Map<String, dynamic> bookingData);
  Future<void> deleteBooking(String bookingId);
  Future<void> updateBookingStatus(String bookingId, String status);
  Future<void> sendPasswordResetEmail(String email);
}

class FirebaseRemoteDataSourceImpl implements FirebaseRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  @override
  Future<User?> signUpWithEmail(
    String email,
    String password,
    String name, {
    String userType = 'client',
    String? businessName,
    String? category,
    double? baseRate,
    String? bio,
  }) async {
    // NUCLEAR PRINT: This MUST show up in the terminal if the button is working
    print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    print('!!! SIGNUP STARTED FOR: $email');
    print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    dev.log('SIGNUP: Starting Auth for $email', name: 'SkillConnect');
    
    try {
      dev.log('SIGNUP: Calling createUserWithEmailAndPassword (20s timeout)...', name: 'SkillConnect');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          dev.log('SIGNUP: ERROR - Firebase Auth timed out!', name: 'SkillConnect');
          throw Exception('Auth Timeout');
        },
      );

      if (credential.user != null) {
        final uid = credential.user!.uid;
        dev.log('SIGNUP: Auth Success. UID: $uid', name: 'SkillConnect');
        
        final userData = {
          'uid': uid,
          'email': email,
          'displayName': name,
          'userType': userType,
          'createdAt': FieldValue.serverTimestamp(),
          'balance': 0,
        };

        dev.log('SIGNUP: Writing to users collection (15s timeout)...', name: 'SkillConnect');
        await _firestore.collection('users').doc(uid).set(userData).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            dev.log('SIGNUP: ERROR - Users collection write timed out!', name: 'SkillConnect');
            throw Exception('Firestore Timeout');
          },
        );
        dev.log('SIGNUP: Users collection write successful', name: 'SkillConnect');

        if (userType == 'provider') {
          dev.log('SIGNUP: Writing to providers collection (15s timeout)...', name: 'SkillConnect');
          await _firestore.collection('providers').doc(uid).set({
            'pid': uid,
            'businessName': businessName ?? '',
            'category': category ?? '',
            'baseRate': baseRate ?? 0.0,
            'bio': bio ?? '',
            'rating': 0.0,
            'ratingCount': 0,
            'verificationStatus': 'pending',
            'portfolioImages': [],
            'totalEarnings': 0.0,
          }).timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              dev.log('SIGNUP: ERROR - Providers collection write timed out!', name: 'SkillConnect');
              throw Exception('Firestore Timeout (Provider)');
            },
          );
          dev.log('SIGNUP: Providers collection write successful', name: 'SkillConnect');
        }
        
        return credential.user;
      }
    } catch (e) {
      dev.log('SIGNUP: CRITICAL ERROR: $e', name: 'SkillConnect', error: e);
      print('!!! SIGNUP FAILED: $e');
      rethrow;
    }
    return null;
  }

  @override
  Future<String?> getUserType(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['userType'] as String?;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<List<ProviderModel>> getProvidersByCategory(String category) async {
    final query = await _firestore
        .collection('providers')
        .where('category', isEqualTo: category)
        .get();
    return query.docs.map((doc) => ProviderModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> createBooking(Map<String, dynamic> bookingData) async {
    await _firestore.collection('bookings').add(bookingData);
  }

  @override
  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).delete();
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({'status': status});
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
