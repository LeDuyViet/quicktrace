//ignore_for_file: unused_import

import 'dart:io' show sleep;
import 'package:quicktrace/quicktrace.dart';

Future<void> simulateVariousOperations(QuickTracer tracer) async {
  // Ultra fast operations
  tracer.span('Ultra fast operation 1');
  await Future.delayed(Duration(microseconds: 500));

  tracer.span('Ultra fast operation 2');
  await Future.delayed(Duration(microseconds: 800));

  // Fast operations
  tracer.span('Fast validation');
  await Future.delayed(Duration(milliseconds: 5));

  tracer.span('Quick lookup');
  await Future.delayed(Duration(milliseconds: 8));

  // Medium operations
  tracer.span('Medium processing');
  await Future.delayed(Duration(milliseconds: 45));

  tracer.span('Similar processing');
  await Future.delayed(Duration(milliseconds: 48)); // Similar to above

  tracer.span('Another similar task');
  await Future.delayed(Duration(milliseconds: 44)); // Also similar

  // Slow operations
  tracer.span('Slow database query');
  await Future.delayed(Duration(milliseconds: 150));

  tracer.span('Complex computation');
  await Future.delayed(Duration(milliseconds: 200));

  // Very slow operation
  tracer.span('Very slow external API call');
  await Future.delayed(Duration(milliseconds: 800));
}

void main() async {
  print('🎯 Smart Filtering Examples');
  print('===========================');

  // Example 1: No filtering (show all)
  print('\n1️⃣ No Filtering (Show All Operations)');
  print('-------------------------------------');
  final tracer1 = QuickTracer(
    'Complete Trace',
    outputStyle: OutputStyle.styleDetailed,
  );
  await simulateVariousOperations(tracer1);
  tracer1.end();

  await Future.delayed(Duration(seconds: 1));

  // Example 2: Hide ultra fast operations
  print('\n2️⃣ Hide Ultra Fast Operations (< 2ms)');
  print('--------------------------------------');
  final tracer2 = QuickTracer(
    'Filtered - No Ultra Fast',
    outputStyle: OutputStyle.styleDetailed,
    hideUltraFast: Duration(milliseconds: 2),
  );
  await simulateVariousOperations(tracer2);
  tracer2.end();

  await Future.delayed(Duration(seconds: 1));

  // Example 3: Show only slow operations
  print('\n3️⃣ Show Only Slow Operations (>= 100ms)');
  print('----------------------------------------');
  final tracer3 = QuickTracer(
    'Slow Operations Only',
    outputStyle: OutputStyle.styleDetailed,
    showSlowOnly: Duration(milliseconds: 100),
  );
  await simulateVariousOperations(tracer3);
  tracer3.end();

  await Future.delayed(Duration(seconds: 1));

  // Example 4: Group similar operations
  print('\n4️⃣ Group Similar Operations (±10ms threshold)');
  print('----------------------------------------------');
  final tracer4 = QuickTracer(
    'Grouped Similar',
    outputStyle: OutputStyle.styleDetailed,
    groupSimilar: Duration(milliseconds: 10),
  );
  await simulateVariousOperations(tracer4);
  tracer4.end();

  await Future.delayed(Duration(seconds: 1));

  // Example 5: Combined smart filtering
  print('\n5️⃣ Combined Smart Filtering');
  print('----------------------------');
  final tracer5 = QuickTracer(
    'Smart Filtered',
    outputStyle: OutputStyle.styleDetailed,
    showSlowOnly: Duration(milliseconds: 50),    // Show slow >= 50ms
    hideUltraFast: Duration(milliseconds: 2),    // Hide ultra fast < 2ms
    groupSimilar: Duration(milliseconds: 15),    // Group similar ±15ms
  );
  await simulateVariousOperations(tracer5);
  tracer5.end();
}
