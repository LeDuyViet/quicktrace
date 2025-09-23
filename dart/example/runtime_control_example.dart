//ignore_for_file: unused_import

import 'dart:io' show sleep;
import 'package:quicktrace/quicktrace.dart';

Future<void> doSomeWork(QuickTracer tracer, String label) async {
  await Future.delayed(Duration(milliseconds: 20));
  tracer.span('Step 1: $label');

  await Future.delayed(Duration(milliseconds: 30));
  tracer.span('Step 2: $label');

  await Future.delayed(Duration(milliseconds: 15));
  tracer.span('Step 3: $label');
}

void main() async {
  print('🔧 Runtime Control Examples');
  print('============================');

  // Example 1: Enable/Disable tracing
  print('\n1️⃣ Enable/Disable Tracing');
  print('--------------------------');

  final tracer1 = QuickTracer('Runtime Control Demo');

  print('✅ Tracing enabled:');
  await doSomeWork(tracer1, 'Enabled');
  tracer1.end();

  print('\n❌ Tracing disabled:');
  tracer1.setEnabled(false);
  await doSomeWork(tracer1, 'Disabled'); // Won't collect data
  tracer1.end(); // Won't print anything

  // Example 2: Silent mode
  print('\n2️⃣ Silent Mode (Data Collection Only)');
  print('--------------------------------------');

  final tracer2 = QuickTracer(
    'Silent Mode Demo',
    outputStyle: OutputStyle.styleColorful,
  );

  tracer2.setSilent(true); // Collect data but don't print

  print('🔇 Silent mode - collecting data...');
  await doSomeWork(tracer2, 'Silent');
  tracer2.end(); // Won't print

  // Access collected data programmatically
  final measurements = tracer2.measurements;
  final totalDuration = tracer2.totalDuration;

  print('📊 Collected ${measurements.length} measurements');
  print('⏱️  Total duration: ${DurationFormatter.format(totalDuration)}');

  for (int i = 0; i < measurements.length - 1; i++) { // Exclude "End"
    final m = measurements[i];
    print('   ${i + 1}. ${m.statement}: ${DurationFormatter.format(m.duration)}');
  }

  // Example 3: Dynamic style changes
  print('\n3️⃣ Dynamic Style Changes');
  print('-------------------------');

  var tracer3 = QuickTracer('Style Change Demo');

  print('🎨 Starting with default style:');
  await doSomeWork(tracer3, 'Default Style');
  tracer3.end();

  // Change to colorful style
  tracer3 = QuickTracer(
    'Style Change Demo',
    outputStyle: OutputStyle.styleColorful,
  );

  print('\n🌈 Changed to colorful style:');
  await doSomeWork(tracer3, 'Colorful Style');
  tracer3.end();

  // Change to minimal style
  tracer3 = QuickTracer('Style Change Demo');
  tracer3.setOutputStyle(OutputStyle.styleMinimal);

  print('\n📝 Changed to minimal style:');
  await doSomeWork(tracer3, 'Minimal Style');
  tracer3.end();

  // Example 4: Custom print conditions
  print('\n4️⃣ Custom Print Conditions');
  print('---------------------------');

  final tracer4 = QuickTracer('Conditional Printing');

  // Set custom condition: only print if total > 50ms
  tracer4.setPrintCondition((t) => t.totalDuration > Duration(milliseconds: 50));

  print('⚡ Fast execution (won\'t print):');
  await Future.delayed(Duration(milliseconds: 10));
  tracer4.span('Quick task');
  tracer4.end(); // Won't print because < 50ms

  print('🐌 Slow execution (will print):');
  final tracer5 = QuickTracer('Conditional Printing');
  tracer5.setPrintCondition((t) => t.totalDuration > Duration(milliseconds: 50));

  await doSomeWork(tracer5, 'Slow enough'); // Will print because > 50ms
  tracer5.end();

  // Example 5: Data inspection without printing
  print('\n5️⃣ Data Inspection');
  print('-------------------');

  final tracer6 = QuickTracer(
    'Data Inspection',
    silent: true, // Silent to avoid printing
  );

  await Future.delayed(Duration(milliseconds: 25));
  tracer6.span('Database connection');

  await Future.delayed(Duration(milliseconds: 75));
  tracer6.span('Query execution');

  await Future.delayed(Duration(milliseconds: 40));
  tracer6.span('Result processing');

  tracer6.end();

  // Inspect collected data
  print('📈 Total measurements: ${tracer6.measurements.length}');
  print('⏱️  Total execution time: ${DurationFormatter.format(tracer6.totalDuration)}');
  print('🔧 Tracer enabled: ${tracer6.isEnabled}');
  print('🔇 Tracer silent: ${tracer6.isSilent}');
  print('🎨 Output style: ${tracer6.outputStyle.displayName}');
}
