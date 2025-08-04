# OrbitNest Flutter Package Implementation Guide

## Overview

This guide provides comprehensive instructions for implementing a Flutter package that integrates with the OrbitNest Studio backend system. The package will provide Supabase-compatible authentication and database operations for Flutter mobile applications.

## Package Architecture

### Package Structure
```
orbitnest_flutter/
├── lib/
│   ├── src/
│   │   ├── client/
│   │   │   ├── orbitnest_client.dart
│   │   │   └── http_client.dart
│   │   ├── auth/
│   │   │   ├── auth_client.dart
│   │   │   ├── auth_response.dart
│   │   │   ├── user.dart
│   │   │   ├── session.dart
│   │   │   └── auth_exception.dart
│   │   ├── database/
│   │   │   ├── database_client.dart
│   │   │   ├── query_builder.dart
│   │   │   ├── filter_builder.dart
│   │   │   ├── postgrest_response.dart
│   │   │   └── database_exception.dart
│   │   ├── edge_functions/
│   │   │   ├── edge_functions_client.dart
│   │   │   ├── function_response.dart
│   │   │   └── function_exception.dart
│   │   ├── logging/
│   │   │   ├── logging_client.dart
│   │   │   ├── log_entry.dart
│   │   │   └── log_query.dart
│   │   ├── constants/
│   │   │   └── constants.dart
│   │   ├── types/
│   │   │   ├── json_types.dart
│   │   │   └── response_types.dart
│   │   └── utils/
│   │       ├── token_manager.dart
│   │       ├── storage_helper.dart
│   │       └── validators.dart
│   └── orbitnest.dart
├── test/
├── example/
├── pubspec.yaml
├── README.md
├── CHANGELOG.md
└── LICENSE
```

## Core Dependencies

### pubspec.yaml
```yaml
name: orbitnest
description: Flutter client for OrbitNest Studio - Supabase-compatible backend as a service
version: 1.0.0
homepage: https://orbitnest.studio

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.0
  crypto: ^3.0.3
  collection: ^1.18.0
  meta: ^1.9.1
  jwt_decoder: ^2.0.1
  web_socket_channel: ^2.4.0
  uuid: ^4.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
  build_runner: ^2.4.6
  json_annotation: ^4.8.1
  json_serializable: ^6.7.1
  flutter_lints: ^3.0.0

flutter:
  # No specific Flutter configuration needed
```

## Main Client Implementation

### lib/orbitnest.dart (Main Export File)
```dart
library orbitnest;

// Core client
export 'src/client/orbitnest_client.dart';

// Authentication
export 'src/auth/auth_client.dart';
export 'src/auth/auth_response.dart';
export 'src/auth/user.dart';
export 'src/auth/session.dart';
export 'src/auth/auth_exception.dart';

// Database
export 'src/database/database_client.dart';
export 'src/database/query_builder.dart';
export 'src/database/filter_builder.dart';
export 'src/database/postgrest_response.dart';
export 'src/database/database_exception.dart';

// Edge Functions
export 'src/edge_functions/edge_functions_client.dart';
export 'src/edge_functions/function_response.dart';
export 'src/edge_functions/function_exception.dart';

// Logging
export 'src/logging/logging_client.dart';
export 'src/logging/log_entry.dart';
export 'src/logging/log_query.dart';

// Types
export 'src/types/json_types.dart';
export 'src/types/response_types.dart';

// Constants
export 'src/constants/constants.dart';
```

### lib/src/client/orbitnest_client.dart (Main Client)
```dart
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../auth/auth_client.dart';
import '../database/database_client.dart';
import '../edge_functions/edge_functions_client.dart';
import '../logging/logging_client.dart';
import '../utils/token_manager.dart';
import 'http_client.dart';

class OrbitNestClient {
  late final String _projectUrl;
  late final String _projectId;
  late final String _anonKey;
  late final String? _serviceRoleKey;
  late final HttpClient _httpClient;
  late final TokenManager _tokenManager;

  // Sub-clients
  late final AuthClient auth;
  late final DatabaseClient database;
  late final EdgeFunctionsClient functions;
  late final LoggingClient logging;

  // Private constructor for initialization
  OrbitNestClient._internal({
    required String projectUrl,
    required String projectId,
    required String anonKey,
    String? serviceRoleKey,
    Map<String, String>? headers,
    bool autoRefreshToken = true,
  }) {
    _projectUrl = projectUrl.endsWith('/') ? projectUrl.substring(0, projectUrl.length - 1) : projectUrl;
    _projectId = projectId;
    _anonKey = anonKey;
    _serviceRoleKey = serviceRoleKey;
    
    _httpClient = HttpClient(
      baseUrl: _projectUrl,
      defaultHeaders: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'apikey': _anonKey,
        ...?headers,
      },
    );

    _tokenManager = TokenManager(
      httpClient: _httpClient,
      autoRefresh: autoRefreshToken,
    );

    // Initialize sub-clients
    auth = AuthClient(
      httpClient: _httpClient,
      tokenManager: _tokenManager,
      projectId: _projectId,
    );

    database = DatabaseClient(
      httpClient: _httpClient,
      tokenManager: _tokenManager,
      projectId: _projectId,
    );

    functions = EdgeFunctionsClient(
      httpClient: _httpClient,
      tokenManager: _tokenManager,
      projectId: _projectId,
      projectUrl: _projectUrl,
    );

    logging = LoggingClient(
      httpClient: _httpClient,
      tokenManager: _tokenManager,
      projectId: _projectId,
    );
  }

  /// Create OrbitNest client instance
  factory OrbitNestClient.create({
    required String projectUrl,
    required String projectId,
    required String anonKey,
    String? serviceRoleKey,
    Map<String, String>? headers,
    bool autoRefreshToken = true,
  }) {
    return OrbitNestClient._internal(
      projectUrl: projectUrl,
      projectId: projectId,
      anonKey: anonKey,
      serviceRoleKey: serviceRoleKey,
      headers: headers,
      autoRefreshToken: autoRefreshToken,
    );
  }

  /// Get current project URL
  String get projectUrl => _projectUrl;

  /// Get anonymous key
  String get anonKey => _anonKey;

  /// Get service role key (if available)
  String? get serviceRoleKey => _serviceRoleKey;

  /// Get current session
  Session? get currentSession => _tokenManager.currentSession;

  /// Get current user
  User? get currentUser => _tokenManager.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _tokenManager.isAuthenticated;

  /// Listen to authentication state changes
  Stream<AuthState> get authStateChanges => _tokenManager.authStateChanges;

  /// Dispose resources
  void dispose() {
    _tokenManager.dispose();
    _httpClient.dispose();
  }
}

/// Authentication state enum
enum AuthState {
  signedIn,
  signedOut,
  tokenRefreshed,
  passwordRecovery,
}
```

