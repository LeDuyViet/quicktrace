//ignore_for_file: unused_import

import 'dart:io' show sleep;
import 'dart:math';
import 'package:quicktrace/quicktrace.dart';

final _random = Random();

// Simulate different types of operations with realistic timing
Future<Map<String, dynamic>> simulateDatabase(QuickTracer tracer, String query) async {
  tracer.span('Database: $query');

  // Simulate database query time (realistic variability)
  final baseTime = 50 + _random.nextInt(100); // 50-150ms
  await Future.delayed(Duration(milliseconds: baseTime));

  return {
    'query': query,
    'results': _random.nextInt(100),
    'time': baseTime,
  };
}

Future<bool> simulateCache(QuickTracer tracer, String key) async {
  tracer.span('Cache lookup: $key');

  // Cache operations are usually very fast
  await Future.delayed(Duration(milliseconds: 1 + _random.nextInt(5)));

  // 70% cache hit rate
  return _random.nextDouble() < 0.7;
}

Future<Map<String, dynamic>> simulateExternalAPI(QuickTracer tracer, String service) async {
  tracer.span('External API: $service');

  // External APIs can be slow and variable
  final baseTime = 200 + _random.nextInt(800); // 200ms-1s
  await Future.delayed(Duration(milliseconds: baseTime));

  return {
    'service': service,
    'status': 'success',
    'latency': baseTime,
  };
}

Future<void> simulateBusinessLogic(QuickTracer tracer, String complexity) async {
  tracer.span('Business logic: $complexity');

  int duration;
  switch (complexity) {
    case 'simple':
      duration = 5 + _random.nextInt(15); // 5-20ms
      break;
    case 'medium':
      duration = 20 + _random.nextInt(50); // 20-70ms
      break;
    case 'complex':
      duration = 100 + _random.nextInt(200); // 100-300ms
      break;
    default:
      duration = 10;
  }

  await Future.delayed(Duration(milliseconds: duration));
}

// HTTP Handlers with tracing
Future<Map<String, dynamic>> userProfileHandler(String? userId) async {
  final tracer = QuickTracer(
    'GET /api/user/profile',
    outputStyle: OutputStyle.styleDetailed,
    hideUltraFast: Duration(milliseconds: 2),
  );

  userId ??= '12345';

  // Check cache first
  final cacheHit = await simulateCache(tracer, 'user:$userId');

  Map<String, dynamic> userData;
  if (!cacheHit) {
    // Cache miss - query database
    userData = await simulateDatabase(tracer, 'SELECT * FROM users WHERE id = $userId');

    // Cache the result
    tracer.span('Cache store');
    await Future.delayed(Duration(milliseconds: 2));
  } else {
    tracer.span('Cache hit');
    await Future.delayed(Duration(milliseconds: 1));
    userData = {
      'id': userId,
      'name': 'John Doe',
      'cached': true,
    };
  }

  // Process business logic
  await simulateBusinessLogic(tracer, 'medium');

  // Enrich with additional data
  final enrichData = await simulateExternalAPI(tracer, 'user-enrichment-service');

  // Final response preparation
  tracer.span('Response serialization');
  await Future.delayed(Duration(milliseconds: 3));

  final response = {
    'user': userData,
    'enrichment': enrichData,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };

  tracer.end();
  return response;
}

Future<Map<String, dynamic>> analyticsHandler() async {
  final tracer = QuickTracer(
    'POST /api/analytics',
    outputStyle: OutputStyle.styleColorful,
    showSlowOnly: Duration(milliseconds: 50),
    groupSimilar: Duration(milliseconds: 20),
  );

  // Validate request
  tracer.span('Request validation');
  await Future.delayed(Duration(milliseconds: 5));

  // Multiple database queries for analytics
  for (int i = 1; i <= 3; i++) {
    final query = 'analytics_query_$i';
    await simulateDatabase(tracer, query);
  }

  // Complex data processing
  await simulateBusinessLogic(tracer, 'complex');

  // Generate multiple reports
  for (int i = 1; i <= 4; i++) {
    tracer.span('Generate report $i');
    await Future.delayed(Duration(milliseconds: 30 + _random.nextInt(40)));
  }

  // Store results
  await simulateDatabase(tracer, 'INSERT INTO analytics_results');

  final response = {
    'status': 'completed',
    'reports_generated': 4,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };

  tracer.end();
  return response;
}

Future<Map<String, dynamic>> healthCheckHandler() async {
  final tracer = QuickTracer(
    'GET /health',
    outputStyle: OutputStyle.styleMinimal,
    minTotalDuration: Duration(milliseconds: 10), // Only show if > 10ms
  );

  // Quick database ping
  tracer.span('Database ping');
  await Future.delayed(Duration(milliseconds: 2 + _random.nextInt(8)));

  // Quick cache ping
  tracer.span('Cache ping');
  await Future.delayed(Duration(milliseconds: 1 + _random.nextInt(3)));

  // External service check
  tracer.span('External service check');
  await Future.delayed(Duration(milliseconds: 5 + _random.nextInt(15)));

  final response = {
    'status': 'healthy',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };

  tracer.end();
  return response;
}

void main() async {
  print('🌐 Real-World HTTP API Server with QuickTrace');
  print('=============================================');

  // Demo mode - simulate requests instead of starting server
  print('\n🎬 Demo Mode - Simulating API Requests:');
  print('======================================');

  // Simulate various API calls
  print('\n1️⃣ User Profile Request (Medium complexity)');
  await userProfileHandler('12345');

  await Future.delayed(Duration(seconds: 1));

  print('\n2️⃣ Analytics Request (High complexity)');
  await analyticsHandler();

  await Future.delayed(Duration(seconds: 1));

  print('\n3️⃣ Health Check (Low complexity)');
  await healthCheckHandler();

  await Future.delayed(Duration(seconds: 1));

  print('\n4️⃣ Multiple Quick Health Checks');
  for (int i = 1; i <= 3; i++) {
    print('\nHealth check #$i:');
    await healthCheckHandler();
    await Future.delayed(Duration(milliseconds: 500));
  }

  print('\n✅ Demo completed!');
  print('\n💡 In a real server, you would integrate this with your HTTP framework:');
  print('   // Use QuickTracer in your route handlers');
  print('   // Set up middleware for automatic tracing');
}
