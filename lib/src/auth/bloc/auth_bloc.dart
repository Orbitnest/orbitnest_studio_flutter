import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/auth_repository.dart';
import '../services/token_manager.dart';
import '../services/passkey_authenticator_service.dart';
import '../models/passkey_device.dart';
import '../models/session.dart';
import '../exceptions/auth_exception.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final TokenManager _tokenManager;
  final PasskeyAuthenticatorService _passkeyAuthenticator;

  AuthBloc({
    required AuthRepository authRepository,
    required TokenManager tokenManager,
    PasskeyAuthenticatorService? passkeyAuthenticator,
  })  : _authRepository = authRepository,
        _tokenManager = tokenManager,
        _passkeyAuthenticator =
            passkeyAuthenticator ?? PasskeyAuthenticatorService(),
        super(const AuthInitialState()) {
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
    on<AuthRegisterPasskeyEvent>(_onRegisterPasskey);
    on<AuthSignInWithPasskeyEvent>(_onSignInWithPasskey);
    on<AuthSignUpWithPasskeyEvent>(_onSignUpWithPasskey);
    on<AuthListPasskeysEvent>(_onListPasskeys);
    on<AuthRenamePasskeyEvent>(_onRenamePasskey);
    on<AuthRevokePasskeyEvent>(_onRevokePasskey);

    // Register refresh callback with token manager
    _tokenManager.setRefreshCallback(_performTokenRefresh);

    // Initialize authentication state
    add(const AuthInitializeEvent());
  }

  /// Perform token refresh for token manager callback
  Future<bool> _performTokenRefresh() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final response = await _authRepository.refreshSession(
        refreshToken: refreshToken,
      );

      if (response.isAuthenticated && response.session != null) {
        await _tokenManager.storeSession(response.session!);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _onSignUpWithEmail(
    AuthSignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final response = await _authRepository.signUpWithEmail(
        email: event.email,
        data: event.data,
      );

      if (response.isOtpSent) {
        emit(
          AuthOtpSentState(
            email: event.email,
            message: response.message ?? 'OTP sent to your email',
            type: 'signup',
          ),
        );
      } else if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(
          AuthAuthenticatedState(
            user: response.user!,
            session: response.session!,
          ),
        );
      } else {
        emit(AuthErrorState(message: response.message ?? 'Sign up failed'));
      }
    } catch (e) {
      emit(
        AuthErrorState(message: _getErrorMessage(e), code: _getErrorCode(e)),
      );
    }
  }

  Future<void> _onVerifySignUp(
    AuthVerifySignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final response = await _authRepository.verifySignUp(
        email: event.email,
        token: event.token,
        password: event.password,
      );

      if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(
          AuthAuthenticatedState(
            user: response.user!,
            session: response.session!,
          ),
        );
      } else {
        emit(
          AuthErrorState(message: response.message ?? 'Verification failed'),
        );
      }
    } catch (e) {
      emit(
        AuthErrorState(message: _getErrorMessage(e), code: _getErrorCode(e)),
      );
    }
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final response = await _authRepository.signInWithEmail(
        email: event.email,
      );

      if (response.isOtpSent) {
        emit(
          AuthOtpSentState(
            email: event.email,
            message: response.message ?? 'OTP sent to your email',
            type: 'signin',
          ),
        );
      } else if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(
          AuthAuthenticatedState(
            user: response.user!,
            session: response.session!,
          ),
        );
      } else {
        emit(AuthErrorState(message: response.message ?? 'Sign in failed'));
      }
    } catch (e) {
      emit(
        AuthErrorState(message: _getErrorMessage(e), code: _getErrorCode(e)),
      );
    }
  }

  Future<void> _onVerifySignIn(
    AuthVerifySignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final response = await _authRepository.verifySignIn(
        email: event.email,
        token: event.token,
      );

      if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(
          AuthAuthenticatedState(
            user: response.user!,
            session: response.session!,
          ),
        );
      } else {
        emit(
          AuthErrorState(message: response.message ?? 'Verification failed'),
        );
      }
    } catch (e) {
      emit(
        AuthErrorState(message: _getErrorMessage(e), code: _getErrorCode(e)),
      );
    }
  }

  Future<void> _onSignUp(AuthSignUpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());

    try {
      final response = await _authRepository.signUp(
        email: event.email,
        password: event.password,
        data: event.data,
      );

      if (response.isOtpSent) {
        emit(
          AuthOtpSentState(
            email: event.email,
            message: response.message ?? 'OTP sent to your email',
            type: 'signup',
          ),
        );
      } else if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(
          AuthAuthenticatedState(
            user: response.user!,
            session: response.session!,
          ),
        );
      } else {
        emit(AuthErrorState(message: response.message ?? 'Sign up failed'));
      }
    } catch (e) {
      emit(
        AuthErrorState(message: _getErrorMessage(e), code: _getErrorCode(e)),
      );
    }
  }

  Future<void> _onSignInWithPassword(
    AuthSignInWithPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final response = await _authRepository.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(
          AuthAuthenticatedState(
            user: response.user!,
            session: response.session!,
          ),
        );
      } else {
        emit(AuthErrorState(message: response.message ?? 'Sign in failed'));
      }
    } catch (e) {
      emit(
        AuthErrorState(message: _getErrorMessage(e), code: _getErrorCode(e)),
      );
    }
  }

  Future<void> _onSignOut(
    AuthSignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      await _authRepository.signOut();
      await _tokenManager.clearSession();
      emit(const AuthUnauthenticatedState());
    } catch (e) {
      // Even if sign out fails on server, clear local session
      await _tokenManager.clearSession();
      emit(const AuthUnauthenticatedState());
    }
  }

  Future<void> _onRefreshSession(
    AuthRefreshSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final refreshToken =
          event.refreshToken ?? await _tokenManager.getRefreshToken();

      if (refreshToken == null) {
        emit(const AuthUnauthenticatedState());
        return;
      }

      final response = await _authRepository.refreshSession(
        refreshToken: refreshToken,
      );

      if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(
          AuthAuthenticatedState(
            user: response.user!,
            session: response.session!,
          ),
        );
      } else {
        await _tokenManager.clearSession();
        emit(const AuthUnauthenticatedState());
      }
    } catch (e) {
      await _tokenManager.clearSession();
      emit(const AuthUnauthenticatedState());
    }
  }

  Future<void> _onUpdateUser(
    AuthUpdateUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final response = await _authRepository.updateUser(
        email: event.email,
        password: event.password,
        data: event.data,
      );

      // Persist updated user into stored session so it survives app restarts.
      // Without this, _onInitialize would restore the stale user (without
      // display_name) on next launch.
      try {
        final currentSession = await _tokenManager.getStoredSession();
        if (currentSession != null) {
          await _tokenManager.storeSession(
            currentSession.copyWith(user: response.user),
          );
        }
      } catch (sessionError) {
        // Non-fatal – user is updated in memory even if storage fails
      }

      emit(
        AuthUserUpdatedState(user: response.user, message: response.message),
      );
    } catch (e) {
      emit(
        AuthErrorState(message: _getErrorMessage(e), code: _getErrorCode(e)),
      );
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
        emit(AuthAuthenticatedState(user: user, session: session));
      } else {
        emit(const AuthUnauthenticatedState());
      }
    } catch (e) {
      emit(
        AuthErrorState(message: _getErrorMessage(e), code: _getErrorCode(e)),
      );
    }
  }

  Future<void> _onResetPasswordForEmail(
    AuthResetPasswordForEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final response = await _authRepository.resetPasswordForEmail(
        email: event.email,
      );

      emit(
        AuthPasswordResetSentState(
          email: event.email,
          message: response.message,
        ),
      );
    } catch (e) {
      emit(
        AuthErrorState(message: _getErrorMessage(e), code: _getErrorCode(e)),
      );
    }
  }

  Future<void> _onUpdatePassword(
    AuthUpdatePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final response = await _authRepository.updatePassword(
        email: event.email,
        token: event.token,
        password: event.password,
      );

      if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(
          AuthAuthenticatedState(
            user: response.user!,
            session: response.session!,
          ),
        );
      } else {
        emit(
          AuthUserUpdatedState(
            user: response.user!,
            message: response.message ?? 'Password updated successfully',
          ),
        );
      }
    } catch (e) {
      emit(
        AuthErrorState(message: _getErrorMessage(e), code: _getErrorCode(e)),
      );
    }
  }

  Future<void> _onInitialize(
    AuthInitializeEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final session = await _tokenManager.getStoredSession();

      if (session == null) {
        emit(const AuthUnauthenticatedState());
        return;
      }

      // Check if token needs refresh (expired or expiring within 5 minutes)
      final accessTokenExpired = _tokenManager.isTokenExpired(
        session.accessToken,
      );
      final accessTokenExpiringSoon = _tokenManager.needsRefresh(
        session.accessToken,
      );

      if (accessTokenExpired || accessTokenExpiringSoon) {
        // Try to refresh the session asynchronously
        add(AuthRefreshSessionEvent(refreshToken: session.refreshToken));

        // Still emit authenticated state with current session while refresh is in progress
        // The refresh will update the session when complete
        if (!accessTokenExpired) {
          emit(AuthAuthenticatedState(user: session.user, session: session));
        }
        return;
      }

      emit(AuthAuthenticatedState(user: session.user, session: session));

      // Kick off a background fetch of the latest user profile so any stale
      // stored session (e.g. missing user_metadata set in a previous app run
      // right before a crash / force-quit) is reconciled with the server on
      // next launch. Fire-and-forget — the in-memory state is already emitted
      // above so the UI is unblocked.
      unawaited(_reconcileStoredUserFromServer(session));
    } catch (e) {
      emit(const AuthUnauthenticatedState());
    }
  }

  /// Fetch the authoritative user record from GET /auth/user and, if it
  /// differs from the one in the stored session, persist the fresher copy
  /// back to secure storage. This keeps `user_metadata` (display_name, etc.)
  /// from going stale across app restarts — the upper app layer
  /// (AppAuthBloc) is responsible for emitting the refreshed UI state via
  /// its own `refreshCurrentUser` pathway; here we only fix the persistence
  /// so that *subsequent* cold starts see the latest user.
  Future<void> _reconcileStoredUserFromServer(Session currentSession) async {
    try {
      final freshUser = await _authRepository.getUser();
      if (freshUser == null) return;

      // If the server copy already matches what we have in storage, skip
      // the extra write.
      final inMemoryMetadata = currentSession.user.userMetadata;
      final freshMetadata = freshUser.userMetadata;
      final metadataChanged =
          (inMemoryMetadata?.toString() ?? '') !=
          (freshMetadata?.toString() ?? '');
      if (!metadataChanged &&
          currentSession.user.email == freshUser.email &&
          currentSession.user.id == freshUser.id) {
        return;
      }

      final updatedSession = currentSession.copyWith(user: freshUser);
      await _tokenManager.storeSession(updatedSession);
    } catch (e) {
      // Background user reconciliation failed (non-fatal)
    }
  }

  Future<void> _onClearError(
    AuthClearErrorEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthErrorState) {
      emit(const AuthInitialState());
    }
  }

  // ── Passkey handlers ──────────────────────────────────────────────────────

  Future<void> _onRegisterPasskey(
    AuthRegisterPasskeyEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final options = await _authRepository.passkeyRegisterOptions(
        deviceName: event.deviceName,
      );
      final attestation = await _passkeyAuthenticator.register(
        Map<String, dynamic>.from(options['publicKey'] as Map),
      );
      final saved = await _authRepository.passkeyRegisterVerify(
        challengeId: options['challenge_id'] as String,
        attestation: attestation,
        deviceName: event.deviceName,
      );
      emit(AuthPasskeyRegisteredState(device: PasskeyDevice.fromJson(saved)));
    } catch (e) {
      emit(AuthErrorState(message: _getErrorMessage(e), code: _getErrorCode(e)));
    }
  }

  Future<void> _onSignInWithPasskey(
    AuthSignInWithPasskeyEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final options = await _authRepository.passkeyLoginOptions(
        identifier: event.identifier,
      );
      final assertion = await _passkeyAuthenticator.authenticate(
        Map<String, dynamic>.from(options['publicKey'] as Map),
      );
      final response = await _authRepository.passkeyLoginVerify(
        challengeId: options['challenge_id'] as String,
        assertion: assertion,
      );
      if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(AuthAuthenticatedState(
          user: response.user!,
          session: response.session!,
        ));
      } else {
        emit(AuthErrorState(
          message: response.message ?? 'Passkey sign-in failed',
        ));
      }
    } catch (e) {
      emit(AuthErrorState(message: _getErrorMessage(e), code: _getErrorCode(e)));
    }
  }

  Future<void> _onSignUpWithPasskey(
    AuthSignUpWithPasskeyEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final options = await _authRepository.passkeySignupOptions(
        email: event.email,
        userMetadata: event.userMetadata,
        deviceName: event.deviceName,
      );
      final attestation = await _passkeyAuthenticator.register(
        Map<String, dynamic>.from(options['publicKey'] as Map),
      );
      final response = await _authRepository.passkeySignupVerify(
        challengeId: options['challenge_id'] as String,
        attestation: attestation,
        deviceName: event.deviceName,
      );
      if (response.isAuthenticated) {
        await _tokenManager.storeSession(response.session!);
        emit(AuthAuthenticatedState(
          user: response.user!,
          session: response.session!,
        ));
      } else {
        emit(AuthErrorState(
          message: response.message ?? 'Passkey sign-up failed',
        ));
      }
    } catch (e) {
      emit(AuthErrorState(message: _getErrorMessage(e), code: _getErrorCode(e)));
    }
  }

  Future<void> _onListPasskeys(
    AuthListPasskeysEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final raw = await _authRepository.listPasskeys();
      final devices = raw.map((j) => PasskeyDevice.fromJson(j)).toList();
      emit(AuthPasskeysListedState(devices: devices));
    } catch (e) {
      emit(AuthErrorState(message: _getErrorMessage(e), code: _getErrorCode(e)));
    }
  }

  Future<void> _onRenamePasskey(
    AuthRenamePasskeyEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.renamePasskey(
        deviceId: event.deviceId,
        deviceName: event.deviceName,
      );
      emit(AuthPasskeyUpdatedState(
        deviceId: event.deviceId,
        message: 'Passkey renamed',
      ));
    } catch (e) {
      emit(AuthErrorState(message: _getErrorMessage(e), code: _getErrorCode(e)));
    }
  }

  Future<void> _onRevokePasskey(
    AuthRevokePasskeyEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.revokePasskey(deviceId: event.deviceId);
      emit(AuthPasskeyRevokedState(deviceId: event.deviceId));
    } catch (e) {
      emit(AuthErrorState(message: _getErrorMessage(e), code: _getErrorCode(e)));
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
