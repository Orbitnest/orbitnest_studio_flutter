# OrbitNest Studio Flutter

The official Flutter client for [OrbitNest Studio](https://studio.orbitnest.io) — a Postgres-backed application platform. One SDK for authentication, database queries, realtime, storage, edge functions, background jobs, and migrations, with a Supabase-compatible API for easy migration.

The client is built on the BLoC pattern internally, but you don't need to know BLoC to use it: every feature is exposed through plain `async`/`await` methods. Reactive state streams are available when you want them.

## Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Quick start](#quick-start)
- [Authentication](#authentication)
- [Database](#database)
- [Storage](#storage)
- [Realtime](#realtime)
- [Edge functions](#edge-functions)
- [Background jobs](#background-jobs)
- [Migrations](#migrations)
- [Reactive state with BLoC](#reactive-state-with-bloc)
- [Error handling](#error-handling)
- [Migrating from Supabase](#migrating-from-supabase)
- [API surface](#api-surface)

## Installation

```yaml
dependencies:
  orbitnest_studio_flutter: ^1.5.0
```

```bash
flutter pub get
```

## Configuration

A client app authenticates with your project's **anon key** — a public, RLS-protected key. The project slug and API URL are encoded inside the anon key JWT and resolved automatically; you don't set them separately.

Copy `.env.example` to `.env` and set your key:

```env
# From OrbitNest Studio → Settings → API Keys
ORBITNEST_ANON_KEY=your_anon_key_here

# Verbose SDK logging — leave false/unset in production
ORBITNEST_DEBUG=false

# Optional. HTTP timeout in ms (default 180000). Local dev base URL override.
# ORBITNEST_API_TIMEOUT=180000
# ORBITNEST_API_URL=http://localhost:3002
```

Register `.env` as an asset in your app's `pubspec.yaml`:

```yaml
flutter:
  assets:
    - .env
```

> **Security.** This is a client SDK. Ship **only** the anon key. A service-role / admin key is server-side and would be extractable from the installed app binary, so it must never be bundled. Backend management — creating tables, policies, functions, or jobs — is done from the OrbitNest Studio dashboard or admin tooling, not from this SDK.

## Quick start

```dart
import 'package:orbitnest_studio_flutter/orbitnest_studio_flutter.dart';

Future<void> main() async {
  await EnvConfig.initialize();           // load .env
  final orbitnest = OrbitNestClient.create();

  // Or pass the key explicitly:
  // final orbitnest = OrbitNestClient.create(anonKey: 'your_anon_key');

  final users = await orbitnest
      .from('users')
      .select('id, name, email')
      .eq('status', 'active')
      .limit(20)
      .execute();

  print(users.data);
  orbitnest.dispose();
}
```

The client exposes each capability as a sub-API:

```dart
orbitnest.auth        // authentication
orbitnest.database    // database CRUD + query builder
orbitnest.storage     // file storage
orbitnest.realtime    // live subscriptions, broadcast, presence
orbitnest.functions   // edge function invocation
orbitnest.jobs        // background jobs
orbitnest.migrations  // server-side migration runs
```

## Authentication

OrbitNest supports password, email OTP, SMS OTP, TOTP-based multi-factor auth, and passkeys (WebAuthn). All methods return plain maps/objects and throw `AuthException` on failure.

### Password

```dart
// Sign up sends a verification OTP to the email.
await orbitnest.auth.signUp(email: 'user@example.com', password: 'secret123');

final result = await orbitnest.auth.signInWithPassword(
  email: 'user@example.com',
  password: 'secret123',
);
final user = result['user'] as User;

await orbitnest.auth.resetPasswordForEmail('user@example.com');
await orbitnest.auth.resetPassword(
  email: 'user@example.com',
  token: '123456',
  newPassword: 'newSecret123',
);
```

### Email OTP

```dart
await orbitnest.auth.signInWithEmail('user@example.com');   // sends a code
await orbitnest.auth.verifySignIn(email: 'user@example.com', otp: '123456');

// Sign-up variants: signUpWithEmail(...) then verifySignUp(...).
```

### SMS OTP

Requires SMS to be configured for your project. Phone numbers are E.164 (e.g. `+15555550123`).

```dart
await orbitnest.auth.signInWithSms('+15555550123');
await orbitnest.auth.verifySmsOtp(phone: '+15555550123', code: '123456');
```

### Multi-factor authentication (TOTP)

```dart
// Enroll an authenticator app.
final enroll = await orbitnest.auth.enrollMfaTotp(friendlyName: 'My phone');
// enroll['qr_code'] / enroll['otpauth_url'] — show to the user to scan.

final verified = await orbitnest.auth.verifyMfaEnrollment(
  factorId: enroll['factor_id'],
  code: '123456',
);
final recoveryCodes = verified['recovery_codes']; // shown once — store safely

// When a password sign-in is MFA-gated, complete it with the challenge token:
await orbitnest.auth.verifyMfa(challengeToken: '...', code: '123456');

await orbitnest.auth.listMfaFactors();
await orbitnest.auth.regenerateMfaRecoveryCodes();
await orbitnest.auth.unenrollMfa(factorId: '...');
```

### Passkeys (WebAuthn)

```dart
if (await orbitnest.auth.isPasskeySupported()) {
  // New user: create an account and register a passkey in one ceremony.
  await orbitnest.auth.signUpWithPasskey(email: 'user@example.com');

  // Returning user:
  await orbitnest.auth.signInWithPasskey(identifier: 'user@example.com');

  // For an already-authenticated user:
  await orbitnest.auth.registerPasskey(deviceName: 'iPhone');
  await orbitnest.auth.listPasskeys();
  await orbitnest.auth.renamePasskey(deviceId: '...', deviceName: 'Work phone');
  await orbitnest.auth.revokePasskey(deviceId: '...');
}
```

### Session

```dart
orbitnest.auth.isAuthenticated;        // bool
orbitnest.auth.currentUser;            // User?
orbitnest.auth.currentSession;         // Session?
await orbitnest.auth.refreshSession();
await orbitnest.auth.signOut();

// React to changes (optional).
orbitnest.auth.onAuthStateChange.listen((state) { /* ... */ });

// Fires when the server rejects the session and it can't be recovered.
orbitnest.onSessionExpired.listen((_) => goToLogin());
```

Sessions are stored in encrypted device storage. Tokens refresh automatically ahead of expiry.

## Database

A Supabase-compatible query builder plus direct CRUD helpers. Queries run against your existing tables and respect Row Level Security.

### Query builder

```dart
final posts = await orbitnest
    .from('posts')
    .select('*, author:users(name)')
    .eq('published', true)
    .gte('created_at', '2024-01-01')
    .order('created_at', ascending: false)
    .range(0, 49)         // pagination
    .execute();

await orbitnest.from('users').insert({'name': 'Jane', 'email': 'jane@x.io'});
await orbitnest.from('users').upsert({'id': 1, 'name': 'Jane'}, onConflict: 'id');
await orbitnest.from('users').update({'status': 'inactive'}).execute(); // filter, then update
await orbitnest.from('users').delete().execute();
```

Filters: `eq`, `neq`, `gt`, `gte`, `lt`, `lte`, `like`, `ilike`, `isFilter`, `isNull`, `isNotNull`, `inFilter`, `contains`, `containedBy`, `overlaps`, the `range*` family, `textSearch`, `match`, `not`, `or`, `and`, `filter`.
Modifiers: `order`, `limit`, `range`, `single`, `maybeSingle`.

### Direct CRUD

```dart
final res = await orbitnest.database.select('users',
  columns: 'id, name', filters: {'status': 'active'}, limit: 10);
print(res.data);

await orbitnest.database.insert('users', {'name': 'Sam'});
await orbitnest.database.update('users', {'age': 31}, filters: {'id': 1});
await orbitnest.database.delete('users', filters: {'id': 1});

await orbitnest.database.insertMany('users', [ {...}, {...} ]);
await orbitnest.database.updateMany('users', {'tier': 'pro'}, filters: {'plan': 'paid'});
await orbitnest.database.deleteMany('users', filters: {'status': 'deleted'});
```

### Vector search (pgvector)

```dart
final matches = await orbitnest.database.vectorSearch(
  'documents',
  'embedding',
  [0.12, 0.04, /* ... */],
  metric: 'cosine',   // 'l2' (default), 'cosine', or 'ip'
  limit: 5,
);
```

### Raw SQL

```dart
final result = await orbitnest.database.sql(
  'SELECT name, COUNT(*) FROM posts GROUP BY name ORDER BY count DESC LIMIT ?',
  parameters: [10],
);
```

## Storage

Bucket-scoped file operations. `getPublicUrl` builds a URL locally (no network) and can request on-the-fly image transforms.

```dart
final bucket = orbitnest.storage.from('avatars');

await bucket.upload(path: 'u/1.png', bytes: pngBytes, contentType: 'image/png', upsert: true);
final bytes = await bucket.download('u/1.png');
final files = await bucket.list(prefix: 'u/');
await bucket.remove(['u/1.png']);

final url = bucket.getPublicUrl('u/1.png', transform: StorageTransform(
  width: 200, height: 200, format: 'webp', quality: 80, fit: 'cover',
));
```

## Realtime

Subscribe to Postgres changes, send broadcast messages, and track presence over a single WebSocket.

```dart
final channel = orbitnest.realtime.channel('room:42');

channel
  .onPostgresChanges(
    event: PgEvent.insert,
    table: 'messages',
    filter: RealtimeFilter(column: 'room_id', op: 'eq', value: '42'),
    callback: (payload) => print('new message: ${payload.newRecord}'),
  )
  .onBroadcast(event: 'typing', callback: (p) => print(p.payload))
  .onPresenceSync((state) => print('online: ${state.keys}'));

await channel.subscribe();
await channel.track({'user': 'jane'});           // presence
await channel.send(event: 'typing', payload: {'user': 'jane'});

await channel.unsubscribe();
await orbitnest.realtime.dispose();
```

## Edge functions

The SDK **invokes** edge functions. (Creating and managing functions is done in the OrbitNest Studio dashboard, not from the client.)

```dart
final res = await orbitnest.functions.invoke('send-email', body: {
  'to': 'user@example.com',
  'subject': 'Welcome',
});
print(res.data);

// HTTP-verb helpers:
await orbitnest.functions.get('health');
await orbitnest.functions.post('charge', body: {'amount': 100});
await orbitnest.functions.put('profile', body: {'name': 'Jane'});
await orbitnest.functions.delete('session');

// Shorthand on the client:
await orbitnest.function('send-email', params: {'to': 'user@example.com'});
```

## Background jobs

Trigger and inspect scheduled server-side jobs. (Job authoring is an admin operation.)

```dart
await orbitnest.jobs.trigger('nightly-report');
final runs = await orbitnest.jobs.getRuns('nightly-report', limit: 20);
final all = await orbitnest.jobs.list();
```

## Migrations

The SDK never runs migrations on-device — it triggers server-side runs and reads their status, which is useful for in-app admin or diagnostics screens.

```dart
final result = await orbitnest.migrations.run();      // apply all pending
final status = await orbitnest.migrations.status();   // applied / pending / failed

// MigrationLogController drives a live log view:
final controller = MigrationLogController(orbitnest.migrations);
await controller.refreshStatus();
await controller.runMigrations();
print(controller.logs);
```

## Reactive state with BLoC

Every sub-API also exposes a state stream, and the underlying BLoCs are available for `flutter_bloc` integration. Use these only when you want UI that reacts to state automatically — the `async`/`await` API above covers most apps.

```dart
orbitnest.auth.onAuthStateChange.listen((state) { /* ... */ });
orbitnest.database.onStateChange.listen((state) { /* ... */ });

// Direct BLoC access for BlocProvider / BlocBuilder:
orbitnest.authBloc;
orbitnest.databaseBloc;
orbitnest.functionsBloc;
```

## Error handling

All operations throw a subclass of `OrbitNestException` on failure:

```dart
try {
  await orbitnest.auth.signInWithPassword(email: e, password: p);
} on AuthException catch (e) {
  print('${e.code}: ${e.message}');
} on DatabaseException catch (e) {
  print(e.message);
} on FunctionException catch (e) {
  print(e.message);
}
```

Transient network failures (timeouts, connection errors, and `408`/`429`/`5xx` responses) are retried automatically with exponential backoff. Logs redact tokens, keys, and other sensitive fields in both debug and release builds.

## Migrating from Supabase

The query builder and client shape mirror `supabase_flutter`, so most data code is unchanged.

```dart
// Before
await Supabase.initialize(url: url, anonKey: key);
final db = Supabase.instance.client;

// After
await EnvConfig.initialize();
final db = OrbitNestClient.create();

// Identical query syntax:
final rows = await db.from('users').select('*').eq('status', 'active').execute();
```

## API surface

| Area | Entry point | Notes |
|------|-------------|-------|
| Auth | `orbitnest.auth` | password, email/SMS OTP, MFA (TOTP), passkeys, sessions |
| Database | `orbitnest.from(table)`, `orbitnest.database` | query builder, CRUD, bulk, pgvector, raw SQL |
| Storage | `orbitnest.storage.from(bucket)` | upload, download, list, remove, public URLs + transforms |
| Realtime | `orbitnest.realtime.channel(name)` | Postgres changes, broadcast, presence |
| Functions | `orbitnest.functions` | invoke only (`invoke`, `call`, `get`/`post`/`put`/`delete`) |
| Jobs | `orbitnest.jobs` | `trigger`, `getRuns`, `list`, `get` |
| Migrations | `orbitnest.migrations` | `run`, `status` (server-side) |
| Config | `EnvConfig` | `.env` loading, runtime settings |

Call `orbitnest.dispose()` when the client is no longer needed to release the HTTP client and any open realtime connection.

## License

MIT — see [LICENSE](LICENSE).
