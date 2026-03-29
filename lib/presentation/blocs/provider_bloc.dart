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

/// Event to rate a provider (client side)
class RateProviderEvent extends ProviderEvent {
  final String providerId;
  final String bookingId;
  final double rating;
  RateProviderEvent({required this.providerId, required this.bookingId, required this.rating});

  @override
  List<Object?> get props => [providerId, bookingId, rating];
}

// States
abstract class ProviderState extends Equatable {
  const ProviderState();

  @override
  List<Object?> get props => [];
}

class ProviderInitial extends ProviderState {
  const ProviderInitial();
}

class ProviderLoading extends ProviderState {
  const ProviderLoading();
}

class ProviderLoaded extends ProviderState {
  final List<ProviderEntity> providers;
  const ProviderLoaded(this.providers);
  @override
  List<Object?> get props => [providers];
}

class ProviderError extends ProviderState {
  final String message;
  const ProviderError(this.message);
  @override
  List<Object?> get props => [message];
}

class DashboardLoaded extends ProviderState {
  final ProviderEntity profile;
  final List<BookingEntity> bookings;
  const DashboardLoaded({required this.profile, required this.bookings});
  @override
  List<Object?> get props => [profile, bookings];
}

/// State emitted when a booking is successfully created
class BookingSuccess extends ProviderState {
  const BookingSuccess();
}

/// State emitted when a booking operation (edit/delete/status) succeeds
class BookingOperationSuccess extends ProviderState {
  final String? message;
  const BookingOperationSuccess([this.message]);
  @override
  List<Object?> get props => [message];
}

// Bloc
class ProviderBloc extends Bloc<ProviderEvent, ProviderState> {
  final ProviderRepository repository;

    ProviderBloc({required this.repository}) : super(const ProviderInitial()) {
    on<LoadProvidersByCategory>((event, emit) async {
      emit(const ProviderLoading());
      try {
        final providers = await repository.getProvidersByCategory(event.category);
        emit(ProviderLoaded(providers));
      } catch (e) {
          emit(ProviderError(e.toString()));
      }
    });

    on<CancelBooking>((event, emit) async {
      try {
            emit(const BookingSuccess());
        emit(const BookingOperationSuccess('Booking cancelled'));
        // If current state has profile, reload dashboard silently based on provider ID logic
        if (state is DashboardLoaded) {
           final currentState = state as DashboardLoaded;
           add(LoadProviderDashboard(currentState.profile.providerId));
        }
      } catch (e) {
          emit(ProviderError(e.toString()));
      }
    });

    on<AcceptBooking>((event, emit) async {
      try {
        await repository.acceptBooking(event.bookingId);
        emit(const BookingOperationSuccess('Booking accepted'));
      } catch (e) {
          emit(ProviderError(e.toString()));
      }
    });

    on<UpdateBookingStatusEvent>((event, emit) async {
      try {
        await repository.updateBookingStatus(event.bookingId, event.newStatus);
        
        // We don't emit BookingOperationSuccess here if we are on dashboard 
        // because it breaks the UI. The stream Listener in LoadProviderDashboard 
        // will automatically pick up the status change from Firestore and emit UpdateBookings!
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
        emit(const BookingOperationSuccess('Booking updated'));
      } catch (e) {
          emit(ProviderError(e.toString()));
      }
    });

    on<DeleteBookingEvent>((event, emit) async {
      try {
        await repository.cancelBooking(event.bookingId);
        emit(const BookingOperationSuccess('Booking deleted'));
      } catch (e) {
        emit(ProviderError(e.toString()));
      }
    });

    on<LoadProviderDashboard>((event, emit) async {
      emit(const ProviderLoading());
      try {
        final profile = await repository.getProviderProfile(event.providerId);
        if (profile != null) {
          // Listen to bookings stream, map through them and get client names
          repository.getBookingsStream(event.providerId, 'provider').listen((bookings) async {
            // Attach client names to the entities based on clientId if they aren't explicitly saved
            add(UpdateBookings(List.unmodifiable(bookings)));
          });
          // ignore: prefer_const_constructors
          emit(DashboardLoaded(profile: profile, bookings: const []));
        } else {
          emit(const ProviderError('Profile not found'));
        }
      } catch (e) {
        emit(ProviderError(e.toString()));
      }
    });

    on<UpdateBookings>((event, emit) {
      if (state is DashboardLoaded) {
        final currentState = state as DashboardLoaded;
        // ignore: prefer_const_constructors
        emit(DashboardLoaded(profile: currentState.profile, bookings: List.unmodifiable([...event.bookings])));
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
        emit(const BookingSuccess());
      } catch (e) {
        emit(ProviderError(e.toString()));
      }
    });

    on<RateProviderEvent>((event, emit) async {
      try {
        await repository.rateProvider(event.providerId, event.bookingId, event.rating);
        emit(BookingOperationSuccess('Rating submitted successfully!'));
      } catch (e) {
        emit(ProviderError(e.toString()));
      }
    });
  }
}