## Authentication Implementation

### lib/src/auth/user.dart
```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  @JsonKey(name: 'email_confirmed_at')
  final DateTime? emailConfirmedAt;
  @JsonKey(name: 'phone_confirmed_at')
  final DateTime? phoneConfirmedAt;
  @JsonKey(name: 'last_sign_in_at')
  final DateTime? lastSignInAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'user_metadata')
  final Map<String, dynamic>? userMetadata;
  @JsonKey(name: 'app_metadata')
  final Map<String, dynamic>? appMetadata;

  const User({
    required this.id,
    required this.email,
    this.emailConfirmedAt,
    this.phoneConfirmedAt,
    this.lastSignInAt,
    required this.createdAt,
    required this.updatedAt,
    this.userMetadata,
    this.appMetadata,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    DateTime? emailConfirmedAt,
    DateTime? phoneConfirmedAt,
    DateTime? lastSignInAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? userMetadata,
    Map<String, dynamic>? appMetadata,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      emailConfirmedAt: emailConfirmedAt ?? this.emailConfirmedAt,
      phoneConfirmedAt: phoneConfirmedAt ?? this.phoneConfirmedAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userMetadata: userMetadata ?? this.userMetadata,
      appMetadata: appMetadata ?? this.appMetadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{id: $id, email: $email, emailConfirmedAt: $emailConfirmedAt}';
  }
}
```

### lib/src/auth/session.dart
```dart
import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'session.g.dart';

@JsonSerializable()
class Session {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  @JsonKey(name: 'expires_in')
  final int expiresIn;
  @JsonKey(name: 'expires_at')
  final int? expiresAt;
  @JsonKey(name: 'token_type')
  final String tokenType;
  final User user;

  const Session({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.expiresAt,
    this.tokenType = 'Bearer',
    required this.user,
  });

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);
  Map<String, dynamic> toJson() => _$SessionToJson(this);

  /// Check if session is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch > expiresAt! * 1000;
  }

  /// Get expiration time as DateTime
  DateTime? get expirationTime {
    if (expiresAt == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(expiresAt! * 1000);
  }

  Session copyWith({
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    int? expiresAt,
    String? tokenType,
    User? user,
  }) {
    return Session(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          user == other.user;

  @override
  int get hashCode => accessToken.hashCode ^ user.hashCode;

  @override
  String toString() {
    return 'Session{tokenType: $tokenType, user: ${user.email}, expiresAt: $expirationTime}';
  }
}
```

