/// Available output styles for tracing
enum OutputStyle {
  /// Simple table format
  styleDefault,
  
  /// Modern with Unicode borders
  styleColorful,
  
  /// Compact tree view
  styleMinimal,
  
  /// Full analysis with statistics
  styleDetailed,
  
  /// Clean table format
  styleTable,
  
  /// Structured JSON output
  styleJson,
}

/// Extension to provide display names for output styles
extension OutputStyleExtension on OutputStyle {
  String get displayName {
    switch (this) {
      case OutputStyle.styleDefault:
        return 'Default';
      case OutputStyle.styleColorful:
        return 'Colorful';
      case OutputStyle.styleMinimal:
        return 'Minimal';
      case OutputStyle.styleDetailed:
        return 'Detailed';
      case OutputStyle.styleTable:
        return 'Table';
      case OutputStyle.styleJson:
        return 'JSON';
    }
  }
}
