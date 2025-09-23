//ignore_for_file: unused_import

import 'dart:io' show sleep;
import 'package:quicktrace/quicktrace.dart';

Future<void> simulateWork(QuickTracer tracer) async {
  tracer.span('Load configuration');
  await Future.delayed(Duration(milliseconds: 25));

  tracer.span('Connect to database');
  await Future.delayed(Duration(milliseconds: 75));

  tracer.span('Execute complex query');
  await Future.delayed(Duration(milliseconds: 120));

  tracer.span('Process results');
  await Future.delayed(Duration(milliseconds: 45));

  tracer.span('Cache data');
  await Future.delayed(Duration(milliseconds: 15));

  tracer.span('Generate response');
  await Future.delayed(Duration(milliseconds: 8));
}

void main() async {
  print('🎨 QuickTrace Output Styles Demo');
  print('=================================');

  final styles = [
    {'name': 'Default', 'style': OutputStyle.styleDefault},
    {'name': 'Colorful', 'style': OutputStyle.styleColorful},
    {'name': 'Minimal', 'style': OutputStyle.styleMinimal},
    {'name': 'Detailed', 'style': OutputStyle.styleDetailed},
    {'name': 'Table', 'style': OutputStyle.styleTable},
    {'name': 'JSON', 'style': OutputStyle.styleJson},
  ];

  for (final styleInfo in styles) {
    print('\n\x1B[1;36m=================== ${styleInfo['name']} STYLE ===================\x1B[0m');

    final tracer = QuickTracer(
      'API Processing - ${styleInfo['name']} Style',
      outputStyle: styleInfo['style'] as OutputStyle,
    );

    await simulateWork(tracer);
    tracer.end();

    await Future.delayed(Duration(milliseconds: 500)); // Brief pause between styles
  }
}
