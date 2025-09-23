import Foundation

/// Options for configuring the tracer behavior
public enum TracerOption {
    /// Only show operations slower than the specified threshold
    case showSlowOnly(TimeInterval)
    
    /// Hide operations faster than the specified threshold
    case hideUltraFast(TimeInterval)
    
    /// Group operations with similar durations (within threshold)
    case groupSimilar(TimeInterval)
    
    /// Only print if total duration is at least the specified threshold
    case minTotalDuration(TimeInterval)
    
    /// Only print if any span duration is at least the specified threshold
    case minSpanDuration(TimeInterval)
    
    /// Enable or disable tracing completely
    case enabled(Bool)
    
    /// Enable or disable console output (still collects data)
    case silent(Bool)
    
    /// Set the output style
    case style(OutputStyle)
    
    /// Custom print condition
    case customCondition((QuickTrace) -> Bool)
}

/// Smart filter configuration combining multiple filtering options
public struct SmartFilter {
    /// Threshold for slow operations (show slow only)
    public let slowThreshold: TimeInterval?
    
    /// Threshold for ultra fast operations (hide ultra fast)
    public let ultraFastThreshold: TimeInterval?
    
    /// Threshold for grouping similar operations
    public let similarThreshold: TimeInterval?
    
    /// Creates a smart filter with the specified thresholds
    /// - Parameters:
    ///   - slowThreshold: Only show operations slower than this threshold
    ///   - ultraFastThreshold: Hide operations faster than this threshold
    ///   - similarThreshold: Group operations with durations within this threshold
    public init(slowThreshold: TimeInterval? = nil, 
                ultraFastThreshold: TimeInterval? = nil, 
                similarThreshold: TimeInterval? = nil) {
        self.slowThreshold = slowThreshold
        self.ultraFastThreshold = ultraFastThreshold
        self.similarThreshold = similarThreshold
    }
}

/// Caller information for debugging
public struct CallerInfo {
    /// The file where the tracer was created
    public let file: String
    
    /// The line number where the tracer was created
    public let line: Int
    
    /// The function where the tracer was created
    public let function: String
    
    /// Creates caller info
    public init(file: String = #file, line: Int = #line, function: String = #function) {
        self.file = file
        self.line = line
        self.function = function
    }
    
    /// Returns a short description with just filename and line
    public var shortDescription: String {
        let filename = (file as NSString).lastPathComponent
        return "\(filename):\(line)"
    }
    
    /// Returns a full description including function name
    public var fullDescription: String {
        let filename = (file as NSString).lastPathComponent
        return "\(filename):\(line) in \(function)"
    }
}

