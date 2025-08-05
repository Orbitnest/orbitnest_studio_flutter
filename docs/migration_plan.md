# 🚀 OrbitNest Studio Migration Plan

## Overview

This document provides a comprehensive guide for migrating from Supabase to OrbitNest Studio package. OrbitNest offers a Supabase-compatible API with enhanced features and better Flutter integration.

## 📋 Key Changes Made

### Security Improvements
- ✅ **Removed legacy `createWithParams` method** - No more hardcoded API keys in source code
- ✅ **Environment-only configuration** - All sensitive credentials must be in `.env` files
- ✅ **Secure token management** - Enhanced JWT handling and refresh logic

### API Enhancements
- ✅ **Direct method API** - Supabase-style methods for quick operations
- ✅ **BLoC integration** - Advanced state management for reactive applications
- ✅ **Unified client** - Single entry point for all OrbitNest services

## 🔧 Migration Steps

### 1. Environment Setup

**Before (Supabase):**
```dart
Supabase.initialize(
  url: 'https://your-project.supabase.co',
  anonKey: 'your-anon-key'
);
```

**After (OrbitNest):**
```env
# .env file
ORBITNEST_BASE_URL=https://your-project.orbitnest.io
ORBITNEST_PROJECT_SLUG=your-project-slug
ORBITNEST_PROJECT_ID=your-project-id
ORBITNEST_ANON_KEY=your-anon-key
ORBITNEST_SERVICE_ROLE_KEY=your-service-role-key
```

```dart
// Initialize configuration
await EnvConfig.initialize();

// Create client (secure, no hardcoded keys)
final orbitnest = OrbitNestClient.create();
```

### 2. Client Initialization

**Migration Class:** `OrbitNestClient`
- **Purpose:** Main entry point, replaces `SupabaseClient`
- **Usage:** Single instance for all operations

```dart
// Initialize once in your app
final orbitnest = OrbitNestClient.create();

// Optional: Override specific values while keeping .env security
final orbitnest = OrbitNestClient.create(
  projectUrl: 'https://custom-staging.orbitnest.io',
);
```

### 3. Authentication Migration

**Migration Class:** `OrbitNestAuth` (via `orbitnest.auth`)
- **Purpose:** Handles all authentication operations
- **Compatibility:** Direct Supabase method equivalents

| Supabase Method | OrbitNest Equivalent |
|----------------|---------------------|
| `supabase.auth.signInWithPassword()` | `orbitnest.signIn()` |
| `supabase.auth.signUp()` | `orbitnest.signUp()` |
| `supabase.auth.signOut()` | `orbitnest.signOut()` |
| `supabase.auth.currentUser` | `orbitnest.currentUser()` |
| `supabase.auth.currentSession` | `orbitnest.currentSession()` |

```dart
// Direct method API (recommended for simple apps)
await orbitnest.signIn('user@example.com', 'password');
await orbitnest.signUp('user@example.com', 'password');
await orbitnest.signOut();

// Advanced API with state management
await orbitnest.auth.signInWithPassword(
  email: 'user@example.com', 
  password: 'password'
);
```

### 4. Database Migration

**Migration Class:** `OrbitNestDatabase` (via `orbitnest.database`)
- **Purpose:** PostgreSQL operations with Supabase-compatible query builder
- **Compatibility:** Same API as Supabase PostgREST

| Supabase Method | OrbitNest Equivalent |
|----------------|---------------------|
| `supabase.from('table').select()` | `orbitnest.from('table').select()` |
| `supabase.from('table').insert()` | `orbitnest.insert('table', data)` |
| `supabase.from('table').update()` | `orbitnest.update('table', data)` |
| `supabase.from('table').delete()` | `orbitnest.delete('table')` |
| `supabase.rpc()` | `orbitnest.sql()` |

```dart
// Query builder (100% Supabase compatible)
final data = await orbitnest.from('users')
  .select()
  .eq('status', 'active')
  .order('created_at');

// Direct methods (simplified API)
final users = await orbitnest.select('users', 
  filters: {'status': 'active'},
  orderBy: ['created_at']
);
```

### 5. Edge Functions Migration

**Migration Class:** `OrbitNestFunctions` (via `orbitnest.functions`)
- **Purpose:** Serverless function execution
- **Enhancement:** Better error handling and response parsing

| Supabase Method | OrbitNest Equivalent |
|----------------|---------------------|
| `supabase.functions.invoke()` | `orbitnest.function()` |

