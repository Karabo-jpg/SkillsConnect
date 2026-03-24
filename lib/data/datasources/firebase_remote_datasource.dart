import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillconnect/data/models/provider_model.dart';
import 'package:skillconnect/data/models/booking_model.dart';

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
  Future<UserModel?> getUserProfile(String uid);
  Future<ProviderModel?> getProviderProfile(String uid);
  Stream<List<BookingModel>> getBookingsStream(String uid, String userType);
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
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Authentication timed out. Please try again.');
        },
      );

      if (credential.user != null) {
        final uid = credential.user!.uid;
        
        final userData = {
          'uid': uid,
          'email': email,
          'displayName': name,
          'userType': userType,
          'createdAt': FieldValue.serverTimestamp(),
          'balance': 0,
        };

        await _firestore.collection('users').doc(uid).set(userData).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception('Database write timed out. Please try again.');
          },
        );

        if (userType == 'provider') {
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
              throw Exception('Database write timed out. Please try again.');
            },
          );
        }
        
        return credential.user;
      }
    } catch (e) {
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
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<ProviderModel?> getProviderProfile(String uid) async {
    final doc = await _firestore.collection('providers').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return ProviderModel.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Stream<List<BookingModel>> getBookingsStream(String uid, String userType) {
    final field = userType == 'provider' ? 'providerId' : 'clientId';
    return _firestore
        .collection('bookings')
        .where(field, isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
