import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String bid;
  final String clientId;
  final String providerId;
  final String serviceName;
  final DateTime bookingDate;
  final double depositAmount;
  final String status;

  const BookingEntity({
    required this.bid,
    required this.clientId,
    required this.providerId,
    required this.serviceName,
    required this.bookingDate,
    required this.depositAmount,
    required this.status,
  });

  @override
  List<Object?> get props => [bid, clientId, providerId, serviceName, bookingDate, depositAmount, status];
}