### lib/src/auth/auth_client.dart
```dart
import 'dart:async';
import 'dart:convert';

import '../client/http_client.dart';
import '../utils/token_manager.dart';
import 'auth_response.dart';
import 'auth_exception.dart';
import 'user.dart';
import 'session.dart';

class AuthClient {
  final HttpClient _httpClient;
  final TokenManager _tokenManager;
  final String _projectId;

  AuthClient({
    required HttpClient httpClient,
    required TokenManager tokenManager,
    required String projectId,
  })  : _httpClient = httpClient,
        _tokenManager = tokenManager,
        _projectId = projectId;

  /// Current user
  User? get currentUser => _tokenManager.currentUser;

  /// Current session
  Session? get currentSession => _tokenManager.currentSession;

  /// Listen to auth state changes
  Stream<AuthState> get onAuthStateChange => _tokenManager.authStateChanges;

  /// Email-first registration (OTP-based)
  Future<AuthResponse> signUpWithEmail({
    required String email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _httpClient.post(
        '/api/projects/$_projectId/auth/signup-with-email',
        body: {
          'email': email,
          if (password != null) 'password': password,
          if (data != null) 'data': data,
        },
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Verify signup with OTP
  Future<AuthResponse> verifySignup({
    required String email,
    required String token,
    String? password,
  }) async {
    try {
      final response = await _httpClient.post(
        '/api/projects/$_projectId/auth/verify-signup',
        body: {
          'email': email,
          'token': token,
          if (password != null) 'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);
      if (authResponse.session != null) {
        await _tokenManager.setSession(authResponse.session!);
      }

      return authResponse;
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Email/password signup (traditional)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _httpClient.post(
        '/api/projects/$_projectId/auth/signup',
        body: {
          'email': email,
          'password': password,
          if (data != null) 'data': data,
        },
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Email-only signin (passwordless OTP)
  Future<AuthResponse> signInWithEmail({
    required String email,
  }) async {
    try {
      final response = await _httpClient.post(
        '/api/projects/$_projectId/auth/signin-with-email',
        body: {'email': email},
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Verify signin with OTP
  Future<AuthResponse> verifySignin({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _httpClient.post(
        '/api/projects/$_projectId/auth/verify-signin',
        body: {
          'email': email,
          'token': token,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);
      if (authResponse.session != null) {
        await _tokenManager.setSession(authResponse.session!);
      }

      return authResponse;
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Email/password signin (traditional)
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        '/api/projects/$_projectId/auth/signin',
        body: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);
      if (authResponse.session != null) {
        await _tokenManager.setSession(authResponse.session!);
      }

      return authResponse;
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Request password recovery
  Future<AuthResponse> resetPasswordForEmail({
    required String email,
  }) async {
    try {
      final response = await _httpClient.post(
        '/api/projects/$_projectId/auth/recover',
        body: {'email': email},
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Reset password with OTP
  Future<AuthResponse> updatePassword({
    required String email,
    required String token,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        '/api/projects/$_projectId/auth/reset-password',
        body: {
          'email': email,
          'token': token,
          'password': password,
        },
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Update user metadata
  Future<AuthResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _httpClient.put(
        '/api/projects/$_projectId/auth/user',
        body: {
          if (email != null) 'email': email,
          if (password != null) 'password': password,
          if (data != null) 'data': data,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);
      if (authResponse.session != null) {
        await _tokenManager.setSession(authResponse.session!);
      }

      return authResponse;
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Get current user profile
  Future<User> getUser() async {
    try {
      final response = await _httpClient.get('/api/projects/$_projectId/auth/user');
      return User.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Refresh session
  Future<AuthResponse> refreshSession({String? refreshToken}) async {
    try {
      final token = refreshToken ?? currentSession?.refreshToken;
      if (token == null) {
        throw const AuthException('No refresh token available');
      }

      final response = await _httpClient.post(
        '/api/projects/$_projectId/auth/refresh',
        body: {'refresh_token': token},
      );

      final authResponse = AuthResponse.fromJson(response.data);
      if (authResponse.session != null) {
        await _tokenManager.setSession(authResponse.session!);
      }

      return authResponse;
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _httpClient.post(
        '/api/projects/$_projectId/auth/signout',
        body: {'scope': 'global'},
      );
    } catch (e) {
      // Continue with local signout even if server request fails
    } finally {
      await _tokenManager.removeSession();
    }
  }

  /// Admin endpoints (using service role key)
  
  /// Get user by ID (admin only)
  Future<User> getUserById(String userId) async {
    try {
      final response = await _httpClient.get(
        '/api/projects/$_projectId/auth/admin/users/$userId',
        useServiceRoleKey: true,
      );
      return User.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// List users (admin only)
  Future<List<User>> listUsers({
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _httpClient.get(
        '/api/projects/$_projectId/auth/admin/users',
        queryParameters: {
          if (page != null) 'page': page.toString(),
          if (perPage != null) 'per_page': perPage.toString(),
        },
        useServiceRoleKey: true,
      );

      final List<dynamic> users = response.data['users'] ?? [];
      return users.map((user) => User.fromJson(user)).toList();
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Create user (admin only)
  Future<User> createUser({
    required String email,
    required String password,
    Map<String, dynamic>? userMetadata,
    bool? emailConfirm,
  }) async {
    try {
      final response = await _httpClient.post(
        '/api/projects/$_projectId/auth/admin/users',
        body: {
          'email': email,
          'password': password,
          if (userMetadata != null) 'user_metadata': userMetadata,
          if (emailConfirm != null) 'email_confirm': emailConfirm,
        },
        useServiceRoleKey: true,
      );

      return User.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Delete user (admin only)
  Future<void> deleteUser(String userId) async {
    try {
      await _httpClient.delete(
        '/api/projects/$_projectId/auth/admin/users/$userId',
        useServiceRoleKey: true,
      );
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }
}

enum AuthState {
  signedIn,
  signedOut,
  tokenRefreshed,
  passwordRecovery,
}
```

## Database Operations Implementation

