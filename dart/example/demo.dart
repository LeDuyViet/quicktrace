//ignore_for_file: unused_import

/// Demo file to showcase QuickTrace functionality
/// Run with: dart run example/demo.dart

import 'dart:io' show sleep;
import 'package:quicktrace/quicktrace.dart';

void main() async {
  print('🚀 QuickTrace for Dart & Flutter - Demo');
  print('========================================');
  
  // Demo 1: Basic colorful tracing
  print('\n1️⃣ Basic Colorful Tracing:');
  print('---------------------------');
  
  final tracer1 = QuickTracer(
    'API Request Processing',
    outputStyle: OutputStyle.styleColorful,
  );
  
  tracer1.span('Authenticate user');
  await Future.delayed(Duration(milliseconds: 25));
  
  tracer1.span('Query database');
  await Future.delayed(Duration(milliseconds: 150)); // Slow operation
  
  tracer1.span('Process business logic');
  await Future.delayed(Duration(milliseconds: 75));
  
  tracer1.span('Generate response');
  await Future.delayed(Duration(milliseconds: 10));
  
  tracer1.end();
  
  await Future.delayed(Duration(seconds: 1));
  
  // Demo 2: Smart filtering
  print('\n2️⃣ Smart Filtering (Hide < 20ms, Group Similar):');
  print('--------------------------------------------------');
  
  final tracer2 = QuickTracer(
    'Batch Processing',
    outputStyle: OutputStyle.styleDetailed,
    hideUltraFast: Duration(milliseconds: 20),
    groupSimilar: Duration(milliseconds: 10),
  );
  
  // Fast operations (will be hidden)
  tracer2.span('Quick validation 1');
  await Future.delayed(Duration(milliseconds: 5));
  
  tracer2.span('Quick validation 2');
  await Future.delayed(Duration(milliseconds: 8));
  
  // Similar operations (will be grouped)
  tracer2.span('Process item 1');
  await Future.delayed(Duration(milliseconds: 45));
  
  tracer2.span('Process item 2');
  await Future.delayed(Duration(milliseconds: 48));
  
  tracer2.span('Process item 3');
  await Future.delayed(Duration(milliseconds: 44));
  
  // Slow operation
  tracer2.span('Save to database');
  await Future.delayed(Duration(milliseconds: 200));
  
  tracer2.end();
  
  await Future.delayed(Duration(seconds: 1));
  
  // Demo 3: Silent mode with programmatic access
  print('\n3️⃣ Silent Mode - Programmatic Data Access:');
  print('-------------------------------------------');
  
  final tracer3 = QuickTracer(
    'Background Task',
    silent: true, // Don't print output
  );
  
  tracer3.span('Initialize');
  await Future.delayed(Duration(milliseconds: 30));
  
  tracer3.span('Execute task');
  await Future.delayed(Duration(milliseconds: 120));
  
  tracer3.span('Cleanup');
  await Future.delayed(Duration(milliseconds: 15));
  
  tracer3.end();
  
  // Access data programmatically
  print('📊 Silent tracer collected data:');
  print('   Total duration: ${DurationFormatter.format(tracer3.totalDuration)}');
  print('   Number of spans: ${tracer3.measurements.length - 1}');
  print('   Measurements:');
  
  for (int i = 0; i < tracer3.measurements.length - 1; i++) {
    final m = tracer3.measurements[i];
    final color = ColorRules.getSpanColor(m.duration);
    final colorName = ColorRules.getDurationColorName(m.duration);
    print('     ${i + 1}. ${m.statement}: ${DurationFormatter.format(m.duration)} ($colorName)');
  }
  
  await Future.delayed(Duration(seconds: 1));
  
  // Demo 4: JSON output for integration
  print('\n4️⃣ JSON Output for Integration:');
  print('--------------------------------');
  
  final tracer4 = QuickTracer(
    'Data Export',
    outputStyle: OutputStyle.styleJson,
  );
  
  tracer4.span('Load configuration');
  await Future.delayed(Duration(milliseconds: 20));
  
  tracer4.span('Connect to service');
  await Future.delayed(Duration(milliseconds: 100));
  
  tracer4.span('Export data');
  await Future.delayed(Duration(milliseconds: 250));
  
  tracer4.end();
  
  print('\n✅ Demo completed! QuickTrace for Dart is ready to use.');
  print('\n💡 Key Features Demonstrated:');
  print('   🎨 Beautiful colored output with multiple styles');
  print('   🔍 Smart filtering to reduce noise');
  print('   📊 Programmatic access to performance data');
  print('   🌍 Cross-platform ANSI color support');
  print('   ⚡ Zero-config usage with sensible defaults');
  
  print('\n📚 Next Steps:');
  print('   • Run other examples: dart run example/styles_example.dart');
  print('   • Integrate with your Flutter app');
  print('   • Use in production with silent mode');
  print('   • Set up monitoring with custom conditions');
}
