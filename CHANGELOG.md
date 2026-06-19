## [1.5.1]

### Changed
- Widened dependency constraints to support the latest stable releases of `flutter_bloc` (9.x), `flutter_dotenv` (6.x), and `flutter_secure_storage` (10.x).
- Raised the `dio` lower bound to `^5.5.0` (required for `DioMediaType`).

### Removed
- Dropped deprecated `flutter_secure_storage` Android cipher options; data migrates automatically.

### Added
- Added an `example/` with a minimal usage sample.

## [1.5.0]

### Added
- **Storage client**: upload, download, list, remove, and `getPublicUrl` with image transforms.

## [1.4.0]

### Added
- **MFA recovery codes**: `verifyMfaEnrollment` now surfaces `recovery_codes`, plus a new `regenerateMfaRecoveryCodes` method.

## [1.3.0]

### Added
- **Multi-factor authentication (TOTP)**, **SMS OTP sign-in**, and **pgvector vector search**.

## [1.2.0]

### Added
- **Migrations client**: trigger server-side migration runs, read status, and display logs (the SDK never executes migrations itself).

## [1.1.0]

### Added
- **Analytics module** with batched event ingestion.

## [1.0.9] - 2026-02-23

### Added
- **Automatic Token Refresh**: Implemented automatic token refresh mechanism that triggers when tokens expire or are within 5 minutes of expiration
- **Error Recovery with Retry**: Added comprehensive retry logic with exponential backoff for network failures (408, 429, 500-504 errors)
- **Query Builder Integration**: Completed BLoC query builder integration with proper error handling

### Improved
- **Token Management**: Enhanced token manager with refresh callback support and automatic refresh detection
- **Network Resilience**: Added RetryInterceptor with configurable retry policies (aggressive, standard, conservative)
- **Authentication Flow**: Improved initialization flow to automatically attempt token refresh on expired tokens
- **Error Messages**: Better error messages for query builder usage

### Fixed
- Token refresh TODO implementation completed
- Query builder now provides clearer error messages when used incorrectly
- Automatic token refresh triggers on app initialization when needed

### Technical Details
- Added `RetryPolicy` class with configurable retry strategies
- Added `RetryInterceptor` for automatic request retry with exponential backoff
- Enhanced `TokenManager` with refresh callback mechanism
- Updated `AuthBloc` to register refresh callback and handle automatic token refresh
- Improved query builder error handling and documentation

## [1.0.8] - Previous Release
- Base implementation with auth, database, and edge functions support