### lib/src/database/database_client.dart
```dart
import 'dart:async';

import '../client/http_client.dart';
import '../utils/token_manager.dart';
import 'query_builder.dart';
import 'postgrest_response.dart';
import 'database_exception.dart';

class DatabaseClient {
  final HttpClient _httpClient;
  final TokenManager _tokenManager;
  final String _projectId;

  DatabaseClient({
    required HttpClient httpClient,
    required TokenManager tokenManager,
    required String projectId,
  })  : _httpClient = httpClient,
        _tokenManager = tokenManager,
        _projectId = projectId;

  /// Create a query builder for a table
  QueryBuilder from(String table) {
    return QueryBuilder(
      httpClient: _httpClient,
      tokenManager: _tokenManager,
      projectId: _projectId,
      table: table,
    );
  }

  /// Execute raw SQL query
  Future<PostgrestResponse<List<Map<String, dynamic>>>> sql(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    try {
      final response = await _httpClient.post(
        '/api/projects/$_projectId/database/sql',
        body: {
          'query': query,
          if (variables != null) 'variables': variables,
        },
      );

      return PostgrestResponse<List<Map<String, dynamic>>>(
        data: List<Map<String, dynamic>>.from(response.data['data'] ?? []),
        status: response.statusCode,
        statusText: response.statusMessage,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Execute RPC (Remote Procedure Call)
  Future<PostgrestResponse<T>> rpc<T>(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _httpClient.post(
        '/api/projects/$_projectId/database/rpc/$functionName',
        body: params ?? {},
      );

      return PostgrestResponse<T>(
        data: response.data['data'] as T,
        status: response.statusCode,
        statusText: response.statusMessage,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Create a new table
  Future<void> createTable(
    String tableName,
    Map<String, String> columns, {
    List<String>? primaryKey,
    Map<String, String>? foreignKeys,
  }) async {
    try {
      await _httpClient.post(
        '/api/projects/$_projectId/database/tables',
        body: {
          'table_name': tableName,
          'columns': columns,
          if (primaryKey != null) 'primary_key': primaryKey,
          if (foreignKeys != null) 'foreign_keys': foreignKeys,
        },
        useServiceRoleKey: true,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Drop a table
  Future<void> dropTable(String tableName, {bool cascade = false}) async {
    try {
      await _httpClient.delete(
        '/api/projects/$_projectId/database/tables/$tableName',
        queryParameters: {
          if (cascade) 'cascade': 'true',
        },
        useServiceRoleKey: true,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Get table schema
  Future<Map<String, dynamic>> getTableSchema(String tableName) async {
    try {
      final response = await _httpClient.get('/api/projects/$_projectId/database/tables/$tableName');
      return response.data;
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// List all tables
  Future<List<String>> listTables() async {
    try {
      final response = await _httpClient.get('/api/projects/$_projectId/database/tables/list');
      final List<dynamic> tables = response.data['tables'] ?? [];
      return tables.map((table) => table['table_name'] as String).toList();
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Enable Row Level Security on a table
  Future<void> enableRLS(String tableName) async {
    try {
      await _httpClient.post(
        '/api/projects/$_projectId/database/tables/$tableName/rls/enable',
        useServiceRoleKey: true,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Disable Row Level Security on a table
  Future<void> disableRLS(String tableName) async {
    try {
      await _httpClient.post(
        '/api/projects/$_projectId/database/tables/$tableName/rls/disable',
        useServiceRoleKey: true,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Create RLS policy
  Future<void> createPolicy({
    required String tableName,
    required String policyName,
    required String command, // SELECT, INSERT, UPDATE, DELETE
    required String using,
    String? withCheck,
  }) async {
    try {
      await _httpClient.post(
        '/api/projects/$_projectId/database/tables/$tableName/policies',
        body: {
          'policy_name': policyName,
          'command': command,
          'using': using,
          if (withCheck != null) 'with_check': withCheck,
        },
        useServiceRoleKey: true,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// List policies for a table
  Future<List<Map<String, dynamic>>> listPolicies(String tableName) async {
    try {
      final response = await _httpClient.get('/api/projects/$_projectId/database/tables/$tableName/policies');
      final List<dynamic> policies = response.data['policies'] ?? [];
      return policies.cast<Map<String, dynamic>>();
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Delete a policy
  Future<void> deletePolicy(String tableName, String policyName) async {
    try {
      await _httpClient.delete(
        '/api/projects/$_projectId/database/tables/$tableName/policies/$policyName',
        useServiceRoleKey: true,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }
}
```

