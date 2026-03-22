import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skillconnect/domain/entities/provider_entity.dart';
import 'package:skillconnect/domain/repositories/provider_repository.dart';

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
        emit(ProviderInitial()); 
      } catch (e) {
        emit(ProviderError(e.toString()));
      }
    });

    on<AcceptBooking>((event, emit) async {
      try {
        await repository.acceptBooking(event.bookingId);
        emit(ProviderInitial()); 
      } catch (e) {
        emit(ProviderError(e.toString()));
      }
    });
  }
}
