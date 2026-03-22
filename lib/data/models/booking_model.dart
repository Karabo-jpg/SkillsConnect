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
    return BookingModel(
      bid: doc.id,
      clientId: data['clientId'] ?? '',
      providerId: data['providerId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      bookingDate: (data['bookingDate'] as Timestamp).toDate(),
      depositAmount: (data['depositAmount'] ?? 0.0).toDouble(),
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
