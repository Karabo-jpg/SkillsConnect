import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String bid;
  final String clientId;
  final String providerId;
  final String serviceName;
  final DateTime bookingDate;
  final DateTime? scheduledDate;
  final double depositAmount;
  final String status;
  final String notes;

  const BookingEntity({
    required this.bid,
    required this.clientId,
    required this.providerId,
    required this.serviceName,
    required this.bookingDate,
    this.scheduledDate,
    required this.depositAmount,
    required this.status,
    this.notes = '',
  });

  @override
  List<Object?> get props => [bid, clientId, providerId, serviceName, bookingDate, scheduledDate, depositAmount, status, notes];
}
