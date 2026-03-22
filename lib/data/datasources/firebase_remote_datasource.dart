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
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
      print('DEBUG: Auth successful. UID: ${credential.user!.uid}');
      
      final userData = {
        'uid': credential.user!.uid,
        'email': email,
        'displayName': name,
        'userType': userType,
        'createdAt': FieldValue.serverTimestamp(),
        'balance': 0, // Initial balance
      };

      try {
        print('DEBUG: Attempting to write to Firestore users collection...');
        await _firestore.collection('users').doc(credential.user!.uid).set(userData);
        print('DEBUG: Successfully wrote to Firestore users collection.');
      } catch (e) {
        print('DEBUG: ERROR writing to users collection: $e');
        rethrow;
      }

      if (userType == 'provider') {
        try {
          print('DEBUG: Attempting to write to Firestore providers collection...');
          await _firestore.collection('providers').doc(credential.user!.uid).set({
            'pid': credential.user!.uid,
            'businessName': businessName ?? '',
            'category': category ?? '',
            'baseRate': baseRate ?? 0.0,
            'bio': bio ?? '',
            'rating': 0.0,
            'ratingCount': 0,
            'verificationStatus': 'pending',
            'portfolioImages': [],
            'totalEarnings': 0.0,
          });
          print('DEBUG: Successfully wrote to Firestore providers collection.');
        } catch (e) {
          print('DEBUG: ERROR writing to providers collection: $e');
          rethrow;
        }
      }
    }
    return credential.user;
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
