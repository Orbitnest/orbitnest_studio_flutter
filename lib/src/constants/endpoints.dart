/// API endpoint constants for OrbitNest Studio
class Endpoints {
  // Admin Authentication
  static const String adminRequestVerification =
      '/api/auth/request-verification';
  static const String adminSignup = '/api/auth/signup';
  static const String adminSignin = '/api/auth/signin';
  static const String adminProfile = '/api/auth/profile';
  static const String adminRequestPasswordReset =
      '/api/auth/reset-password-request';
  static const String adminResetPassword = '/api/auth/reset-password';
  static const String adminChangePassword = '/api/auth/change-password';
  static const String adminRefreshToken = '/api/auth/refresh';
  static const String adminSignout = '/api/auth/signout';

  // Admin User Management
  static const String adminUsers = '/api/admin/admins';
  static String adminUserById(String id) => '/api/admin/admins/$id';
  static String adminUpdatePassword(String id) =>
      '/api/admin/admins/$id/password';
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
      '/api/projects/$projectId/auth/signup-with-email';
  static String projectVerifySignup(String projectId) =>
      '/api/projects/$projectId/auth/verify-signup';
  static String projectSigninWithEmail(String projectId) =>
      '/api/projects/$projectId/auth/signin-with-email';
  static String projectVerifySignin(String projectId) =>
      '/api/projects/$projectId/auth/verify-signin';
  static String projectSignup(String projectId) =>
      '/api/projects/$projectId/auth/signup';
  static String projectSignin(String projectId) =>
      '/api/projects/$projectId/auth/signin';
  static String projectRecover(String projectId) =>
      '/api/projects/$projectId/auth/recover';
  static String projectResetPassword(String projectId) =>
      '/api/projects/$projectId/auth/reset-password';
  static String projectUser(String projectId) =>
      '/api/projects/$projectId/auth/user';
  static String projectUpdateUser(String projectId) =>
      '/api/projects/$projectId/auth/user';
  static String projectDeleteUser(String projectId) =>
      '/api/projects/$projectId/auth/user';
  static String projectRefresh(String projectId) =>
      '/api/projects/$projectId/auth/refresh';
  static String projectSignout(String projectId) =>
      '/api/projects/$projectId/auth/signout';
  static String projectSignoutAll(String projectId) =>
      '/api/projects/$projectId/auth/signout-all';

  // Admin Project Auth
  static String projectAdminUsers(String projectId) =>
      '/api/projects/$projectId/auth/admin/users';
  static String projectAdminUserById(String projectId, String userId) =>
      '/api/projects/$projectId/auth/admin/users/$userId';
  static String projectAdminStats(String projectId) =>
      '/api/projects/$projectId/auth/admin/stats';
  static String projectAdminConfig(String projectId) =>
      '/api/projects/$projectId/auth/admin/config';
  static String projectAdminUpdateConfig(String projectId) =>
      '/api/projects/$projectId/auth/admin/config';

  // Edge Functions
  static String projectFunctions(String projectId) =>
      '/api/projects/$projectId/functions';
  static String projectFunctionByName(String projectId, String name) =>
      '/api/projects/$projectId/functions/$name';
  static String projectFunctionLogs(String projectId, String name) =>
      '/api/projects/$projectId/functions/$name/logs';

  // Function Invocation
  static String invokeFunction(String projectId, String name) =>
      '/api/projects/$projectId/functions/$name/invoke';

  // Environment Variables
  static String projectEnvironmentVariables(String projectId) =>
      '/api/projects/$projectId/environment-variables';
  static String projectEnvironmentVariablesBulk(String projectId) =>
      '/api/projects/$projectId/environment-variables/bulk';
  static String projectEnvironmentVariableByName(
          String projectId, String name) =>
      '/api/projects/$projectId/environment-variables/$name';

  // Database Operations (Client endpoints using project slug)
  static String projectDatabaseSql(String projectSlug) =>
      '/api/project/$projectSlug/database/sql';
  static String projectDatabaseTables(String projectSlug) =>
      '/api/project/$projectSlug/database/tables';
  static String projectDatabaseTablesList(String projectSlug) =>
      '/api/project/$projectSlug/database/tables/list';
  static String projectDatabaseTableData(String projectSlug, String table) =>
      '/api/project/$projectSlug/database/tables/$table/data';
  static String projectDatabaseTableRows(String projectSlug, String table) =>
      '/api/project/$projectSlug/database/tables/$table/rows';
  static String projectDatabaseTableRowById(
          String projectSlug, String table, String rowId) =>
      '/api/project/$projectSlug/database/tables/$table/rows/$rowId';
  static String projectDatabaseTableBulkInsert(
          String projectSlug, String table) =>
      '/api/project/$projectSlug/database/tables/$table/rows/bulk';
  static String projectDatabaseTableBulkUpdate(
          String projectSlug, String table) =>
      '/api/project/$projectSlug/database/tables/$table/rows/bulk';
  static String projectDatabaseTableBulkDelete(
          String projectSlug, String table) =>
      '/api/project/$projectSlug/database/tables/$table/rows/bulk';
  static String projectDatabaseTableEnableRls(String projectSlug, String table) =>
      '/api/project/$projectSlug/database/tables/$table/rls/enable';
  static String projectDatabaseTableDisableRls(
          String projectSlug, String table) =>
      '/api/project/$projectSlug/database/tables/$table/rls/disable';
  static String projectDatabaseTablePolicies(String projectSlug, String table) =>
      '/api/project/$projectSlug/database/tables/$table/policies';
  static String projectDatabaseTablePolicyByName(
          String projectSlug, String table, String name) =>
      '/api/project/$projectSlug/database/tables/$table/policies/$name';

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
  static String projectEdgeFunctionConsoleLogs(
          String projectId, String functionName) =>
      '/api/projects/$projectId/logs/edge-functions/$functionName/console';
  static String projectEdgeFunctionErrorLogs(
          String projectId, String functionName) =>
      '/api/projects/$projectId/logs/edge-functions/$functionName/errors';
  static String projectExportLogs(String projectId) =>
      '/api/projects/$projectId/logs/export';

  // Health Checks
  static const String databaseHealth = '/api/database/health';
}
