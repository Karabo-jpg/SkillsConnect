import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillconnect/domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.bid,
    required super.clientId,
    required super.providerId,
    required super.serviceName,
    required super.bookingDate,
    required super.depositAmount,
    required super.status,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime parsedDate;
    try {
      final raw = data['bookingDate'];
      if (raw is Timestamp) {
        parsedDate = raw.toDate();
      } else {
        parsedDate = DateTime.now();
      }
    } catch (_) {
      parsedDate = DateTime.now();
    }
    return BookingModel(
      bid: doc.id,
      clientId: data['clientId'] ?? '',
      providerId: data['providerId'] ?? '',
      serviceName: data['serviceName'] ?? data['serviceId'] ?? '',
      bookingDate: parsedDate,
      depositAmount: (data['depositAmount'] ?? data['totalAmount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      'providerId': providerId,
      'serviceName': serviceName,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'depositAmount': depositAmount,
      'status': status,
    };
  }
}