### lib/src/database/query_builder.dart
```dart
import 'dart:async';

import '../client/http_client.dart';
import '../utils/token_manager.dart';
import 'filter_builder.dart';
import 'postgrest_response.dart';
import 'database_exception.dart';

class QueryBuilder<T> {
  final HttpClient _httpClient;
  final TokenManager _tokenManager;
  final String _projectId;
  final String _table;
  final List<String> _selectColumns = [];
  final List<String> _conditions = [];
  final List<String> _orderBy = [];
  int? _limit;
  int? _offset;
  String? _range;

  QueryBuilder({
    required HttpClient httpClient,
    required TokenManager tokenManager,
    required String projectId,
    required String table,
  })  : _httpClient = httpClient,
        _tokenManager = tokenManager,
        _projectId = projectId,
        _table = table;

  /// Select specific columns
  QueryBuilder<T> select([String columns = '*']) {
    _selectColumns.clear();
    if (columns != '*') {
      _selectColumns.addAll(columns.split(',').map((col) => col.trim()));
    }
    return this;
  }

  /// Add filter conditions
  FilterBuilder<T> filter(String column, String operator, dynamic value) {
    return FilterBuilder<T>(
      queryBuilder: this,
      column: column,
      operator: operator,
      value: value,
    );
  }

  /// Equal filter shorthand
  QueryBuilder<T> eq(String column, dynamic value) {
    _conditions.add('$column=eq.$value');
    return this;
  }

  /// Not equal filter
  QueryBuilder<T> neq(String column, dynamic value) {
    _conditions.add('$column=neq.$value');
    return this;
  }

  /// Greater than filter
  QueryBuilder<T> gt(String column, dynamic value) {
    _conditions.add('$column=gt.$value');
    return this;
  }

  /// Greater than or equal filter
  QueryBuilder<T> gte(String column, dynamic value) {
    _conditions.add('$column=gte.$value');
    return this;
  }

  /// Less than filter
  QueryBuilder<T> lt(String column, dynamic value) {
    _conditions.add('$column=lt.$value');
    return this;
  }

  /// Less than or equal filter
  QueryBuilder<T> lte(String column, dynamic value) {
    _conditions.add('$column=lte.$value');
    return this;
  }

  /// Pattern matching filter
  QueryBuilder<T> like(String column, String pattern) {
    _conditions.add('$column=like.$pattern');
    return this;
  }

  /// Case insensitive pattern matching
  QueryBuilder<T> ilike(String column, String pattern) {
    _conditions.add('$column=ilike.$pattern');
    return this;
  }

  /// In array filter
  QueryBuilder<T> inFilter(String column, List<dynamic> values) {
    final valueString = values.map((v) => v.toString()).join(',');
    _conditions.add('$column=in.($valueString)');
    return this;
  }

  /// Is null filter
  QueryBuilder<T> isNull(String column) {
    _conditions.add('$column=is.null');
    return this;
  }

  /// Is not null filter
  QueryBuilder<T> isNotNull(String column) {
    _conditions.add('$column=not.is.null');
    return this;
  }

  /// Order by column
  QueryBuilder<T> order(String column, {bool ascending = true}) {
    _orderBy.add('$column.${ascending ? 'asc' : 'desc'}');
    return this;
  }

  /// Limit results
  QueryBuilder<T> limit(int count) {
    _limit = count;
    return this;
  }

  /// Offset results (pagination)
  QueryBuilder<T> offset(int count) {
    _offset = count;
    return this;
  }

  /// Range selection
  QueryBuilder<T> range(int from, int to) {
    _range = '$from-$to';
    return this;
  }

  /// Execute SELECT query
  Future<PostgrestResponse<List<Map<String, dynamic>>>> execute() async {
    try {
      final queryParams = <String, String>{};

      // Add select columns
      if (_selectColumns.isNotEmpty) {
        queryParams['select'] = _selectColumns.join(',');
      }

      // Add filters
      for (final condition in _conditions) {
        final parts = condition.split('=');
        if (parts.length == 2) {
          queryParams[parts[0]] = parts[1];
        }
      }

      // Add ordering
      if (_orderBy.isNotEmpty) {
        queryParams['order'] = _orderBy.join(',');
      }

      // Add limit
      if (_limit != null) {
        queryParams['limit'] = _limit.toString();
      }

      // Add offset
      if (_offset != null) {
        queryParams['offset'] = _offset.toString();
      }

      final response = await _httpClient.get(
        '/api/projects/$_projectId/database/tables/$_table/data',
        queryParameters: queryParams,
        headers: _range != null ? {'Range': _range!} : null,
      );

      return PostgrestResponse<List<Map<String, dynamic>>>(
        data: List<Map<String, dynamic>>.from(response.data['data'] ?? []),
        status: response.statusCode,
        statusText: response.statusMessage,
        count: response.data['count'],
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Insert data
  Future<PostgrestResponse<List<Map<String, dynamic>>>> insert(
    dynamic data, {
    bool upsert = false,
    String? onConflict,
  }) async {
    try {
      final body = <String, dynamic>{
        'data': data is List ? data : [data],
        if (upsert) 'upsert': true,
        if (onConflict != null) 'on_conflict': onConflict,
      };

      final response = await _httpClient.post(
        '/api/projects/$_projectId/database/tables/$_table/rows',
        body: body,
      );

      return PostgrestResponse<List<Map<String, dynamic>>>(
        data: List<Map<String, dynamic>>.from(response.data['data'] ?? []),
        status: response.statusCode,
        statusText: response.statusMessage,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Update data
  Future<PostgrestResponse<List<Map<String, dynamic>>>> update(
    Map<String, dynamic> data,
  ) async {
    try {
      final queryParams = <String, String>{};

      // Add filters for WHERE clause
      for (final condition in _conditions) {
        final parts = condition.split('=');
        if (parts.length == 2) {
          queryParams[parts[0]] = parts[1];
        }
      }

      final response = await _httpClient.put(
        '/api/projects/$_projectId/database/tables/$_table/rows',
        body: {'data': data},
        queryParameters: queryParams,
      );

      return PostgrestResponse<List<Map<String, dynamic>>>(
        data: List<Map<String, dynamic>>.from(response.data['data'] ?? []),
        status: response.statusCode,
        statusText: response.statusMessage,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Delete data
  Future<PostgrestResponse<List<Map<String, dynamic>>>> delete() async {
    try {
      final queryParams = <String, String>{};

      // Add filters for WHERE clause
      for (final condition in _conditions) {
        final parts = condition.split('=');
        if (parts.length == 2) {
          queryParams[parts[0]] = parts[1];
        }
      }

      final response = await _httpClient.delete(
        '/api/projects/$_projectId/database/tables/$_table/rows',
        queryParameters: queryParams,
      );

      return PostgrestResponse<List<Map<String, dynamic>>>(
        data: List<Map<String, dynamic>>.from(response.data['data'] ?? []),
        status: response.statusCode,
        statusText: response.statusMessage,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Count rows
  Future<int> count() async {
    try {
      final queryParams = <String, String>{};

      // Add filters
      for (final condition in _conditions) {
        final parts = condition.split('=');
        if (parts.length == 2) {
          queryParams[parts[0]] = parts[1];
        }
      }

      queryParams['count'] = 'exact';

      final response = await _httpClient.head(
        '/api/projects/$_projectId/database/tables/$_table/data',
        queryParameters: queryParams,
      );

      final countHeader = response.headers['content-range'];
      if (countHeader != null) {
        final match = RegExp(r'/(\d+)').firstMatch(countHeader);
        if (match != null) {
          return int.parse(match.group(1)!);
        }
      }

      return 0;
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }
}
```

## Edge Functions Implementation

