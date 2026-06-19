import 'package:flutter/material.dart';
import 'package:orbitnest_studio_flutter/orbitnest_studio_flutter.dart';

/// Minimal example: initialize the client, sign in, and read a table.
///
/// Provide your project's anon key via a `.env` file (see `.env.example`)
/// or pass it directly to [OrbitNestClient.create].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Loads ORBITNEST_ANON_KEY from a bundled `.env`.
  await EnvConfig.initialize();
  final orbitnest = OrbitNestClient.create();

  runApp(MyApp(orbitnest: orbitnest));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.orbitnest});

  final OrbitNestClient orbitnest;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrbitNest Studio Example',
      home: HomeScreen(orbitnest: orbitnest),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.orbitnest});

  final OrbitNestClient orbitnest;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _status = 'Idle';
  List<Map<String, dynamic>> _rows = const [];

  OrbitNestClient get _client => widget.orbitnest;

  Future<void> _signInAndLoad() async {
    setState(() => _status = 'Signing in...');
    try {
      // Password sign-in.
      await _client.auth.signInWithPassword(
        email: 'user@example.com',
        password: 'secret123',
      );

      // Query a table with the Supabase-compatible builder.
      final response = await _client
          .from('users')
          .select('id, name, email')
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(20)
          .execute();

      setState(() {
        _rows = List<Map<String, dynamic>>.from(response.data);
        _status = 'Loaded ${_rows.length} rows';
      });
    } on OrbitNestException catch (e) {
      setState(() => _status = 'Error: ${e.message}');
    }
  }

  @override
  void dispose() {
    _client.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OrbitNest Studio')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_status),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _rows.length,
              itemBuilder: (context, i) {
                final row = _rows[i];
                return ListTile(
                  title: Text('${row['name']}'),
                  subtitle: Text('${row['email']}'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _signInAndLoad,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
