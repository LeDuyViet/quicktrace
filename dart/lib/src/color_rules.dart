/// ANSI color codes for cross-platform terminal output
class AnsiColors {
  // Reset
  static const String reset = '\x1B[0m';

  // Regular colors
  static const String black = '\x1B[30m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';

  // Bright colors
  static const String brightBlack = '\x1B[90m';
  static const String brightRed = '\x1B[91m';
  static const String brightGreen = '\x1B[92m';
  static const String brightYellow = '\x1B[93m';
  static const String brightBlue = '\x1B[94m';
  static const String brightMagenta = '\x1B[95m';
  static const String brightCyan = '\x1B[96m';
  static const String brightWhite = '\x1B[97m';

  // Styles
  static const String bold = '\x1B[1m';
  static const String dim = '\x1B[2m';
  static const String italic = '\x1B[3m';
  static const String underline = '\x1B[4m';

  /// Apply color to text
  static String colorize(String text, String colorCode) {
    return '$colorCode$text$reset';
  }

  /// Apply color with style to text
  static String colorizeWithStyle(String text, String colorCode, String styleCode) {
    return '$styleCode$colorCode$text$reset';
  }
}

/// Color rule for duration-based coloring
class ColorRule {
  final Duration threshold;
  final String color;
  final String name;

  const ColorRule({
    required this.threshold,
    required this.color,
    required this.name,
  });
}

/// Color rule for percentage-based coloring
class PercentageColorRule {
  final double threshold;
  final String color;
  final String name;

  const PercentageColorRule({
    required this.threshold,
    required this.color,
    required this.name,
  });
}

/// Cross-platform safe color rules for different time ranges
class ColorRules {
  static final List<ColorRule> durationColorRules = [
    ColorRule(
      threshold: Duration(seconds: 3),
      color: AnsiColors.red + AnsiColors.bold,
      name: 'Very Slow',
    ),
    ColorRule(
      threshold: Duration(seconds: 1),
      color: AnsiColors.red,
      name: 'Slow',
    ),
    ColorRule(
      threshold: Duration(milliseconds: 500),
      color: AnsiColors.yellow,
      name: 'Medium-Slow',
    ),
    ColorRule(
      threshold: Duration(milliseconds: 200),
      color: AnsiColors.brightBlue,
      name: 'Medium',
    ),
    ColorRule(
      threshold: Duration(milliseconds: 100),
      color: AnsiColors.cyan,
      name: 'Normal',
    ),
    ColorRule(
      threshold: Duration(milliseconds: 50),
      color: AnsiColors.green,
      name: 'Fast',
    ),
    ColorRule(
      threshold: Duration(milliseconds: 10),
      color: AnsiColors.brightGreen,
      name: 'Very Fast',
    ),
    ColorRule(
      threshold: Duration.zero,
      color: AnsiColors.brightBlack,
      name: 'Ultra Fast',
    ),
  ];

  static final List<PercentageColorRule> progressColorRules = [
    PercentageColorRule(
      threshold: 75,
      color: AnsiColors.red + AnsiColors.bold,
      name: 'Critical',
    ),
    PercentageColorRule(
      threshold: 50,
      color: AnsiColors.red,
      name: 'High',
    ),
    PercentageColorRule(
      threshold: 25,
      color: AnsiColors.magenta,
      name: 'Medium',
    ),
    PercentageColorRule(
      threshold: 10,
      color: AnsiColors.blue,
      name: 'Low',
    ),
    PercentageColorRule(
      threshold: 5,
      color: AnsiColors.green,
      name: 'Very Low',
    ),
    PercentageColorRule(
      threshold: 0,
      color: AnsiColors.cyan,
      name: 'Minimal',
    ),
  ];

  /// Get color for duration
  static String getSpanColor(Duration duration) {
    for (final rule in durationColorRules) {
      if (duration >= rule.threshold) {
        return rule.color;
      }
    }
    return AnsiColors.white;
  }

  /// Get color for percentage
  static String getProgressBarColor(double percentage) {
    for (final rule in progressColorRules) {
      if (percentage >= rule.threshold) {
        return rule.color;
      }
    }
    return AnsiColors.white;
  }

  /// Get color name for duration
  static String getDurationColorName(Duration duration) {
    for (final rule in durationColorRules) {
      if (duration >= rule.threshold) {
        return rule.name;
      }
    }
    return 'Unknown';
  }

  /// Get color name for percentage
  static String getProgressColorName(double percentage) {
    for (final rule in progressColorRules) {
      if (percentage >= rule.threshold) {
        return rule.name;
      }
    }
    return 'Unknown';
  }

  /// Format duration with color
  static String formatDurationWithColor(Duration duration) {
    final color = getSpanColor(duration);
    return AnsiColors.colorize(duration.toString(), color);
  }
}
