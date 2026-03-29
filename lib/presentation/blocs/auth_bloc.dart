import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillconnect/domain/repositories/auth_repository.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

/// Base class for all authentication-related BLoC events.
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Fired on app startup to check whether a Firebase user session already exists.
///
/// [AuthBloc] listens to [AuthRepository.user] stream; if a user is found it
/// dispatches [_FetchUserTypeSubEvent] to load their role from Firestore.
class AuthCheckRequested extends AuthEvent {}

/// Requests email/password sign-in via [AuthRepository.signIn].
///
/// On success emits [Authenticated]; on failure emits [AuthError] with the
/// Firebase exception message so the UI can display a meaningful snack bar.
class LogInRequested extends AuthEvent {
  final String email;
  final String password;
  LogInRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

/// Requests account creation for either a client or a service provider.
///
/// Required fields: [email], [password], [name].
/// Provider-only optional fields: [businessName], [category], [baseRate], [bio].
/// These are forwarded to [AuthRepository.signUp] which writes the appropriate
/// Firestore documents (`users` and optionally `providers`).
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

/// Sends a Firebase password-reset email to [email].
///
/// Does not transition to a new state on success; the UI shows a
/// confirmation [SnackBar] directly. On failure emits [AuthError].
class AuthSendPasswordResetRequested extends AuthEvent {
  final String email;
  AuthSendPasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Signs the current user out and returns the app to [Unauthenticated] state.
class LogOutRequested extends AuthEvent {}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

/// Base class for all authentication states emitted by [AuthBloc].
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state before any auth check has been performed.
class AuthInitial extends AuthState {}

/// Emitted while an async auth operation (sign-in, sign-up, etc.) is in progress.
/// The UI should show a loading indicator and disable interaction.
class AuthLoading extends AuthState {}

/// Emitted when a valid Firebase user session exists.
///
/// [user] is the Firebase [User] object.
/// [userType] is either `'client'` or `'provider'`, fetched from Firestore.
/// The root widget uses this state to route users to the correct home screen.
class Authenticated extends AuthState {
  final User user;
  final String userType;
  Authenticated(this.user, this.userType);

  @override
  List<Object?> get props => [user, userType];
}

/// Emitted when no authenticated session exists (logged out or first launch).
class Unauthenticated extends AuthState {}

/// Emitted when an auth operation fails.
///
/// [message] contains the Firebase exception description and is displayed
/// to the user via a [SnackBar] in the listening widget.
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// Bloc
// ---------------------------------------------------------------------------

/// Manages authentication state for the entire application.
///
/// Handles user session persistence, sign-in, sign-up, sign-out, and
/// password reset by delegating all Firebase calls to [AuthRepository].
///
/// State flow:
/// ```
/// AuthInitial -> AuthCheckRequested -> AuthLoading -> Authenticated | Unauthenticated
/// Unauthenticated -> LogInRequested -> AuthLoading -> Authenticated | AuthError
/// Unauthenticated -> SignUpRequested -> AuthLoading -> Authenticated | AuthError
/// Authenticated -> LogOutRequested -> Unauthenticated
/// ```
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

  /// Subscribes to the Firebase auth stream on startup.
  ///
  /// Uses [emit.forEach] so the BLoC stays subscribed across the app's lifetime.
  /// When a user logs back in after a restart, this handler automatically
  /// fetches their user type and emits [Authenticated].
  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    await emit.forEach<User?>(
      repository.user,
      onData: (user) {
        if (user != null) {
          add(_FetchUserTypeSubEvent(user));
          return AuthLoading();
        }
        return Unauthenticated();
      },
    );
  }

  /// Internal sub-event handler that loads a user's role from Firestore.
  ///
  /// Separated from [_onAuthCheckRequested] because [emit.forEach] does not
  /// allow secondary async calls inside its callback; dispatching a new event
  /// is the recommended BLoC pattern for this scenario.
  Future<void> _onFetchUserType(_FetchUserTypeSubEvent event, Emitter<AuthState> emit) async {
    final userType = await repository.getUserType(event.user.uid);
    emit(Authenticated(event.user, userType ?? 'client'));
  }

  /// Handles email/password sign-in.
  ///
  /// Emits [AuthLoading] while the Firebase call is in flight, then either
  /// [Authenticated] (with the resolved user type) or [AuthError].
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

  /// Handles new account creation for both clients and providers.
  ///
  /// Delegates to [AuthRepository.signUp] which creates the Firebase Auth user,
  /// writes the `users` document, and (if provider) writes the `providers` document.
  /// Emits [Authenticated] immediately on success so the user lands on their
  /// home screen without needing to log in separately.
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

class _FetchUserTypeSubEvent extends AuthEvent {
  final User user;
  _FetchUserTypeSubEvent(this.user);
  @override
  List<Object?> get props => [user];
}