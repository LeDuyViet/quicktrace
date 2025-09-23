/// Duration formatting utilities to match Go's format
class DurationFormatter {
  /// Format duration in Go-style (e.g., "25.5ms", "120.3ms", "0s")
  static String format(Duration duration) {
    if (duration == Duration.zero) {
      return '0s';
    }
    
    final microseconds = duration.inMicroseconds;
    
    if (microseconds < 1000) {
      // Less than 1ms - show as microseconds
      return '${microseconds}µs';
    } else if (microseconds < 1000000) {
      // Less than 1s - show as milliseconds with decimals
      final ms = microseconds / 1000;
      if (ms < 10) {
        return '${ms.toStringAsFixed(4)}ms';
      } else if (ms < 100) {
        return '${ms.toStringAsFixed(3)}ms';
      } else {
        return '${ms.toStringAsFixed(2)}ms';
      }
    } else if (microseconds < 60000000) {
      // Less than 1 minute - show as seconds with decimals
      final seconds = microseconds / 1000000;
      if (seconds < 10) {
        return '${seconds.toStringAsFixed(3)}s';
      } else {
        return '${seconds.toStringAsFixed(2)}s';
      }
    } else {
      // 1 minute or more - show as minutes and seconds
      final minutes = duration.inMinutes;
      final remainingSeconds = duration.inSeconds % 60;
      final remainingMs = (duration.inMilliseconds % 1000);
      
      if (remainingMs > 0) {
        return '${minutes}m${remainingSeconds}.${remainingMs.toString().padLeft(3, '0')}s';
      } else if (remainingSeconds > 0) {
        return '${minutes}m${remainingSeconds}s';
      } else {
        return '${minutes}m';
      }
    }
  }
  
  /// Format duration for detailed output (consistent with Go's style)
  static String formatDetailed(Duration duration) {
    return format(duration);
  }
  
  /// Format duration for minimal output (shorter if possible)
  static String formatMinimal(Duration duration) {
    if (duration == Duration.zero) {
      return '0s';
    }
    
    final microseconds = duration.inMicroseconds;
    
    if (microseconds < 1000) {
      return '${microseconds}µs';
    } else if (microseconds < 1000000) {
      final ms = microseconds / 1000;
      return '${ms.toStringAsFixed(1)}ms';
    } else {
      final seconds = microseconds / 1000000;
      return '${seconds.toStringAsFixed(1)}s';
    }
  }
}
