import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillconnect/domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.bid,
    required super.clientId,
    required super.providerId,
    required super.serviceName,
    required super.bookingDate,
    super.scheduledDate,
    required super.depositAmount,
    required super.status,
    super.notes = '',
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

    DateTime? parsedScheduledDate;
    try {
      final raw = data['scheduledDate'];
      if (raw is Timestamp) {
        parsedScheduledDate = raw.toDate();
      }
    } catch (_) {
      // ignore
    }

    return BookingModel(
      bid: doc.id,
      clientId: data['clientId'] ?? '',
      providerId: data['providerId'] ?? '',
      serviceName: data['serviceName'] ?? data['serviceId'] ?? '',
      bookingDate: parsedDate,
      scheduledDate: parsedScheduledDate,
      depositAmount: (data['depositAmount'] ?? data['totalAmount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      'providerId': providerId,
      'serviceName': serviceName,
      'bookingDate': Timestamp.fromDate(bookingDate),
      if (scheduledDate != null) 'scheduledDate': Timestamp.fromDate(scheduledDate!),
      'depositAmount': depositAmount,
      'status': status,
      'notes': notes,
    };
  }
}
