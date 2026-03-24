import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skillconnect/domain/entities/provider_entity.dart';
import 'package:skillconnect/domain/entities/booking_entity.dart';
import 'package:skillconnect/domain/repositories/provider_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Events
abstract class ProviderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProvidersByCategory extends ProviderEvent {
  final String category;
  LoadProvidersByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class CancelBooking extends ProviderEvent {
  final String bookingId;
  CancelBooking(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class AcceptBooking extends ProviderEvent {
  final String bookingId;
  AcceptBooking(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class LoadProviderDashboard extends ProviderEvent {
  final String providerId;
  LoadProviderDashboard(this.providerId);

  @override
  List<Object?> get props => [providerId];
}

class UpdateBookings extends ProviderEvent {
  final List<BookingEntity> bookings;
  UpdateBookings(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

/// Event to create a new booking in Firestore
class CreateBookingEvent extends ProviderEvent {
  final String providerId;
  final String serviceName;
  final int amount;
  final String notes;
  final DateTime? scheduledDate;

  CreateBookingEvent({
    required this.providerId,
    required this.serviceName,
    required this.amount,
    this.notes = '',
    this.scheduledDate,
  });

  @override
  List<Object?> get props => [providerId, serviceName, amount, notes, scheduledDate];
}

/// Event to update a booking's status (provider side)
class UpdateBookingStatusEvent extends ProviderEvent {
  final String bookingId;
  final String newStatus;
  UpdateBookingStatusEvent({required this.bookingId, required this.newStatus});

  @override
  List<Object?> get props => [bookingId, newStatus];
}

/// Event to edit booking details (client side - notes, scheduledDate)
class EditBookingEvent extends ProviderEvent {
  final String bookingId;
  final String? notes;
  final DateTime? scheduledDate;
  EditBookingEvent({required this.bookingId, this.notes, this.scheduledDate});

  @override
  List<Object?> get props => [bookingId, notes, scheduledDate];
}

/// Event to delete a booking (client side)
class DeleteBookingEvent extends ProviderEvent {
  final String bookingId;
  DeleteBookingEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

// States
abstract class ProviderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProviderInitial extends ProviderState {}
class ProviderLoading extends ProviderState {}
class ProviderLoaded extends ProviderState {
  final List<ProviderEntity> providers;
  ProviderLoaded(this.providers);

  @override
  List<Object?> get props => [providers];
}
class ProviderError extends ProviderState {
  final String message;
  ProviderError(this.message);

  @override
  List<Object?> get props => [message];
}

class DashboardLoaded extends ProviderState {
  final ProviderEntity profile;
  final List<BookingEntity> bookings;
  DashboardLoaded({required this.profile, required this.bookings});

  @override
  List<Object?> get props => [profile, bookings];
}

/// State emitted when a booking is successfully created
class BookingSuccess extends ProviderState {}

/// State emitted when a booking operation (edit/delete/status) succeeds
class BookingOperationSuccess extends ProviderState {
  final String message;
  BookingOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ProviderBloc extends Bloc<ProviderEvent, ProviderState> {
  final ProviderRepository repository;

  ProviderBloc({required this.repository}) : super(ProviderInitial()) {
    on<LoadProvidersByCategory>((event, emit) async {
      emit(ProviderLoading());
      try {
        final providers = await repository.getProvidersByCategory(event.category);
        emit(ProviderLoaded(providers));
      } catch (e) {
        emit(ProviderError(e.toString()));
      }
    });

    on<CancelBooking>((event, emit) async {
      try {
        await repository.cancelBooking(event.bookingId);
        emit(BookingOperationSuccess('Booking cancelled'));
      } catch (e) {
        emit(ProviderError(e.toString()));
      }
    });

    on<AcceptBooking>((event, emit) async {
      try {
        await repository.acceptBooking(event.bookingId);
        emit(BookingOperationSuccess('Booking accepted'));
      } catch (e) {
        emit(ProviderError(e.toString()));
      }
    });

    on<UpdateBookingStatusEvent>((event, emit) async {
      try {
        await repository.updateBookingStatus(event.bookingId, event.newStatus);
        emit(BookingOperationSuccess('Status updated to ${event.newStatus}'));
      } catch (e) {
        emit(ProviderError(e.toString()));
      }
    });

    on<EditBookingEvent>((event, emit) async {
      try {
        final data = <String, dynamic>{};
        if (event.notes != null) data['notes'] = event.notes;
        if (event.scheduledDate != null) {
          data['scheduledDate'] = Timestamp.fromDate(event.scheduledDate!);
        }
        await repository.updateBooking(event.bookingId, data);
        emit(BookingOperationSuccess('Booking updated'));
      } catch (e) {
        emit(ProviderError(e.toString()));
      }
    });

    on<DeleteBookingEvent>((event, emit) async {
      try {
        await repository.cancelBooking(event.bookingId);
        emit(BookingOperationSuccess('Booking deleted'));
      } catch (e) {
        emit(ProviderError(e.toString()));
      }
    });

    on<LoadProviderDashboard>((event, emit) async {
      emit(ProviderLoading());
      try {
        final profile = await repository.getProviderProfile(event.providerId);
        if (profile != null) {
          repository.getBookingsStream(event.providerId, 'provider').listen((bookings) {
            add(UpdateBookings(bookings));
          });
          emit(DashboardLoaded(profile: profile, bookings: []));
        } else {
          emit(ProviderError('Profile not found'));
        }
      } catch (e) {
        emit(ProviderError(e.toString()));
      }
    });

    on<UpdateBookings>((event, emit) {
      if (state is DashboardLoaded) {
        final currentState = state as DashboardLoaded;
        emit(DashboardLoaded(profile: currentState.profile, bookings: event.bookings));
      }
    });

    on<CreateBookingEvent>((event, emit) async {
      try {
        await repository.bookProvider(
          event.providerId,
          event.serviceName,
          event.amount,
          notes: event.notes,
          scheduledDate: event.scheduledDate,
        );
        emit(BookingSuccess());
      } catch (e) {
        emit(ProviderError(e.toString()));
      }
    });
  }
}
