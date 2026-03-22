import 'package:skillconnect/domain/entities/provider_entity.dart';

abstract class ProviderRepository {
  Future<List<ProviderEntity>> getProvidersByCategory(String category);
  Future<void> bookProvider(String providerId, String serviceId, int amount);
  Future<void> cancelBooking(String bookingId);
  Future<void> acceptBooking(String bookingId);
  Future<UserEntity?> getUserProfile(String uid);
  Future<ProviderEntity?> getProviderProfile(String uid);
  Stream<List<BookingEntity>> getBookingsStream(String uid, String userType);
}
