//ignore_for_file: unused_import

import 'dart:io' show sleep;
import 'package:quicktrace/quicktrace.dart';

void main() async {
  print('🎯 Advanced QuickTrace Example');
  print('===============================');
  
  // Advanced usage với smart filtering
  final tracer = QuickTracer(
    'Advanced Example',
    outputStyle: OutputStyle.styleDetailed,
    hideUltraFast: Duration(milliseconds: 1),
    showSlowOnly: Duration(milliseconds: 10),
    groupSimilar: Duration(milliseconds: 5),
  );

  // Simulate database operations
  await Future.delayed(Duration(milliseconds: 100));
  tracer.span('Connect to database');

  await Future.delayed(Duration(milliseconds: 45));
  tracer.span('Execute query 1');

  await Future.delayed(Duration(milliseconds: 50)); // Similar to query 1
  tracer.span('Execute query 2');

  await Future.delayed(Duration(milliseconds: 5));
  tracer.span('Cache result');

  await Future.delayed(Duration(microseconds: 500)); // Will be hidden
  tracer.span('Ultra fast operation');

  await Future.delayed(Duration(milliseconds: 200));
  tracer.span('Process business logic');

  await Future.delayed(Duration(milliseconds: 30));
  tracer.span('Send notification');

  tracer.end();
}
