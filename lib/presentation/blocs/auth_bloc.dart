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
  SignUpRequested(this.email, this.password, this.name);

  @override
  List<Object?> get props => [email, password, name];
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
  Authenticated(this.user);

  @override
  List<Object?> get props => [user];
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
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    await emit.forEach<User?>(
      repository.user,
      onData: (user) => user != null ? Authenticated(user) : Unauthenticated(),
    );
  }

  Future<void> _onLogInRequested(LogInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await repository.signIn(event.email, event.password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await repository.signUp(event.email, event.password, event.name);
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
