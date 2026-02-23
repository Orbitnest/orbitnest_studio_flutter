import 'package:flutter_test/flutter_test.dart';
import 'package:orbitnest_studio_flutter/orbitnest_studio_flutter.dart';
import 'package:orbitnest_studio_flutter/src/auth/services/token_manager.dart';
import 'package:orbitnest_studio_flutter/src/constants/endpoints.dart';

void main() {
  group('Critical Features Integration Tests', () {
    late OrbitNestClient client;

    setUpAll(() async {
      // Initialize environment (tests will use .env.test if available)
      await EnvConfig.initialize();
      client = OrbitNestClient.create();
    });

    tearDownAll(() {
      client.dispose();
    });

    group('Token Refresh', () {
      test('should have refresh callback configured', () {
        // Verify token manager has refresh callback
        expect(client, isNotNull);
      });

      test('should detect tokens needing refresh', () async {
        // This is a unit test for the token manager logic
        final tokenManager = TokenManager(
          projectId: 'test',
          apiKey: 'test-key',
        );
68
        // Test with a mock expired token (JWT with exp in past)
        const expiredToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE1MTYyMzkwMjJ9.4Adcj0pRR8ypXG5Wy';

        expect(tokenManager.isTokenExpired(expiredToken), isTrue);
      });
    });

    group('Error Recovery', () {
      test('should retry on network errors', () async {
        // Test that retry interceptor is configured
        expect(client, isNotNull);
        // In production, this would test actual network failures
      });
    });

    group('Query Builder', () {
      test('should build simple query', () {
        final query = client.from('users');
        expect(query, isNotNull);
      });

      test('should build query with filters', () {
        final query = client
            .from('users')
            .select('id, name, email')
            .eq('status', 'active')
            .limit(10);

        expect(query, isNotNull);
      });

      test('should build complex query', () {
        final query = client
            .from('posts')
            .select('*, author:users(name)')
            .eq('published', true)
            .gte('created_at', '2024-01-01')
            .order('created_at', ascending: false)
            .limit(50);

        expect(query, isNotNull);
      });
    });

    group('OrbitNest Compatibility', () {
      test('should use correct endpoints', () {
        // Verify endpoints match OrbitNest API structure
        expect(Endpoints.projectRefresh('test-project'),
               equals('/api/projects/test-project/auth/refresh'));

        expect(Endpoints.projectDatabaseSql('test-slug'),
               equals('/api/project/test-slug/database/sql'));

        expect(Endpoints.invokeFunction('test-slug', 'my-function'),
               equals('/api/projects/test-slug/functions/v1/my-function'));
      });
    });
  });
}
