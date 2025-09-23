import 'dart:convert';
import 'dart:io' show Platform;

import 'measurement.dart';
import 'output_styles.dart';
import 'color_rules.dart';
import 'smart_filtering.dart';
import 'duration_formatter.dart';

/// Default minimum duration to display trace (100ms)
const Duration defaultMinDuration = Duration(milliseconds: 100);

/// Main tracing class for QuickTrace
class QuickTracer {
  final String name;
  final List<Measurement> _measurements = [];
  DateTime _lastTime = DateTime.now();
  final DateTime _totalTime = DateTime.now();
  
  // Configuration
  bool _enabled = true;
  bool _silent = false;
  OutputStyle _outputStyle = OutputStyle.styleDefault;
  
  // Print condition
  bool Function(QuickTracer)? _printCondition;
  
  // Caller info
  String? _callerInfo;
  
  // Smart filtering options
  bool _showSlowOnly = false;
  Duration? _slowThreshold;
  bool _hideUltraFast = false;
  Duration? _ultraFastThreshold;
  bool _groupSimilar = false;
  Duration? _similarThreshold;

  /// Creates a new QuickTracer instance
  QuickTracer(
    this.name, {
    OutputStyle outputStyle = OutputStyle.styleDefault,
    Duration? minTotalDuration,
    Duration? minSpanDuration,
    bool Function(QuickTracer)? customCondition,
    Duration? showSlowOnly,
    Duration? hideUltraFast,
    Duration? groupSimilar,
    bool enabled = true,
    bool silent = false,
  }) : _outputStyle = outputStyle,
       _enabled = enabled,
       _silent = silent {
    
    // Set up print condition
    if (customCondition != null) {
      _printCondition = customCondition;
    } else if (minTotalDuration != null) {
      _printCondition = (tracer) => tracer.totalDuration >= minTotalDuration;
    } else if (minSpanDuration != null) {
      _printCondition = (tracer) {
        return tracer._measurements.any((m) => m.duration >= minSpanDuration);
      };
    } else {
      _printCondition = (tracer) => tracer.totalDuration >= defaultMinDuration;
    }

    // Smart filtering setup
    if (showSlowOnly != null) {
      _showSlowOnly = true;
      _slowThreshold = showSlowOnly;
    }
    if (hideUltraFast != null) {
      _hideUltraFast = true;
      _ultraFastThreshold = hideUltraFast;
    }
    if (groupSimilar != null) {
      _groupSimilar = true;
      _similarThreshold = groupSimilar;
    }

    // Capture caller info (simplified for Dart)
    try {
      final stackTrace = StackTrace.current.toString();
      final lines = stackTrace.split('\n');
      if (lines.length > 2) {
        _callerInfo = _extractCallerInfo(lines[2]);
      }
    } catch (e) {
      // Caller info is optional
    }
  }

  /// Extract caller info from stack trace line
  String? _extractCallerInfo(String stackLine) {
    // Simple extraction - in real implementation might be more sophisticated
    final regex = RegExp(r'(\w+\.dart):(\d+)');
    final match = regex.firstMatch(stackLine);
    if (match != null) {
      return '${match.group(1)}:${match.group(2)}';
    }
    return null;
  }

  /// Record a span with the given statement
  void span(String statement) {
    if (!_enabled) return;

    final now = DateTime.now();
    final duration = now.difference(_lastTime);
    _measurements.add(Measurement(
      statement: statement,
      duration: duration,
    ));
    _lastTime = now;
  }

  /// End tracing and print output
  void end() {
    if (!_enabled) return;

    span('End');

    if (_silent) return;

    // Check print condition
    if (_printCondition != null && !_printCondition!(this)) {
      return;
    }

    // Generate and print output
    final output = _generateOutput();
    print(output);
  }

  /// Generate output based on current style
  String _generateOutput() {
    switch (_outputStyle) {
      case OutputStyle.styleColorful:
        return _generateColorfulOutput();
      case OutputStyle.styleMinimal:
        return _generateMinimalOutput();
      case OutputStyle.styleDetailed:
        return _generateDetailedOutput();
      case OutputStyle.styleTable:
        return _generateTableOutput();
      case OutputStyle.styleJson:
        return _generateJsonOutput();
      case OutputStyle.styleDefault:
      default:
        return _generateDefaultOutput();
    }
  }

