import 'package:skillconnect/data/datasources/firebase_remote_datasource.dart';
import 'package:skillconnect/domain/entities/provider_entity.dart';
import 'package:skillconnect/domain/entities/booking_entity.dart';
import 'package:skillconnect/domain/repositories/provider_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  final FirebaseRemoteDataSource remoteDataSource;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProviderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProviderEntity>> getProvidersByCategory(String category) async {
    return await remoteDataSource.getProvidersByCategory(category);
  }

  @override
  Future<void> bookProvider(String providerId, String serviceId, int amount, {String notes = '', DateTime? scheduledDate}) async {
    final uid = _auth.currentUser?.uid ?? '';
    final bookingData = {
      'clientId': uid,
      'providerId': providerId,
      'serviceName': serviceId,
      'totalAmount': amount,
      'depositAmount': amount.toDouble(),
      'bookingDate': DateTime.now(),
      'scheduledDate': scheduledDate != null ? Timestamp.fromDate(scheduledDate) : null,
      'status': 'pending',
      'notes': notes,
    };
    await remoteDataSource.createBooking(bookingData);
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await remoteDataSource.deleteBooking(bookingId);
  }

  @override
  Future<void> acceptBooking(String bookingId) async {
    await remoteDataSource.updateBookingStatus(bookingId, 'accepted');
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await remoteDataSource.updateBookingStatus(bookingId, status);
  }

  @override
  Future<void> updateBooking(String bookingId, Map<String, dynamic> data) async {
    await remoteDataSource.updateBooking(bookingId, data);
  }

  @override
  Future<UserEntity?> getUserProfile(String uid) async {
    return await remoteDataSource.getUserProfile(uid);
  }

  @override
  Future<ProviderEntity?> getProviderProfile(String uid) async {
    return await remoteDataSource.getProviderProfile(uid);
  }

  @override
  Stream<List<BookingEntity>> getBookingsStream(String uid, String userType) {
    return remoteDataSource.getBookingsStream(uid, userType);
  }

  @override
  Future<String> getUserName(String uid) async {
    return await remoteDataSource.getUserName(uid);
  }

  @override
  Future<String> getBusinessName(String providerId) async {
    return await remoteDataSource.getBusinessName(providerId);
  }

  @override
  Future<void> rateProvider(String providerId, String bookingId, double rating) async {
    await remoteDataSource.rateProvider(providerId, bookingId, rating);
  }
}
