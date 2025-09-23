import 'package:test/test.dart';
import 'package:quicktrace/quicktrace.dart';

void main() {
  group('QuickTracer', () {
    test('should create tracer with default settings', () {
      final tracer = QuickTracer('Test Tracer');
      
      expect(tracer.isEnabled, isTrue);
      expect(tracer.isSilent, isFalse);
      expect(tracer.outputStyle, equals(OutputStyle.styleDefault));
      expect(tracer.measurements, isEmpty);
    });

    test('should record measurements correctly', () {
      final tracer = QuickTracer('Test Tracer', silent: true);
      
      tracer.span('Operation 1');
      tracer.span('Operation 2');
      tracer.end();
      
      expect(tracer.measurements.length, equals(3)); // 2 spans + end
      expect(tracer.measurements[0].statement, equals('Operation 1'));
      expect(tracer.measurements[1].statement, equals('Operation 2'));
      expect(tracer.measurements[2].statement, equals('End'));
    });

    test('should not record measurements when disabled', () {
      final tracer = QuickTracer('Test Tracer', enabled: false, silent: true);
      
      tracer.span('Operation 1');
      tracer.span('Operation 2');
      tracer.end();
      
      expect(tracer.measurements, isEmpty);
    });

    test('should allow runtime configuration changes', () {
      final tracer = QuickTracer('Test Tracer');
      
      // Test enable/disable
      expect(tracer.isEnabled, isTrue);
      tracer.setEnabled(false);
      expect(tracer.isEnabled, isFalse);
      
      // Test silent mode
      expect(tracer.isSilent, isFalse);
      tracer.setSilent(true);
      expect(tracer.isSilent, isTrue);
      
      // Test output style
      expect(tracer.outputStyle, equals(OutputStyle.styleDefault));
      tracer.setOutputStyle(OutputStyle.styleColorful);
      expect(tracer.outputStyle, equals(OutputStyle.styleColorful));
    });

    test('should calculate total duration', () async {
      final tracer = QuickTracer('Test Tracer', silent: true);
      
      await Future.delayed(Duration(milliseconds: 10));
      tracer.span('Operation 1');
      
      await Future.delayed(Duration(milliseconds: 10));
      tracer.end();
      
      expect(tracer.totalDuration.inMilliseconds, greaterThan(15));
    });

    test('should handle custom print conditions', () {
      var printConditionCalled = false;
      final tracer = QuickTracer('Test Tracer'); // Remove silent to trigger print condition
      
      tracer.setPrintCondition((t) {
        printConditionCalled = true;
        return false; // Return false to prevent actual printing in test
      });
      
      tracer.span('Operation 1');
      tracer.end();
      
      expect(printConditionCalled, isTrue);
    });
  });

  group('Measurement', () {
    test('should create measurement correctly', () {
      final measurement = Measurement(
        statement: 'Test Operation',
        duration: Duration(milliseconds: 100),
      );
      
      expect(measurement.statement, equals('Test Operation'));
      expect(measurement.duration, equals(Duration(milliseconds: 100)));
    });

    test('should implement equality correctly', () {
      final measurement1 = Measurement(
        statement: 'Test',
        duration: Duration(milliseconds: 100),
      );
      final measurement2 = Measurement(
        statement: 'Test',
        duration: Duration(milliseconds: 100),
      );
      final measurement3 = Measurement(
        statement: 'Different',
        duration: Duration(milliseconds: 100),
      );
      
      expect(measurement1, equals(measurement2));
      expect(measurement1, isNot(equals(measurement3)));
    });
  });

  group('ColorRules', () {
    test('should return correct colors for different durations', () {
      // Test very slow (> 3s)
      expect(ColorRules.getSpanColor(Duration(seconds: 4)), 
             contains(AnsiColors.red));
      
      // Test slow (1s-3s)
      expect(ColorRules.getSpanColor(Duration(seconds: 2)), 
             equals(AnsiColors.red));
      
      // Test medium-slow (500ms-1s)
      expect(ColorRules.getSpanColor(Duration(milliseconds: 750)), 
             equals(AnsiColors.yellow));
      
      // Test ultra fast (< 10ms)
      expect(ColorRules.getSpanColor(Duration(milliseconds: 5)), 
             equals(AnsiColors.brightBlack));
    });

    test('should return correct color names', () {
      expect(ColorRules.getDurationColorName(Duration(seconds: 4)), 
             equals('Very Slow'));
      expect(ColorRules.getDurationColorName(Duration(milliseconds: 5)), 
             equals('Ultra Fast'));
    });
  });

  group('SmartFiltering', () {
    final measurements = [
      Measurement(statement: 'Fast 1', duration: Duration(milliseconds: 5)),
      Measurement(statement: 'Fast 2', duration: Duration(milliseconds: 6)),
      Measurement(statement: 'Medium', duration: Duration(milliseconds: 50)),
      Measurement(statement: 'Slow', duration: Duration(milliseconds: 200)),
    ];

    test('should filter slow operations only', () {
      final filtered = SmartFiltering.applySmartFiltering(
        measurements: measurements,
        showSlowOnly: true,
        slowThreshold: Duration(milliseconds: 100),
      );
      
      expect(filtered.length, equals(1));
      expect((filtered[0] as Measurement).statement, equals('Slow'));
    });

    test('should hide ultra fast operations', () {
      final filtered = SmartFiltering.applySmartFiltering(
        measurements: measurements,
        hideUltraFast: true,
        ultraFastThreshold: Duration(milliseconds: 10),
      );
      
      expect(filtered.length, equals(2));
      expect((filtered[0] as Measurement).statement, equals('Medium'));
      expect((filtered[1] as Measurement).statement, equals('Slow'));
    });

    test('should group similar operations', () {
      final filtered = SmartFiltering.applySmartFiltering(
        measurements: measurements,
        groupSimilar: true,
        similarThreshold: Duration(milliseconds: 2),
      );
      
      expect(filtered.length, equals(3));
      expect(filtered[0], isA<GroupedMeasurement>());
      
      final group = filtered[0] as GroupedMeasurement;
      expect(group.count, equals(2));
      expect(group.name, contains('Fast 1'));
      expect(group.name, contains('similar'));
    });
  });

  group('OutputStyle', () {
    test('should have correct display names', () {
      expect(OutputStyle.styleDefault.displayName, equals('Default'));
      expect(OutputStyle.styleColorful.displayName, equals('Colorful'));
      expect(OutputStyle.styleMinimal.displayName, equals('Minimal'));
      expect(OutputStyle.styleDetailed.displayName, equals('Detailed'));
      expect(OutputStyle.styleTable.displayName, equals('Table'));
      expect(OutputStyle.styleJson.displayName, equals('JSON'));
    });
  });
}