  /// Generate default output
  String _generateDefaultOutput() {
    final buffer = StringBuffer();
    final totalDuration = this.totalDuration;

    buffer.writeln(AnsiColors.colorizeWithStyle(
      '=' * 70, AnsiColors.cyan, AnsiColors.bold));
    buffer.writeln(AnsiColors.colorizeWithStyle(
      '| $name', AnsiColors.yellow, AnsiColors.bold));
    buffer.writeln(AnsiColors.colorizeWithStyle(
      '=' * 70, AnsiColors.cyan, AnsiColors.bold));
    buffer.writeln(AnsiColors.colorizeWithStyle(
      '| Total time: ', AnsiColors.green, AnsiColors.bold) +
      AnsiColors.colorize(DurationFormatter.format(totalDuration), AnsiColors.green));
    buffer.writeln(AnsiColors.colorize('-' * 70, AnsiColors.cyan));
    buffer.writeln(AnsiColors.colorizeWithStyle(
      '| Span                                        | Execution time', 
      AnsiColors.magenta, AnsiColors.bold));
    buffer.writeln(AnsiColors.colorize('-' * 70, AnsiColors.cyan));

    // Exclude the "End" measurement
    for (final m in _measurements.take(_measurements.length - 1)) {
      final spanColor = ColorRules.getSpanColor(m.duration);
      buffer.write('| ');
      buffer.write(AnsiColors.colorize(
        m.statement.padRight(43), spanColor));
      buffer.write(' | ');
      buffer.write(AnsiColors.colorize(
        DurationFormatter.format(m.duration).padRight(18), spanColor));
      buffer.writeln(' |');
    }

    buffer.writeln(AnsiColors.colorizeWithStyle(
      '=' * 70, AnsiColors.cyan, AnsiColors.bold));

    return buffer.toString();
  }

  /// Generate colorful output
  String _generateColorfulOutput() {
    final buffer = StringBuffer();
    final totalDuration = this.totalDuration;
    
    const nameWidth = 35;
    const durationWidth = 25;
    const totalTableWidth = nameWidth + durationWidth + 4;

    // Modern Unicode borders
    final topBorder = '┌${'─' * (totalTableWidth - 2)}┐';
    final separator = '├${'─' * (totalTableWidth - 2)}┤';
    final bottomBorder = '└${'─' * (totalTableWidth - 2)}┘';

    // Header
    buffer.writeln(AnsiColors.colorizeWithStyle(
      topBorder, AnsiColors.cyan, AnsiColors.bold));

    // Title row
    final titleText = '🚀 $name';
    final titlePadding = ((totalTableWidth - titleText.length - 2) / 2).floor();
    final remainingPadding = totalTableWidth - titleText.length - titlePadding - 2;
    
    buffer.writeln(AnsiColors.colorizeWithStyle(
      '│${' ' * titlePadding}$titleText${' ' * remainingPadding}│',
      AnsiColors.yellow, AnsiColors.bold));

    // Caller info if available
    if (_callerInfo != null) {
      final callerInfo = '📍 File: $_callerInfo';
      final callerPadding = ((totalTableWidth - callerInfo.length - 2) / 2).floor();
      final remainingCallerPadding = totalTableWidth - callerInfo.length - callerPadding - 2;
      
      buffer.writeln(AnsiColors.colorize(
        '│${' ' * callerPadding}$callerInfo${' ' * remainingCallerPadding}│',
        AnsiColors.brightBlack));
    }

    buffer.writeln(AnsiColors.colorizeWithStyle(
      separator, AnsiColors.cyan, AnsiColors.bold));

    // Total time row
    final totalTimeStr = DurationFormatter.format(totalDuration);
    buffer.writeln(AnsiColors.colorizeWithStyle(
      '│ ⏱️  Total Time: ${' ' * (nameWidth - 16)} │ $totalTimeStr',
      AnsiColors.green, AnsiColors.bold));

    buffer.writeln(AnsiColors.colorize(separator, AnsiColors.cyan));

    // Column headers
    buffer.writeln(AnsiColors.colorizeWithStyle(
      '│ ${'📋 Span'.padRight(nameWidth)} │ ⏰ Duration',
      AnsiColors.magenta, AnsiColors.bold));

    buffer.writeln(AnsiColors.colorize(separator, AnsiColors.cyan));

    // Spans
    for (final m in _measurements.take(_measurements.length - 1)) {
      final spanColor = ColorRules.getSpanColor(m.duration);
      
      var spanName = m.statement;
      if (spanName.length > nameWidth) {
        spanName = '${spanName.substring(0, nameWidth - 3)}...';
      }
      
      buffer.write('│ ');
      buffer.write(AnsiColors.colorize(spanName.padRight(nameWidth), spanColor));
      buffer.write(' │ ');
      buffer.write(AnsiColors.colorize(DurationFormatter.format(m.duration), spanColor));
      buffer.writeln();
    }

    buffer.writeln(AnsiColors.colorizeWithStyle(
      bottomBorder, AnsiColors.cyan, AnsiColors.bold));

    return buffer.toString();
  }