```dart
// Direct method API
final result = await orbitnest.function('my-function', 
  params: {'key': 'value'}
);

// Advanced API
final response = await orbitnest.functions.invoke('my-function',
  body: {'key': 'value'},
  headers: {'Custom-Header': 'value'}
);
```

## 🏗️ Architecture Patterns

### Simple Apps (Direct Method API)
Use direct methods on `OrbitNestClient` for straightforward applications:

```dart
class UserService {
  final OrbitNestClient orbitnest;
  
  UserService(this.orbitnest);
  
  Future<List<User>> getUsers() async {
    final data = await orbitnest.select('users');
    return data.map((json) => User.fromJson(json)).toList();
  }
}
```

### Complex Apps (BLoC Pattern)
Use BLoC classes for reactive state management:

```dart
class UserCubit extends Cubit<UserState> {
  final OrbitNestClient orbitnest;
  
  UserCubit(this.orbitnest) : super(UserInitial());
  
  void loadUsers() {
    // Listen to database BLoC events
    orbitnest.database.select('users').then((response) {
      emit(UserLoaded(response.data));
    });
  }
}
```

## 📦 Dependencies Update

### pubspec.yaml Changes

**Remove:**
```yaml
dependencies:
  supabase_flutter: ^any
```

**Add:**
```yaml
dependencies:
  orbitnest_studio_flutter: ^1.0.0
  flutter_bloc: ^8.1.0  # If using BLoC pattern
  flutter_dotenv: ^5.0.0  # For .env support
```

### Import Changes

**Before:**
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
```

**After:**
```dart
import 'package:orbitnest_studio_flutter/orbitnest_studio_flutter.dart';
```

## 🔄 Code Migration Examples

### Authentication Flow

**Before (Supabase):**
```dart
final response = await Supabase.instance.client.auth
  .signInWithPassword(email: email, password: password);
```

**After (OrbitNest):**
```dart
final response = await orbitnest.signIn(email, password);
```

### Database Operations

**Before (Supabase):**
```dart
final data = await Supabase.instance.client
  .from('users')
  .select()
  .eq('id', userId);
```

**After (OrbitNest):**
```dart
final data = await orbitnest.from('users')
  .select()
  .eq('id', userId);
```

### Function Calls

**Before (Supabase):**
```dart
final response = await Supabase.instance.client.functions
  .invoke('my-function', body: {'key': 'value'});
```

**After (OrbitNest):**
```dart
final response = await orbitnest.function('my-function', 
  params: {'key': 'value'});
```

## 🛡️ Security Enhancements

### Environment Variable Management

1. **Create `.env` file** in your project root
2. **Add to `.gitignore`** to prevent committing secrets
3. **Use `flutter_dotenv`** to load environment variables
4. **Initialize before client creation**

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize OrbitNest configuration
  await EnvConfig.initialize();
  
  runApp(MyApp());
}
```

### Code Generation Setup

**Important:** OrbitNest Studio uses Freezed for model generation. After adding the package dependency, you must run code generation:

```bash
# Generate required .freezed.dart and .g.dart files
flutter packages pub run build_runner build --delete-conflicting-outputs

# For development with auto-generation on file changes
flutter packages pub run build_runner watch
```

## ✅ Migration Checklist

- [ ] Create `.env` file with OrbitNest credentials
- [ ] Update `pubspec.yaml` dependencies
- [ ] Replace Supabase imports with OrbitNest imports
- [ ] **Run code generation**: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [ ] Initialize `EnvConfig` before client creation
- [ ] Replace `SupabaseClient` with `OrbitNestClient`
- [ ] Update authentication method calls
- [ ] Update database query methods
- [ ] Update edge function invocations
- [ ] Test all functionality
- [ ] Remove any hardcoded API keys
- [ ] Add `.env` to `.gitignore`

## 🎯 Key Benefits After Migration

1. **Enhanced Security** - No more hardcoded API keys
2. **Better Flutter Integration** - Native BLoC support
3. **Improved Developer Experience** - Direct method API
4. **Flexible Architecture** - Support for both simple and complex patterns
5. **Future-Proof** - Built specifically for OrbitNest Studio features

## 📞 Support

For migration assistance or questions, refer to:
- [API Documentation](./00_api_guide.md)
- [Package Implementation Guide](./01_package_implementation.md)
- OrbitNest Studio documentation
