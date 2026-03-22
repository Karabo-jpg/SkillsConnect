import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillconnect/data/models/provider_model.dart';

abstract class FirebaseRemoteDataSource {
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signUpWithEmail(String email, String password, String name);
  Future<void> signOut();
  Future<List<ProviderModel>> getProvidersByCategory(String category);
  Future<void> createBooking(Map<String, dynamic> bookingData);
  Future<void> deleteBooking(String bookingId);
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
  Future<User?> signUpWithEmail(String email, String password, String name) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'displayName': name,
        'userType': 'client',
      });
    }
    return credential.user;
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
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