  /// Generate minimal output
  String _generateMinimalOutput() {
    final buffer = StringBuffer();
    final totalDuration = this.totalDuration;
    
    const nameWidth = 35;
    const durationWidth = 25;
    const totalWidth = nameWidth + durationWidth + 4;

    final topBorder = '┌${'─' * (totalWidth - 2)}┐';
    final separator = '├${'─' * (totalWidth - 2)}┤';
    final bottomBorder = '└${'─' * (totalWidth - 2)}┘';

    buffer.writeln(AnsiColors.colorizeWithStyle(
      topBorder, AnsiColors.cyan, AnsiColors.bold));

    // Title and total time
    final titleText = '⚡ $name';
    final totalTimeStr = DurationFormatter.format(totalDuration);
    
    buffer.writeln(AnsiColors.colorizeWithStyle(
      '│ ${titleText.padRight(nameWidth)} │ $totalTimeStr',
      AnsiColors.cyan, AnsiColors.bold));

    // Caller info if available
    if (_callerInfo != null) {
      final callerInfo = '📍 File: $_callerInfo';
      buffer.writeln(AnsiColors.colorize(
        '│ ${callerInfo.padRight(nameWidth)} │ ',
        AnsiColors.brightBlack));
    }

    buffer.writeln(AnsiColors.colorize(separator, AnsiColors.cyan));

    // Minimal span listing
    for (final m in _measurements.take(_measurements.length - 1)) {
      final spanColor = ColorRules.getSpanColor(m.duration);
      
      var spanName = '  └─ ${m.statement}';
      if (spanName.length > nameWidth) {
        spanName = '${spanName.substring(0, nameWidth - 3)}...';
      }
      
      buffer.write('│ ');
      buffer.write(AnsiColors.colorize(spanName.padRight(nameWidth), spanColor));
      buffer.write(' │ ');
      buffer.write(AnsiColors.colorize(DurationFormatter.format(m.duration), spanColor));
      buffer.writeln();
    }

    buffer.writeln(AnsiColors.colorizeWithStyle(
      bottomBorder, AnsiColors.cyan, AnsiColors.bold));

    return buffer.toString();
  }

