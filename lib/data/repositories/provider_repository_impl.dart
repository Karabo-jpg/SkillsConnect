import 'package:skillconnect/data/datasources/firebase_remote_datasource.dart';
import 'package:skillconnect/domain/entities/provider_entity.dart';
import 'package:skillconnect/domain/repositories/provider_repository.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  final FirebaseRemoteDataSource remoteDataSource;

  ProviderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProviderEntity>> getProvidersByCategory(String category) async {
    return await remoteDataSource.getProvidersByCategory(category);
  }

  @override
  Future<void> bookProvider(String providerId, String serviceId, int amount) async {
    final bookingData = {
      'providerId': providerId,
      'serviceId': serviceId,
      'totalAmount': amount,
      'status': 'confirmed',
    };
    await remoteDataSource.createBooking(bookingData);
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await remoteDataSource.deleteBooking(bookingId);
  }

  @override
  Future<void> acceptBooking(String bookingId) async {
    await remoteDataSource.updateBookingStatus(bookingId, 'confirmed');
  }
}