### lib/src/edge_functions/edge_functions_client.dart
```dart
import 'dart:async';
import 'dart:convert';

import '../client/http_client.dart';
import '../utils/token_manager.dart';
import 'function_response.dart';
import 'function_exception.dart';

class EdgeFunctionsClient {
  final HttpClient _httpClient;
  final TokenManager _tokenManager;
  final String _projectId;
  final String _projectUrl;

  EdgeFunctionsClient({
    required HttpClient httpClient,
    required TokenManager tokenManager,
    required String projectId,
    required String projectUrl,
  })  : _httpClient = httpClient,
        _tokenManager = tokenManager,
        _projectId = projectId,
        _projectUrl = projectUrl;

  /// Invoke an edge function
  Future<FunctionResponse> invoke(
    String functionName, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String method = 'POST',
  }) async {
    try {
      // Extract slug from project URL or use project ID
      final slug = _projectUrl.split('/').last;
      
      final response = await _httpClient.request(
        method,
        '/projects/$slug/functions/v1/$functionName',
        body: body,
        headers: headers,
      );

      return FunctionResponse(
        data: response.data,
        status: response.statusCode,
        statusText: response.statusMessage,
        headers: response.headers,
      );
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Management endpoints (admin only)

  /// Create or deploy a function
  Future<void> create({
    required String name,
    required String source,
    Map<String, String>? config,
  }) async {
    try {
      await _httpClient.post(
        '/api/projects/$_projectId/functions',
        body: {
          'name': name,
          'source': source,
          if (config != null) 'config': config,
        },
        useServiceRoleKey: true,
      );
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Update a function
  Future<void> update({
    required String name,
    String? source,
    Map<String, String>? config,
  }) async {
    try {
      await _httpClient.put(
        '/api/projects/$_projectId/functions/$name',
        body: {
          if (source != null) 'source': source,
          if (config != null) 'config': config,
        },
        useServiceRoleKey: true,
      );
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Delete a function
  Future<void> delete(String name) async {
    try {
      await _httpClient.delete(
        '/api/projects/$_projectId/functions/$name',
        useServiceRoleKey: true,
      );
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// List all functions
  Future<List<Map<String, dynamic>>> list() async {
    try {
      final response = await _httpClient.get(
        '/api/projects/$_projectId/functions',
        useServiceRoleKey: true,
      );

      final List<dynamic> functions = response.data['functions'] ?? [];
      return functions.cast<Map<String, dynamic>>();
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Get function details
  Future<Map<String, dynamic>> get(String name) async {
    try {
      final response = await _httpClient.get(
        '/api/projects/$_projectId/functions/$name',
        useServiceRoleKey: true,
      );

      return response.data;
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Get function logs
  Future<List<Map<String, dynamic>>> getLogs(
    String name, {
    DateTime? since,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (since != null) {
        queryParams['since'] = since.toIso8601String();
      }
      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }

      final response = await _httpClient.get(
        '/api/projects/$_projectId/functions/$name/logs',
        queryParameters: queryParams,
        useServiceRoleKey: true,
      );

      final List<dynamic> logs = response.data['logs'] ?? [];
      return logs.cast<Map<String, dynamic>>();
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }
}
```

## Usage Examples

