import Foundation

/// ANSI color codes for cross-platform terminal output
public enum ANSIColor: String, CaseIterable {
    // Reset
    case reset = "\u{001B}[0m"
    
    // Regular colors
    case black = "\u{001B}[30m"
    case red = "\u{001B}[31m"
    case green = "\u{001B}[32m"
    case yellow = "\u{001B}[33m"
    case blue = "\u{001B}[34m"
    case magenta = "\u{001B}[35m"
    case cyan = "\u{001B}[36m"
    case white = "\u{001B}[37m"
    
    // Bright colors
    case brightBlack = "\u{001B}[90m"
    case brightRed = "\u{001B}[91m"
    case brightGreen = "\u{001B}[92m"
    case brightYellow = "\u{001B}[93m"
    case brightBlue = "\u{001B}[94m"
    case brightMagenta = "\u{001B}[95m"
    case brightCyan = "\u{001B}[96m"
    case brightWhite = "\u{001B}[97m"
    
    // Styles
    case bold = "\u{001B}[1m"
    case dim = "\u{001B}[2m"
    case italic = "\u{001B}[3m"
    case underline = "\u{001B}[4m"
    
    /// Applies this color to the given text
    /// - Parameter text: The text to colorize
    /// - Returns: The colorized text
    public func applied(to text: String) -> String {
        return rawValue + text + ANSIColor.reset.rawValue
    }
    
    /// Applies this color with a style to the given text
    /// - Parameters:
    ///   - text: The text to colorize
    ///   - style: The style to apply
    /// - Returns: The colorized and styled text
    public func applied(to text: String, withStyle style: ANSIColor) -> String {
        return style.rawValue + rawValue + text + ANSIColor.reset.rawValue
    }
}

/// Color rule for duration-based coloring
public struct ColorRule {
    /// Minimum threshold for this color rule
    public let threshold: TimeInterval
    
    /// Color to apply for durations >= threshold
    public let color: ANSIColor
    
    /// Descriptive name for this color category
    public let name: String
    
    /// Creates a new color rule
    public init(threshold: TimeInterval, color: ANSIColor, name: String) {
        self.threshold = threshold
        self.color = color
        self.name = name
    }
}

/// Color rule for percentage-based coloring (progress bars)
public struct PercentageColorRule {
    /// Minimum threshold percentage for this color rule
    public let threshold: Double
    
    /// Color to apply for percentages >= threshold
    public let color: ANSIColor
    
    /// Descriptive name for this color category
    public let name: String
    
    /// Creates a new percentage color rule
    public init(threshold: Double, color: ANSIColor, name: String) {
        self.threshold = threshold
        self.color = color
        self.name = name
    }
}

/// Predefined color rules for cross-platform compatibility
public struct ColorRules {
    /// Duration-based color rules optimized for cross-platform compatibility
    public static let durationRules: [ColorRule] = [
        ColorRule(threshold: 3.0, color: .red, name: "Very Slow"),        // > 3s
        ColorRule(threshold: 1.0, color: .red, name: "Slow"),             // 1s-3s
        ColorRule(threshold: 0.5, color: .yellow, name: "Medium-Slow"),   // 500ms-1s
        ColorRule(threshold: 0.2, color: .brightBlue, name: "Medium"),    // 200ms-500ms
        ColorRule(threshold: 0.1, color: .cyan, name: "Normal"),          // 100ms-200ms
        ColorRule(threshold: 0.05, color: .green, name: "Fast"),          // 50ms-100ms
        ColorRule(threshold: 0.01, color: .brightGreen, name: "Very Fast"), // 10ms-50ms
        ColorRule(threshold: 0.0, color: .brightBlack, name: "Ultra Fast") // < 10ms
    ]
    
    /// Progress bar color rules for percentages
    public static let progressRules: [PercentageColorRule] = [
        PercentageColorRule(threshold: 75.0, color: .red, name: "Critical"),    // > 75%
        PercentageColorRule(threshold: 50.0, color: .red, name: "High"),        // 50-75%
        PercentageColorRule(threshold: 25.0, color: .magenta, name: "Medium"),  // 25-50%
        PercentageColorRule(threshold: 10.0, color: .blue, name: "Low"),        // 10-25%
        PercentageColorRule(threshold: 5.0, color: .green, name: "Very Low"),   // 5-10%
        PercentageColorRule(threshold: 0.0, color: .cyan, name: "Minimal")      // < 5%
    ]
    
    /// Gets the appropriate color for a duration
    /// - Parameter duration: The duration in seconds
    /// - Returns: The color to use for this duration
    public static func colorForDuration(_ duration: TimeInterval) -> ANSIColor {
        for rule in durationRules {
            if duration >= rule.threshold {
                return rule.color
            }
        }
        return .white
    }
    
    /// Gets the appropriate color for a percentage
    /// - Parameter percentage: The percentage value
    /// - Returns: The color to use for this percentage
    public static func colorForPercentage(_ percentage: Double) -> ANSIColor {
        for rule in progressRules {
            if percentage >= rule.threshold {
                return rule.color
            }
        }
        return .white
    }
    
    /// Gets the category name for a duration
    /// - Parameter duration: The duration in seconds
    /// - Returns: The descriptive name for this duration category
    public static func nameForDuration(_ duration: TimeInterval) -> String {
        for rule in durationRules {
            if duration >= rule.threshold {
                return rule.name
            }
        }
        return "Unknown"
    }
    
    /// Gets the category name for a percentage
    /// - Parameter percentage: The percentage value
    /// - Returns: The descriptive name for this percentage category
    public static func nameForPercentage(_ percentage: Double) -> String {
        for rule in progressRules {
            if percentage >= rule.threshold {
                return rule.name
            }
        }
        return "Unknown"
    }
}

/// Utility functions for colorizing text
public extension String {
    /// Colorizes this string with the given color
    /// - Parameter color: The color to apply
    /// - Returns: The colorized string
    func colored(with color: ANSIColor) -> String {
        return color.applied(to: self)
    }
    
    /// Colorizes this string with the given color and style
    /// - Parameters:
    ///   - color: The color to apply
    ///   - style: The style to apply
    /// - Returns: The colorized and styled string
    func colored(with color: ANSIColor, style: ANSIColor) -> String {
        return color.applied(to: self, withStyle: style)
    }
}

/// Environment detection for color support
public struct TerminalCapabilities {
    /// Checks if the current environment supports ANSI colors
    public static var supportsColors: Bool {
        // Check environment variables
        guard let term = ProcessInfo.processInfo.environment["TERM"] else {
            return false
        }
        
        // Most terminals support colors
        if term.contains("color") || term.contains("xterm") || term == "screen" {
            return true
        }
        
        // Check for color capabilities
        if let colorterm = ProcessInfo.processInfo.environment["COLORTERM"] {
            return !colorterm.isEmpty
        }
        
        return false
    }
    
    /// Safely applies color if supported, otherwise returns plain text
    /// - Parameters:
    ///   - text: The text to potentially colorize
    ///   - color: The color to apply
    /// - Returns: Colorized text if supported, plain text otherwise
    public static func safeColor(_ text: String, with color: ANSIColor) -> String {
        return supportsColors ? color.applied(to: text) : text
    }
}

