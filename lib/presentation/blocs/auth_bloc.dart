import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillconnect/domain/repositories/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}
class LogInRequested extends AuthEvent {
  final String email;
  final String password;
  LogInRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String userType;
  final String? businessName;
  final String? category;
  final double? baseRate;
  final String? bio;

  SignUpRequested(
    this.email,
    this.password,
    this.name, {
    this.userType = 'client',
    this.businessName,
    this.category,
    this.baseRate,
    this.bio,
  });

  @override
  List<Object?> get props => [email, password, name, userType, businessName, category, baseRate, bio];
}

class AuthSendPasswordResetRequested extends AuthEvent {
  final String email;
  AuthSendPasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class LogOutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final User user;
  final String userType;
  Authenticated(this.user, this.userType);

  @override
  List<Object?> get props => [user, userType];
}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LogInRequested>(_onLogInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<AuthSendPasswordResetRequested>(_onAuthSendPasswordResetRequested);
    on<LogOutRequested>(_onLogOutRequested);
    on<_FetchUserTypeSubEvent>(_onFetchUserType);
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    await emit.forEach<User?>(
      repository.user,
      onData: (user) {
        if (user != null) {
          // Trigger user type fetch
          add(_FetchUserTypeSubEvent(user));
          return AuthLoading();
        }
        return Unauthenticated();
      },
    );
  }

  // Add this to your events or as a private class
  // For simplicity, I'll add the handler here
  Future<void> _onFetchUserType(_FetchUserTypeSubEvent event, Emitter<AuthState> emit) async {
    final userType = await repository.getUserType(event.user.uid);
    emit(Authenticated(event.user, userType ?? 'client'));
  }
}

class _FetchUserTypeSubEvent extends AuthEvent {
  final User user;
  _FetchUserTypeSubEvent(this.user);
  @override
  List<Object?> get props => [user];
}

  Future<void> _onLogInRequested(LogInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await repository.signIn(event.email, event.password);
      if (user != null) {
        final userType = await repository.getUserType(user.uid);
        emit(Authenticated(user, userType ?? 'client'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await repository.signUp(
        event.email,
        event.password,
        event.name,
        userType: event.userType,
        businessName: event.businessName,
        category: event.category,
        baseRate: event.baseRate,
        bio: event.bio,
      );
      if (user != null) {
        emit(Authenticated(user, event.userType));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthSendPasswordResetRequested(
      AuthSendPasswordResetRequested event, Emitter<AuthState> emit) async {
    try {
      await repository.sendPasswordResetEmail(event.email);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogOutRequested(LogOutRequested event, Emitter<AuthState> emit) async {
    await repository.signOut();
  }
}