### lib/example/main.dart
```dart
import 'package:flutter/material.dart';
import 'package:orbitnest/orbitnest.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrbitNest Demo',
      home: OrbitNestExample(),
    );
  }
}

class OrbitNestExample extends StatefulWidget {
  @override
  _OrbitNestExampleState createState() => _OrbitNestExampleState();
}

class _OrbitNestExampleState extends State<OrbitNestExample> {
  late OrbitNestClient orbitnest;
  User? currentUser;
  List<Map<String, dynamic>> todos = [];

  @override
  void initState() {
    super.initState();
    initializeOrbitNest();
  }

  void initializeOrbitNest() {
    // Initialize OrbitNest client
    orbitnest = OrbitNestClient.create(
      projectUrl: 'https://api.orbitnest.studio',
      projectId: 'my_project_id',
      anonKey: 'your-anon-key-here',
      serviceRoleKey: 'your-service-role-key-here', // Optional
    );

    // Listen to auth state changes
    orbitnest.authStateChanges.listen((state) {
      setState(() {
        currentUser = orbitnest.currentUser;
      });
      
      if (state == AuthState.signedIn) {
        loadTodos();
      } else if (state == AuthState.signedOut) {
        todos.clear();
      }
    });
  }

  Future<void> signUpWithEmail(String email) async {
    try {
      final response = await orbitnest.auth.signUpWithEmail(email: email);
      print('OTP sent to $email');
      // Show OTP input dialog
    } catch (e) {
      print('Signup error: $e');
    }
  }

  Future<void> verifySignup(String email, String otp, String? password) async {
    try {
      final response = await orbitnest.auth.verifySignup(
        email: email,
        token: otp,
        password: password,
      );
      print('User signed up: ${response.user?.email}');
    } catch (e) {
      print('Verification error: $e');
    }
  }

  Future<void> signInWithEmail(String email) async {
    try {
      final response = await orbitnest.auth.signInWithEmail(email: email);
      print('OTP sent to $email');
      // Show OTP input dialog
    } catch (e) {
      print('Signin error: $e');
    }
  }

  Future<void> verifySignin(String email, String otp) async {
    try {
      final response = await orbitnest.auth.verifySignin(
        email: email,
        token: otp,
      );
      print('User signed in: ${response.user?.email}');
    } catch (e) {
      print('Verification error: $e');
    }
  }

  Future<void> signInWithPassword(String email, String password) async {
    try {
      final response = await orbitnest.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('User signed in: ${response.user?.email}');
    } catch (e) {
      print('Signin error: $e');
    }
  }

  Future<void> loadTodos() async {
    try {
      final response = await orbitnest.database
          .from('todos')
          .select()
          .eq('user_id', currentUser!.id)
          .order('created_at', ascending: false)
          .execute();

      setState(() {
        todos = response.data;
      });
    } catch (e) {
      print('Load todos error: $e');
    }
  }

  Future<void> addTodo(String title) async {
    try {
      final response = await orbitnest.database
          .from('todos')
          .insert({
            'title': title,
            'user_id': currentUser!.id,
            'completed': false,
          })
          .execute();

      loadTodos(); // Refresh the list
    } catch (e) {
      print('Add todo error: $e');
    }
  }

  Future<void> updateTodo(String id, bool completed) async {
    try {
      await orbitnest.database
          .from('todos')
          .update({'completed': completed})
          .eq('id', id)
          .execute();

      loadTodos(); // Refresh the list
    } catch (e) {
      print('Update todo error: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await orbitnest.database
          .from('todos')
          .delete()
          .eq('id', id)
          .execute();

      loadTodos(); // Refresh the list
    } catch (e) {
      print('Delete todo error: $e');
    }
  }

  Future<void> callEdgeFunction() async {
    try {
      final response = await orbitnest.functions.invoke(
        'hello-world',
        body: {'name': 'Flutter'},
      );
      print('Function response: ${response.data}');
    } catch (e) {
      print('Function error: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await orbitnest.auth.signOut();
      print('User signed out');
    } catch (e) {
      print('Signout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OrbitNest Demo'),
        actions: [
          if (currentUser != null)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: signOut,
            ),
        ],
      ),
      body: currentUser == null
          ? AuthScreen(
              onSignUpWithEmail: signUpWithEmail,
              onVerifySignup: verifySignup,
              onSignInWithEmail: signInWithEmail,
              onVerifySignin: verifySignin,
              onSignInWithPassword: signInWithPassword,
            )
          : TodoScreen(
              todos: todos,
              onAddTodo: addTodo,
              onUpdateTodo: updateTodo,
              onDeleteTodo: deleteTodo,
              onCallFunction: callEdgeFunction,
            ),
    );
  }

  @override
  void dispose() {
    orbitnest.dispose();
    super.dispose();
  }
}

// Auth Screen Widget
class AuthScreen extends StatelessWidget {
  final Function(String) onSignUpWithEmail;
  final Function(String, String, String?) onVerifySignup;
  final Function(String) onSignInWithEmail;
  final Function(String, String) onVerifySignin;
  final Function(String, String) onSignInWithPassword;

  const AuthScreen({
    Key? key,
    required this.onSignUpWithEmail,
    required this.onVerifySignup,
    required this.onSignInWithEmail,
    required this.onVerifySignin,
    required this.onSignInWithPassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementation of auth UI
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('OrbitNest Authentication', style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 32),
            // Add your auth form widgets here
            ElevatedButton(
              onPressed: () => onSignInWithEmail('test@example.com'),
              child: Text('Sign In with Email (OTP)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => onSignInWithPassword('test@example.com', 'password'),
              child: Text('Sign In with Password'),
            ),
          ],
        ),
      ),
    );
  }
}

// Todo Screen Widget
class TodoScreen extends StatelessWidget {
  final List<Map<String, dynamic>> todos;
  final Function(String) onAddTodo;
  final Function(String, bool) onUpdateTodo;
  final Function(String) onDeleteTodo;
  final VoidCallback onCallFunction;

  const TodoScreen({
    Key? key,
    required this.todos,
    required this.onAddTodo,
    required this.onUpdateTodo,
    required this.onDeleteTodo,
    required this.onCallFunction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(hintText: 'Add a todo...'),
                  onSubmitted: onAddTodo,
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: onCallFunction,
                child: Text('Call Function'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return ListTile(
                title: Text(todo['title'] ?? ''),
                leading: Checkbox(
                  value: todo['completed'] ?? false,
                  onChanged: (value) => onUpdateTodo(todo['id'], value ?? false),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => onDeleteTodo(todo['id']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

## Testing Strategy

### test/orbitnest_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:orbitnest/orbitnest.dart';

void main() {
  group('OrbitNest Client Tests', () {
    late OrbitNestClient client;

    setUp(() {
      client = OrbitNestClient.create(
        projectUrl: 'https://test.orbitnest.studio/project/test',
        anonKey: 'test-anon-key',
        serviceRoleKey: 'test-service-key',
      );
    });

    tearDown(() {
      client.dispose();
    });

    group('Authentication', () {
      test('should sign up with email', () async {
        // Mock response and test signup
      });

      test('should verify signup with OTP', () async {
        // Mock response and test verification
      });

      test('should sign in with password', () async {
        // Mock response and test signin
      });
    });

    group('Database Operations', () {
      test('should fetch data from table', () async {
        // Mock response and test data fetching
      });

      test('should insert data into table', () async {
        // Mock response and test data insertion
      });

      test('should update data in table', () async {
        // Mock response and test data update
      });

      test('should delete data from table', () async {
        // Mock response and test data deletion
      });
    });

    group('Edge Functions', () {
      test('should invoke edge function', () async {
        // Mock response and test function invocation
      });
    });
  });
}
```

## API Endpoint Mapping

**Important**: The OrbitNest Studio backend uses a specific URL structure:
- Admin/Auth endpoints: `/api/auth/*` and `/api/admin/*`
- Project management: `/api/projects/*`
- Project-specific operations: `/api/projects/:projectId/*`
- Authenticated project APIs: `/api/project/:slug/*`

### Authentication Endpoints
```dart
// Project-scoped authentication endpoints
// Base path: /api/projects/:projectId/auth/
'/signup-with-email'             -> signUpWithEmail()
'/verify-signup'                 -> verifySignup()
'/signin-with-email'             -> signInWithEmail()
'/verify-signin'                 -> verifySignin()
'/signup'                        -> signUp()
'/signin'                        -> signInWithPassword()
'/recover'                       -> resetPasswordForEmail()
'/reset-password'                -> updatePassword()
'/user'                          -> getUser(), updateUser()
'/refresh'                       -> refreshSession()
'/signout'                       -> signOut()
'/admin/users'                   -> listUsers(), createUser()
'/admin/users/:id'               -> getUserById(), deleteUser()
```

### Database Operations Endpoints
```dart
// Project-scoped database operations
// Base path: /api/projects/:projectId/database/
'/sql'                           -> sql()
'/tables'                        -> getSchema(), createTable()
'/tables/list'                   -> listTables()  
'/tables/:table/data'            -> from().select()
'/tables/:tableName/rows'        -> insert()
'/tables/:tableName/rows/:rowId' -> update(), delete()
'/tables/:tableName/bulk-insert' -> bulkInsert()
'/tables/:tableName/bulk-update' -> bulkUpdate()
'/tables/:tableName/bulk-delete' -> bulkDelete()
'/tables/:tableName/rls/enable'  -> enableRLS()
'/tables/:tableName/rls/disable' -> disableRLS()
'/tables/:tableName/policies'    -> createPolicy(), listPolicies()
'/tables/:tableName/policies/:name' -> deletePolicy()
```

