import 'package:skillconnect/data/datasources/firebase_remote_datasource.dart';
import 'package:skillconnect/domain/entities/provider_entity.dart';
import 'package:skillconnect/domain/entities/booking_entity.dart';
import 'package:skillconnect/domain/repositories/provider_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  final FirebaseRemoteDataSource remoteDataSource;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProviderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProviderEntity>> getProvidersByCategory(String category) async {
    return await remoteDataSource.getProvidersByCategory(category);
  }

  @override
  Future<void> bookProvider(String providerId, String serviceId, int amount) async {
    final uid = _getClientUid();
    final bookingData = {
      'clientId': uid,
      'providerId': providerId,
      'serviceName': serviceId,
      'totalAmount': amount,
      'depositAmount': amount.toDouble(),
      'bookingDate': DateTime.now(),
      'status': 'confirmed',
    };
    await remoteDataSource.createBooking(bookingData);
  }

  String _getClientUid() {
    // Import firebase_auth to get current user
    try {
      final user = _auth.currentUser;
      return user?.uid ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await remoteDataSource.deleteBooking(bookingId);
  }

  @override
  Future<void> acceptBooking(String bookingId) async {
    await remoteDataSource.updateBookingStatus(bookingId, 'confirmed');
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
}
