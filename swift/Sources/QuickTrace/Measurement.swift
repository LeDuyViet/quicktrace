import Foundation

/// Represents a single measurement in the trace
public struct Measurement {
    /// The name/description of the operation
    public let statement: String
    
    /// The duration of the operation
    public let duration: TimeInterval
    
    /// Creates a new measurement
    /// - Parameters:
    ///   - statement: The name/description of the operation
    ///   - duration: The duration of the operation in seconds
    public init(statement: String, duration: TimeInterval) {
        self.statement = statement
        self.duration = duration
    }
}

extension Measurement: Equatable {
    public static func == (lhs: Measurement, rhs: Measurement) -> Bool {
        return lhs.statement == rhs.statement && abs(lhs.duration - rhs.duration) < 0.000001
    }
}

extension Measurement: CustomStringConvertible {
    public var description: String {
        return "\(statement): \(String(format: "%.3f", duration))s"
    }
}

/// Represents a group of similar measurements
public struct GroupedMeasurement {
    /// The name of the group
    public let name: String
    
    /// Number of measurements in this group
    public let count: Int
    
    /// Total time of all measurements
    public let totalTime: TimeInterval
    
    /// Average time of measurements in this group
    public let avgTime: TimeInterval
    
    /// Minimum time in this group
    public let minTime: TimeInterval
    
    /// Maximum time in this group
    public let maxTime: TimeInterval
    
    /// Creates a new grouped measurement
    public init(name: String, count: Int, totalTime: TimeInterval, avgTime: TimeInterval, minTime: TimeInterval, maxTime: TimeInterval) {
        self.name = name
        self.count = count
        self.totalTime = totalTime
        self.avgTime = avgTime
        self.minTime = minTime
        self.maxTime = maxTime
    }
}

extension GroupedMeasurement: CustomStringConvertible {
    public var description: String {
        return "\(name) (×\(count)): avg \(String(format: "%.3f", avgTime))s, range \(String(format: "%.3f", minTime))s-\(String(format: "%.3f", maxTime))s"
    }
}

