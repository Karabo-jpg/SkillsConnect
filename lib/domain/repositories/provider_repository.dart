import 'package:skillconnect/domain/entities/provider_entity.dart';
import 'package:skillconnect/domain/entities/booking_entity.dart';

abstract class ProviderRepository {
  Future<List<ProviderEntity>> getProvidersByCategory(String category);
  Future<void> bookProvider(String providerId, String serviceId, int amount, {String notes = '', DateTime? scheduledDate});
  Future<void> cancelBooking(String bookingId);
  Future<void> acceptBooking(String bookingId);
  Future<void> updateBookingStatus(String bookingId, String status);
  Future<void> updateBooking(String bookingId, Map<String, dynamic> data);
  Future<UserEntity?> getUserProfile(String uid);
  Future<ProviderEntity?> getProviderProfile(String uid);
  Stream<List<BookingEntity>> getBookingsStream(String uid, String userType);
  Future<String> getUserName(String uid);
  Future<String> getBusinessName(String providerId);
  Future<void> rateProvider(String providerId, String bookingId, double rating);
}