  /// Generate detailed output with smart filtering
  String _generateDetailedOutput() {
    final buffer = StringBuffer();
    final totalDuration = this.totalDuration;
    
    const indexWidth = 3;
    const nameWidth = 30;
    const durationWidth = 15;
    const percentWidth = 8;
    const barWidth = 12;
    
    const totalWidth = indexWidth + nameWidth + durationWidth + percentWidth + barWidth + 12;

    // Modern Unicode borders
    final topBorder = '╔${'═' * (totalWidth - 2)}╗';
    final separator = '╠${'═' * (totalWidth - 2)}╣';
    final thinSeparator = '╟${'─' * (totalWidth - 2)}╢';
    final bottomBorder = '╚${'═' * (totalWidth - 2)}╝';

    // Header
    buffer.writeln(AnsiColors.colorizeWithStyle(
      topBorder, AnsiColors.blue, AnsiColors.bold));

    // Title row
    final titleText = '🎯 TRACE: $name';
    final titlePadding = ((totalWidth - titleText.length - 2) / 2).floor();
    final remainingPadding = totalWidth - titleText.length - titlePadding - 2;
    
    buffer.writeln(AnsiColors.colorizeWithStyle(
      '║${' ' * titlePadding}$titleText${' ' * remainingPadding}║',
      AnsiColors.magenta, AnsiColors.bold));

    buffer.writeln(AnsiColors.colorizeWithStyle(
      separator, AnsiColors.blue, AnsiColors.bold));

    // Summary section
    buffer.writeln(AnsiColors.colorizeWithStyle(
      '║ 📊 SUMMARY${' ' * (totalWidth - 13)}║',
      AnsiColors.green, AnsiColors.bold));

    // Total execution time
    final totalTimeStr = DurationFormatter.format(totalDuration);
    buffer.write('║ • Total Execution Time: ');
    buffer.write(AnsiColors.colorizeWithStyle(totalTimeStr, AnsiColors.green, AnsiColors.bold));
    final usedWidth = 26 + totalTimeStr.length; // "║ • Total Execution Time: " length
    final paddingRight = totalWidth - usedWidth - 1;
    buffer.writeln('${' ' * (paddingRight > 0 ? paddingRight : 0)}║');

    // Number of spans
    final spanCount = _measurements.length - 1;
    final spanCountStr = spanCount.toString();
    buffer.write('║ • Number of Spans: ');
    buffer.write(AnsiColors.colorizeWithStyle(spanCountStr, AnsiColors.blue, AnsiColors.bold));
    final usedWidth2 = 21 + spanCountStr.length;
    final paddingRight2 = totalWidth - usedWidth2 - 1;
    buffer.writeln('${' ' * (paddingRight2 > 0 ? paddingRight2 : 0)}║');

    // Find slowest operation
    var slowest = _measurements.take(_measurements.length - 1).fold<Measurement>(
      _measurements.first,
      (prev, curr) => curr.duration > prev.duration ? curr : prev,
    );

    var slowestName = slowest.statement;
    if (slowestName.length > 25) {
      slowestName = '${slowestName.substring(0, 22)}...';
    }

    buffer.write('║ • Slowest Operation: ');
    buffer.write(AnsiColors.colorizeWithStyle(slowestName, AnsiColors.red, AnsiColors.bold));
    final usedWidth3 = 23 + slowestName.length;
    final paddingRight3 = totalWidth - usedWidth3 - 1;
    buffer.writeln('${' ' * (paddingRight3 > 0 ? paddingRight3 : 0)}║');

    final slowestDurStr = DurationFormatter.format(slowest.duration);
    buffer.write('║ • Slowest Duration: ');
    buffer.write(AnsiColors.colorizeWithStyle(slowestDurStr, AnsiColors.red, AnsiColors.bold));
    final usedWidth4 = 21 + slowestDurStr.length;
    final paddingRight4 = totalWidth - usedWidth4 - 1;
    buffer.writeln('${' ' * (paddingRight4 > 0 ? paddingRight4 : 0)}║');

    // Caller info if available
    if (_callerInfo != null) {
      buffer.write('║ • File: ');
      buffer.write(AnsiColors.colorizeWithStyle(_callerInfo!, AnsiColors.brightBlack, AnsiColors.bold));
      buffer.writeln('║');
    }

    buffer.writeln(AnsiColors.colorizeWithStyle(
      separator, AnsiColors.blue, AnsiColors.bold));

    // Detailed breakdown header
    buffer.writeln(AnsiColors.colorizeWithStyle(
      '║ 🔍 DETAILED BREAKDOWN${' ' * (totalWidth - 23)}║',
      AnsiColors.magenta, AnsiColors.bold));
    buffer.writeln(AnsiColors.colorizeWithStyle(
      thinSeparator, AnsiColors.blue, AnsiColors.bold));

    // Column headers
    buffer.write('║');
    buffer.write(AnsiColors.colorizeWithStyle(' #'.padLeft(indexWidth), AnsiColors.magenta, AnsiColors.bold));
    buffer.write(' │');
    buffer.write(AnsiColors.colorizeWithStyle(' Operation'.padRight(nameWidth - 1), AnsiColors.magenta, AnsiColors.bold));
    buffer.write(' │');
    buffer.write(AnsiColors.colorizeWithStyle(' Duration'.padLeft(durationWidth - 1), AnsiColors.magenta, AnsiColors.bold));
    buffer.write(' │');
    buffer.write(AnsiColors.colorizeWithStyle(' Percent'.padLeft(percentWidth - 1), AnsiColors.magenta, AnsiColors.bold));
    buffer.write(' │');
    buffer.write(AnsiColors.colorizeWithStyle(' Progress'.padRight(barWidth - 1), AnsiColors.magenta, AnsiColors.bold));
    buffer.writeln(' ║');

    buffer.writeln(AnsiColors.colorize(thinSeparator, AnsiColors.cyan));

    // Apply smart filtering
    final filteredData = SmartFiltering.applySmartFiltering(
      measurements: _measurements.take(_measurements.length - 1).toList(),
      showSlowOnly: _showSlowOnly,
      slowThreshold: _slowThreshold,
      hideUltraFast: _hideUltraFast,
      ultraFastThreshold: _ultraFastThreshold,
      groupSimilar: _groupSimilar,
      similarThreshold: _similarThreshold,
    );

    // Data rows
    for (int i = 0; i < filteredData.length; i++) {
      final item = filteredData[i];
      String operationName;
      Duration duration;
      bool isGrouped = false;

      if (item is GroupedMeasurement) {
        operationName = item.name;
        duration = item.avgTime;
        isGrouped = true;
      } else if (item is Measurement) {
        operationName = item.statement;
        duration = item.duration;
      } else {
        continue;
      }

      final percentage = duration.inMicroseconds / totalDuration.inMicroseconds * 100;
      
      // Progress bar
      var barLength = (percentage / 8).floor();
      if (barLength > barWidth - 1) barLength = barWidth - 1;
      if (barLength < 0) barLength = 0;
      
      final progressBar = '${'█' * barLength}${'░' * (barWidth - 1 - barLength)}';
      
      // Truncate operation name if too long
      if (operationName.length > nameWidth - 1) {
        operationName = '${operationName.substring(0, nameWidth - 4)}...';
      }
      
      final percentStr = '${percentage.toStringAsFixed(1)}%';
      final spanColor = ColorRules.getSpanColor(duration);
      final progressColor = '${AnsiColors.blue}${AnsiColors.bold}';
      
      // Add icon for grouped items
      var displayName = operationName;
      if (isGrouped) {
        displayName = '📦 $operationName';
      }
      
      buffer.write('║');
      buffer.write(' ${(i + 1).toString().padLeft(indexWidth)}');
      buffer.write(' │ ');
      buffer.write(AnsiColors.colorize(displayName.padRight(nameWidth - 1), spanColor));
      buffer.write(' │ ');
      buffer.write(AnsiColors.colorize(DurationFormatter.format(duration).padLeft(durationWidth - 2), spanColor));
      buffer.write(' │ ');
      buffer.write(AnsiColors.colorize(percentStr.padLeft(percentWidth - 2), spanColor));
      buffer.write(' │ ');
      buffer.write(AnsiColors.colorize(progressBar.padRight(barWidth - 1), progressColor));
      buffer.writeln(' ║');
    }

    // Show filtering summary if any filters are applied
    if (_showSlowOnly || _hideUltraFast || _groupSimilar) {
      buffer.writeln(AnsiColors.colorize(thinSeparator, AnsiColors.cyan));
      
      final originalCount = _measurements.length - 1;
      final filteredCount = filteredData.length;
      
      final activeFilters = <String>[];
      if (_showSlowOnly && _slowThreshold != null) {
        activeFilters.add('slow>${_slowThreshold}');
      }
      if (_hideUltraFast && _ultraFastThreshold != null) {
        activeFilters.add('hide<${_ultraFastThreshold}');
      }
      if (_groupSimilar && _similarThreshold != null) {
        activeFilters.add('group±${_similarThreshold}');
      }
      
      final filterInfo = '🔍 Filtered: $filteredCount/$originalCount spans | Active: ${activeFilters.join(', ')}';
      
      buffer.write('║ ');
      buffer.write(AnsiColors.colorize(filterInfo.padRight(totalWidth - 4), AnsiColors.brightBlack));
      buffer.writeln(' ║');
    }

    buffer.writeln(AnsiColors.colorizeWithStyle(
      bottomBorder, AnsiColors.blue, AnsiColors.bold));

    return buffer.toString();
  }

