// Export all public types and classes

@_exported import Foundation

// Re-export all main types for easy importing
public typealias Tracer = QuickTrace

// Convenience factory methods
public extension QuickTrace {
    
    /// Creates a new tracer with colorful output style
    /// - Parameter name: The name of the tracer
    /// - Returns: A new QuickTrace instance
    static func colorful(_ name: String) -> QuickTrace {
        return QuickTrace(name: name, options: [.style(.colorful)])
    }
    
    /// Creates a new tracer with minimal output style
    /// - Parameter name: The name of the tracer
    /// - Returns: A new QuickTrace instance
    static func minimal(_ name: String) -> QuickTrace {
        return QuickTrace(name: name, options: [.style(.minimal)])
    }
    
    /// Creates a new tracer with detailed output style
    /// - Parameter name: The name of the tracer
    /// - Returns: A new QuickTrace instance
    static func detailed(_ name: String) -> QuickTrace {
        return QuickTrace(name: name, options: [.style(.detailed)])
    }
    
    /// Creates a new tracer with table output style
    /// - Parameter name: The name of the tracer
    /// - Returns: A new QuickTrace instance
    static func table(_ name: String) -> QuickTrace {
        return QuickTrace(name: name, options: [.style(.table)])
    }
    
    /// Creates a new tracer with JSON output style
    /// - Parameter name: The name of the tracer
    /// - Returns: A new QuickTrace instance
    static func json(_ name: String) -> QuickTrace {
        return QuickTrace(name: name, options: [.style(.json)])
    }
}

// Convenience methods for common configurations
public extension QuickTrace {
    
    /// Creates a silent tracer that collects data but doesn't print
    /// - Parameter name: The name of the tracer
    /// - Returns: A new silent QuickTrace instance
    static func silent(_ name: String) -> QuickTrace {
        return QuickTrace(name: name, options: [.silent(true)])
    }
    
    /// Creates a disabled tracer that doesn't collect any data
    /// - Parameter name: The name of the tracer
    /// - Returns: A new disabled QuickTrace instance
    static func disabled(_ name: String) -> QuickTrace {
        return QuickTrace(name: name, options: [.enabled(false)])
    }
    
    /// Creates a tracer with smart filtering for performance analysis
    /// - Parameters:
    ///   - name: The name of the tracer
    ///   - slowThreshold: Only show operations slower than this (in seconds)
    ///   - hideUltraFast: Hide operations faster than this (in seconds)
    ///   - groupSimilar: Group operations within this threshold (in seconds)
    /// - Returns: A new QuickTrace instance with smart filtering
    static func smartFiltered(_ name: String, 
                             slowThreshold: TimeInterval = 0.05,
                             hideUltraFast: TimeInterval = 0.001,
                             groupSimilar: TimeInterval = 0.01) -> QuickTrace {
        let filter = SmartFilter(
            slowThreshold: slowThreshold,
            ultraFastThreshold: hideUltraFast,
            similarThreshold: groupSimilar
        )
        return QuickTrace(name: name, options: [.style(.detailed)])
            .with(smartFilter: filter)
    }
}