### Edge Functions Endpoints
```dart
// Management endpoints (admin auth required)
// Base path: /api/projects/:projectId/
'/functions'                     -> create(), list()
'/functions/:name'               -> get(), update(), delete()
'/functions/:name/logs'          -> getLogs()

// Environment variables management
'/environment-variables'         -> createEnvVar(), listEnvVars()
'/environment-variables/bulk'    -> bulkCreateEnvVars()
'/environment-variables/:name'   -> getEnvVar(), updateEnvVar(), deleteEnvVar()

// Function execution (public/API key auth)
// Base path: /projects/:slug/functions/v1/
'/functions/v1/:name'            -> invoke()
```

### Logging Endpoints
```dart
// Project-scoped logging endpoints
// Base path: /api/projects/:projectId/logs/
'/logs'                          -> getLogs()
'/logs/database'                 -> getDatabaseLogs()
'/logs/database/slow'            -> getSlowQueryLogs()
'/logs/database/errors'          -> getDatabaseErrors()
'/logs/auth'                     -> getAuthLogs()
'/logs/auth/failures'            -> getAuthFailures()
'/logs/auth/security'            -> getSecurityLogs()
'/logs/edge-functions'           -> getEdgeFunctionLogs()
'/logs/edge-functions/:functionName/console' -> getFunctionConsoleLogs()
'/logs/edge-functions/:functionName/errors'  -> getFunctionErrors()
'/logs/export'                   -> exportLogs()
```

### Project Management Endpoints
```dart
// Admin-only project management
// Base path: /api/projects/
'/'                              -> create(), list()
'/:id'                           -> get(), update(), delete()
'/:id/api-keys'                  -> createApiKeys(), getApiKeys()
'/:id/api-keys/:keyId'           -> deleteApiKey()
'/decryption-key'                -> getDecryptionKey()
```

### Authenticated Project Endpoints
```dart
// API key authenticated project access
// Base path: /api/project/:slug/
'/info'                          -> getProjectInfo()
'/health'                        -> getHealth()
'/test-auth'                     -> testAuth()
```

## Implementation Checklist

### Phase 1: Core Infrastructure
- [ ] Set up Flutter package structure
- [ ] Implement HTTP client with authentication
- [ ] Create token manager for JWT handling
- [ ] Set up shared preferences for persistence
- [ ] Implement error handling and exceptions

### Phase 2: Authentication
- [ ] Implement User and Session models
- [ ] Create AuthClient with all auth methods
- [ ] Add OTP-based signup/signin flows
- [ ] Implement password-based authentication
- [ ] Add session management and refresh logic
- [ ] Implement admin user management

### Phase 3: Database Operations
- [ ] Create DatabaseClient and QueryBuilder
- [ ] Implement CRUD operations
- [ ] Add filtering and pagination
- [ ] Implement RLS policy management
- [ ] Add SQL execution capabilities
- [ ] Create table management functions

### Phase 4: Edge Functions
- [ ] Implement EdgeFunctionsClient
- [ ] Add function invocation methods
- [ ] Implement function management (admin)
- [ ] Add logging capabilities

### Phase 5: Logging & Monitoring
- [ ] Create LoggingClient
- [ ] Implement log querying
- [ ] Add real-time log streaming
- [ ] Create log filtering capabilities

### Phase 6: Testing & Documentation
- [ ] Write comprehensive unit tests
- [ ] Create integration tests
- [ ] Write example applications
- [ ] Create API documentation
- [ ] Add performance tests

### Phase 7: Publishing
- [ ] Prepare package for pub.dev
- [ ] Create comprehensive README
- [ ] Add example projects
- [ ] Set up CI/CD for testing
- [ ] Publish to pub.dev

## Error Handling Strategy

### Exception Types
```dart
// Custom exception classes for different error types
class OrbitNestException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const OrbitNestException(this.message, {this.statusCode, this.details});
}

class AuthException extends OrbitNestException {
  const AuthException(String message, {int? statusCode, dynamic details})
      : super(message, statusCode: statusCode, details: details);
}

class DatabaseException extends OrbitNestException {
  const DatabaseException(String message, {int? statusCode, dynamic details})
      : super(message, statusCode: statusCode, details: details);
}

class FunctionException extends OrbitNestException {
  const FunctionException(String message, {int? statusCode, dynamic details})
      : super(message, statusCode: statusCode, details: details);
}
```

### Error Response Handling
```dart
// Standard error response format
class ErrorResponse {
  final String error;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const ErrorResponse({
    required this.error,
    this.message,
    this.statusCode,
    this.details,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      error: json['error'] ?? 'Unknown error',
      message: json['message'],
      statusCode: json['status_code'],
      details: json['details'],
    );
  }
}
```

## Performance Considerations

### Caching Strategy
- Implement session caching in shared preferences
- Cache table schemas for database operations
- Implement query result caching where appropriate
- Use lazy loading for large datasets

### Connection Management
- Implement connection pooling for HTTP requests
- Add request timeout configurations
- Implement retry logic for failed requests
- Use WebSocket connections for real-time features

### Memory Management
- Properly dispose of streams and subscriptions
- Implement pagination for large datasets
- Use efficient data structures
- Avoid memory leaks in long-running operations

This comprehensive guide provides all the necessary information to implement a production-ready Flutter package for OrbitNest Studio backend integration. The package will be Supabase-compatible and provide all the functionality needed for mobile app development.