  /// Generate table output
  String _generateTableOutput() {
    final buffer = StringBuffer();
    final totalDuration = this.totalDuration;
    
    const indexWidth = 4;
    const nameWidth = 45;
    const durationWidth = 20;
    
    const totalTableWidth = indexWidth + nameWidth + durationWidth + 3;

    final topBorder = '┌${'─' * indexWidth}┬${'─' * nameWidth}┬${'─' * durationWidth}┐';
    final headerSeparator = '├${'─' * indexWidth}┼${'─' * nameWidth}┼${'─' * durationWidth}┤';
    final bottomBorder = '└${'─' * indexWidth}┴${'─' * nameWidth}┴${'─' * durationWidth}┘';

    // Header
    buffer.writeln(AnsiColors.colorizeWithStyle(
      topBorder, AnsiColors.blue, AnsiColors.bold));

    // Table title
    final titlePadding = ((totalTableWidth - name.length - 4) / 2).floor(); // 4 for "🚀 "
    final remainingPadding = totalTableWidth - name.length - titlePadding - 4;
    
    buffer.writeln(AnsiColors.colorizeWithStyle(
      '│${' ' * titlePadding}🚀 $name${' ' * remainingPadding}│',
      AnsiColors.magenta, AnsiColors.bold));

    // Caller info if available
    if (_callerInfo != null) {
      final callerInfo = '📍 File: $_callerInfo';
      final callerPadding = ((totalTableWidth - callerInfo.length - 2) / 2).floor();
      final remainingCallerPadding = totalTableWidth - callerInfo.length - callerPadding - 2;
      
      buffer.writeln(AnsiColors.colorize(
        '│${' ' * callerPadding}$callerInfo${' ' * remainingCallerPadding}│',
        AnsiColors.brightBlack));
    }

    buffer.writeln(AnsiColors.colorizeWithStyle(
      headerSeparator, AnsiColors.blue, AnsiColors.bold));

    // Column headers
    buffer.write('│');
    buffer.write(AnsiColors.colorizeWithStyle(' No '.padRight(indexWidth), AnsiColors.magenta, AnsiColors.bold));
    buffer.write('│');
    buffer.write(AnsiColors.colorizeWithStyle(' Span Name'.padRight(nameWidth), AnsiColors.magenta, AnsiColors.bold));
    buffer.write('│');
    buffer.writeln(AnsiColors.colorizeWithStyle(' Duration', AnsiColors.magenta, AnsiColors.bold));

    buffer.writeln(AnsiColors.colorize(headerSeparator, AnsiColors.cyan));

    // Summary row
    buffer.write('│');
    buffer.write(AnsiColors.colorizeWithStyle(''.padRight(indexWidth), AnsiColors.green, AnsiColors.bold));
    buffer.write('│');
    buffer.write(AnsiColors.colorizeWithStyle(' 📊 TOTAL EXECUTION TIME'.padRight(nameWidth), AnsiColors.green, AnsiColors.bold));
    buffer.write('│ ');
    
    final totalColor = ColorRules.getSpanColor(totalDuration);
    buffer.writeln(AnsiColors.colorize(DurationFormatter.format(totalDuration), totalColor));

    buffer.writeln(AnsiColors.colorize(headerSeparator, AnsiColors.cyan));

    // Data rows
    for (int i = 0; i < _measurements.length - 1; i++) {
      final m = _measurements[i];
      final spanColor = ColorRules.getSpanColor(m.duration);
      
      buffer.write('│');
      buffer.write(' ${(i + 1).toString().padLeft(indexWidth - 2)} ');
      buffer.write('│ ');
      
      var spanName = m.statement;
      if (spanName.length > nameWidth - 2) {
        spanName = '${spanName.substring(0, nameWidth - 5)}...';
      }
      buffer.write(AnsiColors.colorize(spanName.padRight(nameWidth - 1), spanColor));
      buffer.write('│ ');
      buffer.writeln(AnsiColors.colorize(DurationFormatter.format(m.duration), spanColor));
    }

    buffer.writeln(AnsiColors.colorizeWithStyle(
      bottomBorder, AnsiColors.blue, AnsiColors.bold));

    // Summary statistics
    buffer.writeln();
    buffer.write(AnsiColors.colorize('📈 Spans: ${_measurements.length - 1} | ', AnsiColors.brightBlack));
    
    // Find slowest span
    final slowest = _measurements.take(_measurements.length - 1).fold<Measurement>(
      _measurements.first,
      (prev, curr) => curr.duration > prev.duration ? curr : prev,
    );
    buffer.write(AnsiColors.colorize('🐌 Slowest: ${slowest.statement} (${DurationFormatter.format(slowest.duration)})', AnsiColors.brightBlack));
    buffer.writeln();

    return buffer.toString();
  }

