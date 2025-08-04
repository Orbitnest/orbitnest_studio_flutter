import 'package:flutter_test/flutter_test.dart';
import 'package:orbitnest_studio_flutter/orbitnest_studio_flutter.dart';

void main() {
  group('OrbitNestClient', () {
    test('can be created with required parameters', () {
      final client = OrbitNestClient.create(
        projectUrl: 'http://localhost:3001',
        projectSlug: 'test-project',
        anonKey: 'test-anon-key',
      );

      expect(client.projectSlug, 'test-project');
      expect(client.baseUrl, 'http://localhost:3001');
      expect(client.anonKey, 'test-anon-key');
      
      client.dispose();
    });
  });
}
