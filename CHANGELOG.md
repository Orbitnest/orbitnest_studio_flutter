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
