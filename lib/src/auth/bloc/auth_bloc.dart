import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/auth_repository.dart';
import '../services/token_manager.dart';
import '../exceptions/auth_exception.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final TokenManager _tokenManager;

  AuthBloc({
    required AuthRepository authRepository,
    required TokenManager tokenManager,
  }) : _authRepository = authRepository,
       _tokenManager = tokenManager,
       super(const AuthState.initial()) {
    
    // Register event handlers
    on<AuthSignUpWithEmailEvent>(_onSignUpWithEmail);
    on<AuthVerifySignUpEvent>(_onVerifySignUp);
    on<AuthSignInWithEmailEvent>(_onSignInWithEmail);
    on<AuthVerifySignInEvent>(_onVerifySignIn);
    on<AuthSignUpEvent>(_onSignUp);
    on<AuthSignInWithPasswordEvent>(_onSignInWithPassword);
    on<AuthSignOutEvent>(_onSignOut);
    on<AuthRefreshSessionEvent>(_onRefreshSession);
    on<AuthUpdateUserEvent>(_onUpdateUser);
    on<AuthGetUserEvent>(_onGetUser);
    on<AuthResetPasswordForEmailEvent>(_onResetPasswordForEmail);
    on<AuthUpdatePasswordEvent>(_onUpdatePassword);
    on<AuthInitializeEvent>(_onInitialize);
    on<AuthClearErrorEvent>(_onClearError);

    // Initialize authentication state
    add(const AuthEvent.initialize());
  }

  Future<void> _onSignUpWithEmail(
    AuthSignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    try {
      final response = await _authRepository.signUpWithEmail(
        email: event.email,
        data: event.data,
      );

      if (response.isOtpSent) {
        emit(AuthState.otpSent(
          email: event.email,
          message: response.message ?? 'OTP sent to your email',
          type: 'signup',
        ));
      } else if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(AuthState.authenticated(
          user: response.user!,
          session: response.session!,
        ));
      } else {
        emit(AuthState.error(
          message: response.message ?? 'Sign up failed',
        ));
      }
    } catch (e) {
      emit(AuthState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onVerifySignUp(
    AuthVerifySignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    try {
      final response = await _authRepository.verifySignUp(
        email: event.email,
        token: event.token,
        password: event.password,
      );

      if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(AuthState.authenticated(
          user: response.user!,
          session: response.session!,
        ));
      } else {
        emit(AuthState.error(
          message: response.message ?? 'Verification failed',
        ));
      }
    } catch (e) {
      emit(AuthState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    try {
      final response = await _authRepository.signInWithEmail(
        email: event.email,
      );

      if (response.isOtpSent) {
        emit(AuthState.otpSent(
          email: event.email,
          message: response.message ?? 'OTP sent to your email',
          type: 'signin',
        ));
      } else if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(AuthState.authenticated(
          user: response.user!,
          session: response.session!,
        ));
      } else {
        emit(AuthState.error(
          message: response.message ?? 'Sign in failed',
        ));
      }
    } catch (e) {
      emit(AuthState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onVerifySignIn(
    AuthVerifySignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    try {
      final response = await _authRepository.verifySignIn(
        email: event.email,
        token: event.token,
      );

      if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(AuthState.authenticated(
          user: response.user!,
          session: response.session!,
        ));
      } else {
        emit(AuthState.error(
          message: response.message ?? 'Verification failed',
        ));
      }
    } catch (e) {
      emit(AuthState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onSignUp(
    AuthSignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    try {
      final response = await _authRepository.signUp(
        email: event.email,
        password: event.password,
        data: event.data,
      );

      if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(AuthState.authenticated(
          user: response.user!,
          session: response.session!,
        ));
      } else {
        emit(AuthState.error(
          message: response.message ?? 'Sign up failed',
        ));
      }
    } catch (e) {
      emit(AuthState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onSignInWithPassword(
    AuthSignInWithPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    try {
      final response = await _authRepository.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(AuthState.authenticated(
          user: response.user!,
          session: response.session!,
        ));
      } else {
        emit(AuthState.error(
          message: response.message ?? 'Sign in failed',
        ));
      }
    } catch (e) {
      emit(AuthState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    try {
      await _authRepository.signOut();
      await _tokenManager.clearSession();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      // Even if sign out fails on server, clear local session
      await _tokenManager.clearSession();
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onRefreshSession(
    AuthRefreshSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final refreshToken = event.refreshToken ?? 
                         await _tokenManager.getRefreshToken();
      
      if (refreshToken == null) {
        emit(const AuthState.unauthenticated());
        return;
      }

      final response = await _authRepository.refreshSession(
        refreshToken: refreshToken,
      );

      if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(AuthState.authenticated(
          user: response.user!,
          session: response.session!,
        ));
      } else {
        await _tokenManager.clearSession();
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      await _tokenManager.clearSession();
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onUpdateUser(
    AuthUpdateUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    try {
      final response = await _authRepository.updateUser(
        email: event.email,
        password: event.password,
        data: event.data,
      );

      emit(AuthState.userUpdated(
        user: response.user,
        message: response.message,
      ));
    } catch (e) {
      emit(AuthState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onGetUser(
    AuthGetUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _authRepository.getUser();
      final session = await _tokenManager.getStoredSession();
      
      if (user != null && session != null) {
        emit(AuthState.authenticated(user: user, session: session));
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onResetPasswordForEmail(
    AuthResetPasswordForEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    try {
      final response = await _authRepository.resetPasswordForEmail(
        email: event.email,
      );

      emit(AuthState.passwordResetSent(
        email: event.email,
        message: response.message,
      ));
    } catch (e) {
      emit(AuthState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onUpdatePassword(
    AuthUpdatePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    try {
      final response = await _authRepository.updatePassword(
        email: event.email,
        token: event.token,
        password: event.password,
      );

      if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(AuthState.authenticated(
          user: response.user!,
          session: response.session!,
        ));
      } else {
        emit(AuthState.userUpdated(
          user: response.user!,
          message: response.message ?? 'Password updated successfully',
        ));
      }
    } catch (e) {
      emit(AuthState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onInitialize(
    AuthInitializeEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final session = await _tokenManager.getStoredSession();
      
      if (session == null) {
        emit(const AuthState.unauthenticated());
        return;
      }

      if (session.isExpired) {
        // Try to refresh the session
        add(AuthEvent.refreshSession(refreshToken: session.refreshToken));
        return;
      }

      emit(AuthState.authenticated(
        user: session.user,
        session: session,
      ));
    } catch (e) {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onClearError(
    AuthClearErrorEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthErrorState) {
      emit(const AuthState.initial());
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    }
    return error.toString();
  }

  String? _getErrorCode(dynamic error) {
    if (error is AuthException) {
      return error.code;
    }
    return null;
  }
}