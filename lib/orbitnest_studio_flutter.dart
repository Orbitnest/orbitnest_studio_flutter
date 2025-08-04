library orbitnest_studio_flutter;

// Main client
export 'src/client/orbitnest_client.dart';

// Simplified APIs (recommended for most users)
export 'src/auth/orbitnest_auth.dart';
export 'src/database/orbitnest_database.dart';
export 'src/edge_functions/orbitnest_functions.dart';

// Authentication
export 'src/auth/models/user.dart';
export 'src/auth/models/session.dart';
export 'src/auth/models/auth_response.dart';
export 'src/auth/exceptions/auth_exception.dart';

// Authentication BLoC (for advanced users who need reactive state)
export 'src/auth/bloc/auth_bloc.dart';
export 'src/auth/bloc/auth_event.dart';
export 'src/auth/bloc/auth_state.dart';

// Database
export 'src/database/models/postgrest_response.dart';
export 'src/database/models/table_schema.dart';
export 'src/database/services/query_builder.dart';
export 'src/database/exceptions/database_exception.dart';

// Database BLoC (for advanced users who need reactive state)
export 'src/database/bloc/database_bloc.dart';
export 'src/database/bloc/database_event.dart';
export 'src/database/bloc/database_state.dart';

// Edge Functions
export 'src/edge_functions/models/function_response.dart';
export 'src/edge_functions/exceptions/function_exception.dart';

// Edge Functions BLoC (for advanced users who need reactive state)
export 'src/edge_functions/bloc/functions_bloc.dart';
export 'src/edge_functions/bloc/functions_event.dart';
export 'src/edge_functions/bloc/functions_state.dart';

// Types
export 'src/types/json_types.dart';
export 'src/types/response_types.dart';

// Utilities
export 'src/utils/env_config.dart';
export 'src/utils/logger.dart';

// Constants
export 'src/constants/constants.dart';
export 'src/constants/error_codes.dart';

// Base exception
export 'src/client/interceptors/error_interceptor.dart' show OrbitNestException;
