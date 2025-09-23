//ignore_for_file: unused_import

import 'dart:io' show sleep;
import 'package:quicktrace/quicktrace.dart';

void main() async {
  print('🚀 Basic QuickTrace Example');
  print('==========================');
  
  // Basic usage với default style
  final tracer = QuickTracer('Basic Example');

  await Future.delayed(Duration(milliseconds: 30));
  tracer.span('Initialize database');

  await Future.delayed(Duration(milliseconds: 50));
  tracer.span('Load user data');

  await Future.delayed(Duration(milliseconds: 20));
  tracer.span('Process data');

  await Future.delayed(Duration(milliseconds: 10));
  tracer.span('Generate response');

  tracer.end();
}