  /// Generate JSON output
  String _generateJsonOutput() {
    final buffer = StringBuffer();
    final totalDuration = this.totalDuration;

    buffer.writeln(AnsiColors.colorizeWithStyle(
      '📄 JSON Output:', AnsiColors.magenta, AnsiColors.bold));

    final data = {
      'tracer_name': name,
      'total_duration': DurationFormatter.format(totalDuration),
      'total_microseconds': totalDuration.inMicroseconds,
      'spans': <Map<String, dynamic>>[],
    };

    // Add caller info if available
    if (_callerInfo != null) {
      data['caller_info'] = {
        'file': _callerInfo,
      };
    }

    for (final m in _measurements.take(_measurements.length - 1)) {
      String colorClass;
      if (m.duration > Duration(seconds: 1)) {
        colorClass = 'slow';
      } else if (m.duration > Duration(milliseconds: 100)) {
        colorClass = 'medium';
      } else if (m.duration > Duration(milliseconds: 10)) {
        colorClass = 'fast';
      } else {
        colorClass = 'very_fast';
      }

      final span = {
        'name': m.statement,
        'duration': DurationFormatter.format(m.duration),
        'microseconds': m.duration.inMicroseconds,
        'percent': m.duration.inMicroseconds / totalDuration.inMicroseconds * 100,
        'color_class': colorClass,
      };
      (data['spans'] as List<Map<String, dynamic>>).add(span);
    }

    const encoder = JsonEncoder.withIndent('  ');
    buffer.writeln(encoder.convert(data));

    return buffer.toString();
  }

  // Runtime control methods
  
  /// Enable or disable tracing
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Enable or disable silent mode
  void setSilent(bool silent) {
    _silent = silent;
  }

  /// Change output style at runtime
  void setOutputStyle(OutputStyle style) {
    _outputStyle = style;
  }

  /// Set custom print condition
  void setPrintCondition(bool Function(QuickTracer) condition) {
    _printCondition = condition;
  }

  // Getters
  
  /// Check if tracing is enabled
  bool get isEnabled => _enabled;

  /// Check if silent mode is enabled
  bool get isSilent => _silent;

  /// Get current output style
  OutputStyle get outputStyle => _outputStyle;

  /// Get total duration since tracer creation
  Duration get totalDuration => DateTime.now().difference(_totalTime);

  /// Get copy of all measurements
  List<Measurement> get measurements => List.unmodifiable(_measurements);
}
