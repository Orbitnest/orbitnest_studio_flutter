/// API endpoint constants for OrbitNest Studio
class Endpoints {
  // Admin Authentication
  static const String adminRequestVerification = '/api/auth/request-verification';
  static const String adminCompleteSignup = '/api/auth/complete-signup';
  static const String adminSignin = '/api/auth/signin';
  static const String adminRequestPasswordReset = '/api/auth/request-password-reset';
  static const String adminResetPassword = '/api/auth/reset-password';
  static const String adminRefreshToken = '/api/auth/refresh';
  static const String adminSignout = '/api/auth/signout';

  // Admin User Management
  static const String adminUsers = '/api/admin/users';
  static String adminUserById(String id) => '/api/admin/users/$id';
  static const String adminApiKeys = '/api/admin/api-keys';
  static String adminApiKeyById(String id) => '/api/admin/api-keys/$id';

  // Project Management
  static const String projects = '/api/projects';
  static String projectById(String id) => '/api/projects/$id';
  static String projectApiKeys(String id) => '/api/projects/$id/api-keys';
  static String deleteProjectApiKey(String projectId, String keyId) =>
      '/api/projects/$projectId/api-keys/$keyId';
  static const String projectDecryptionKey = '/api/projects/decryption-key';

  // Project API Key Authentication
  static String projectInfo(String slug) => '/api/project/$slug/info';
  static String projectHealth(String slug) => '/api/project/$slug/health';
  static String projectTestAuth(String slug) => '/api/project/$slug/test-auth';

  // Project Authentication
  static String projectSignupWithEmail(String projectId) =>
      '/projects/$projectId/auth/signup-with-email';
  static String projectVerifySignup(String projectId) =>
      '/projects/$projectId/auth/verify-signup';
  static String projectSigninWithEmail(String projectId) =>
      '/projects/$projectId/auth/signin-with-email';
  static String projectVerifySignin(String projectId) =>
      '/projects/$projectId/auth/verify-signin';
  static String projectSignup(String projectId) =>
      '/projects/$projectId/auth/signup';
  static String projectSignin(String projectId) =>
      '/projects/$projectId/auth/signin';
  static String projectRecover(String projectId) =>
      '/projects/$projectId/auth/recover';
  static String projectResetPassword(String projectId) =>
      '/projects/$projectId/auth/reset-password';
  static String projectUser(String projectId) =>
      '/projects/$projectId/auth/user';
  static String projectRefresh(String projectId) =>
      '/projects/$projectId/auth/refresh';
  static String projectSignout(String projectId) =>
      '/projects/$projectId/auth/signout';

  // Admin Project Auth
  static String projectAdminUsers(String projectId) =>
      '/projects/$projectId/auth/admin/users';
  static String projectAdminUserById(String projectId, String userId) =>
      '/projects/$projectId/auth/admin/users/$userId';
  static String projectAdminStats(String projectId) =>
      '/projects/$projectId/auth/admin/stats';
  static String projectAdminConfig(String projectId) =>
      '/projects/$projectId/auth/admin/config';

  // Edge Functions
  static String projectFunctions(String projectId) =>
      '/api/projects/$projectId/functions';
  static String projectFunctionByName(String projectId, String name) =>
      '/api/projects/$projectId/functions/$name';
  static String projectFunctionLogs(String projectId, String name) =>
      '/api/projects/$projectId/functions/$name/logs';

  // Function Invocation
  static String invokeFunction(String slug, String name) =>
      '/projects/$slug/functions/v1/$name';

  // Environment Variables
  static String projectEnvironmentVariables(String projectId) =>
      '/api/projects/$projectId/environment-variables';
  static String projectEnvironmentVariablesBulk(String projectId) =>
      '/api/projects/$projectId/environment-variables/bulk';
  static String projectEnvironmentVariableByName(String projectId, String name) =>
      '/api/projects/$projectId/environment-variables/$name';

  // Database Operations
  static String projectDatabaseSql(String projectId) =>
      '/api/projects/$projectId/database/sql';
  static String projectDatabaseTables(String projectId) =>
      '/api/projects/$projectId/database/tables';
  static String projectDatabaseTablesList(String projectId) =>
      '/api/projects/$projectId/database/tables/list';
  static String projectDatabaseTableData(String projectId, String table) =>
      '/api/projects/$projectId/database/tables/$table/data';
  static String projectDatabaseTableRows(String projectId, String table) =>
      '/api/projects/$projectId/database/tables/$table/rows';
  static String projectDatabaseTableRowById(String projectId, String table, String rowId) =>
      '/api/projects/$projectId/database/tables/$table/rows/$rowId';
  static String projectDatabaseTableBulkInsert(String projectId, String table) =>
      '/api/projects/$projectId/database/tables/$table/bulk-insert';
  static String projectDatabaseTableBulkUpdate(String projectId, String table) =>
      '/api/projects/$projectId/database/tables/$table/bulk-update';
  static String projectDatabaseTableBulkDelete(String projectId, String table) =>
      '/api/projects/$projectId/database/tables/$table/bulk-delete';
  static String projectDatabaseTableEnableRls(String projectId, String table) =>
      '/api/projects/$projectId/database/tables/$table/rls/enable';
  static String projectDatabaseTableDisableRls(String projectId, String table) =>
      '/api/projects/$projectId/database/tables/$table/rls/disable';
  static String projectDatabaseTablePolicies(String projectId, String table) =>
      '/api/projects/$projectId/database/tables/$table/policies';
  static String projectDatabaseTablePolicyByName(String projectId, String table, String name) =>
      '/api/projects/$projectId/database/tables/$table/policies/$name';

  // Logging
  static String projectLogs(String projectId) =>
      '/api/projects/$projectId/logs';
  static String projectDatabaseLogs(String projectId) =>
      '/api/projects/$projectId/logs/database';
  static String projectDatabaseSlowLogs(String projectId) =>
      '/api/projects/$projectId/logs/database/slow';
  static String projectDatabaseErrorLogs(String projectId) =>
      '/api/projects/$projectId/logs/database/errors';
  static String projectAuthLogs(String projectId) =>
      '/api/projects/$projectId/logs/auth';
  static String projectAuthFailureLogs(String projectId) =>
      '/api/projects/$projectId/logs/auth/failures';
  static String projectSecurityLogs(String projectId) =>
      '/api/projects/$projectId/logs/auth/security';
  static String projectEdgeFunctionLogs(String projectId) =>
      '/api/projects/$projectId/logs/edge-functions';
  static String projectEdgeFunctionConsoleLogs(String projectId, String functionName) =>
      '/api/projects/$projectId/logs/edge-functions/$functionName/console';
  static String projectEdgeFunctionErrorLogs(String projectId, String functionName) =>
      '/api/projects/$projectId/logs/edge-functions/$functionName/errors';
  static String projectExportLogs(String projectId) =>
      '/api/projects/$projectId/logs/export';

  // Health Checks
  static const String databaseHealth = '/api/database/health';
}