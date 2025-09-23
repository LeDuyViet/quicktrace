import Foundation

/// A lightweight, colorful tracing library for Swift
public class QuickTrace {
    // MARK: - Properties
    
    /// The name of this tracer
    public let name: String
    
    /// All measurements collected by this tracer
    private var measurements: [Measurement] = []
    
    /// The time when the last measurement was taken
    private var lastTime: Date
    
    /// The time when the tracer was created
    private var totalTime: Date
    
    /// Whether tracing is enabled
    private var isEnabled: Bool = true
    
    /// Whether output should be suppressed (still collects data)
    private var isSilent: Bool = false
    
    /// The output style to use
    private var outputStyle: OutputStyle = .default
    
    /// Custom condition for printing
    private var printCondition: ((QuickTrace) -> Bool)?
    
    /// Caller information for debugging
    private var callerInfo: CallerInfo?
    
    // Smart filtering options
    private var showSlowOnly: Bool = false
    private var slowThreshold: TimeInterval = 0
    private var hideUltraFast: Bool = false
    private var ultraFastThreshold: TimeInterval = 0
    private var groupSimilar: Bool = false
    private var similarThreshold: TimeInterval = 0
    
    /// Default minimum duration to display traces (100ms)
    public static let defaultMinDuration: TimeInterval = 0.1
    
    // MARK: - Initialization
    
    /// Creates a new QuickTrace instance
    /// - Parameters:
    ///   - name: The name of this tracer
    ///   - options: Configuration options
    ///   - callerInfo: Caller information (automatically captured)
    public init(name: String, 
                options: [TracerOption] = [],
                callerInfo: CallerInfo = CallerInfo()) {
        self.name = name
        self.lastTime = Date()
        self.totalTime = Date()
        self.callerInfo = callerInfo
        
        // Set default print condition
        self.printCondition = { tracer in
            return tracer.getTotalDuration() >= QuickTrace.defaultMinDuration
        }
        
        // Apply options
        for option in options {
            apply(option: option)
        }
    }
    
    // MARK: - Builder Pattern
    
    /// Applies an option and returns self for chaining
    /// - Parameter option: The option to apply
    /// - Returns: Self for method chaining
    @discardableResult
    public func with(option: TracerOption) -> QuickTrace {
        apply(option: option)
        return self
    }
    
    /// Sets the output style and returns self for chaining
    /// - Parameter style: The output style to use
    /// - Returns: Self for method chaining
    @discardableResult
    public func with(style: OutputStyle) -> QuickTrace {
        self.outputStyle = style
        return self
    }
    
    /// Applies smart filtering and returns self for chaining
    /// - Parameter filter: The smart filter configuration
    /// - Returns: Self for method chaining
    @discardableResult
    public func with(smartFilter filter: SmartFilter) -> QuickTrace {
        if let slowThreshold = filter.slowThreshold {
            apply(option: .showSlowOnly(slowThreshold))
        }
        if let ultraFastThreshold = filter.ultraFastThreshold {
            apply(option: .hideUltraFast(ultraFastThreshold))
        }
        if let similarThreshold = filter.similarThreshold {
            apply(option: .groupSimilar(similarThreshold))
        }
        return self
    }
    
    // MARK: - Core Functionality
    
    /// Records a span (operation) in the trace
    /// - Parameter statement: Description of the operation
    public func span(_ statement: String) {
        guard isEnabled else { return }
        
        let now = Date()
        let duration = now.timeIntervalSince(lastTime)
        
        measurements.append(Measurement(statement: statement, duration: duration))
        lastTime = now
    }
    
    /// Ends the trace and outputs the results
    public func end() {
        guard isEnabled else { return }
        
        span("End")
        
        guard !isSilent else { return }
        
        // Check print condition
        if let condition = printCondition, !condition(self) {
            return
        }
        
        // Generate and print output
        let output = generateOutput()
        print(output, terminator: "")
    }
    
    // MARK: - Runtime Control
    
    /// Enables or disables tracing
    /// - Parameter enabled: Whether to enable tracing
    public func setEnabled(_ enabled: Bool) {
        self.isEnabled = enabled
    }
    
    /// Enables or disables console output
    /// - Parameter silent: Whether to suppress output
    public func setSilent(_ silent: Bool) {
        self.isSilent = silent
    }
    
    /// Sets the output style
    /// - Parameter style: The output style to use
    public func setOutputStyle(_ style: OutputStyle) {
        self.outputStyle = style
    }
    
    /// Sets a custom print condition
    /// - Parameter condition: The condition to evaluate before printing
    public func setPrintCondition(_ condition: @escaping (QuickTrace) -> Bool) {
        self.printCondition = condition
    }
    
    // MARK: - Getters
    
    /// Gets the current enabled state
    /// - Returns: Whether tracing is enabled
    public func getEnabled() -> Bool {
        return isEnabled
    }
    
    /// Gets the current silent state
    /// - Returns: Whether output is suppressed
    public func getSilent() -> Bool {
        return isSilent
    }
    
    /// Gets the current output style
    /// - Returns: The current output style
    public func getOutputStyle() -> OutputStyle {
        return outputStyle
    }
    
    /// Gets the total duration of all operations
    /// - Returns: Total duration in seconds
    public func getTotalDuration() -> TimeInterval {
        return Date().timeIntervalSince(totalTime)
    }
    
    /// Gets all measurements (excluding the "End" measurement)
    /// - Returns: Array of measurements
    public func getMeasurements() -> [Measurement] {
        let endMeasurements = measurements.filter { $0.statement != "End" }
        return endMeasurements
    }
    
    /// Gets all measurements including the "End" measurement
    /// - Returns: Array of all measurements
    public func getAllMeasurements() -> [Measurement] {
        return measurements
    }
    
    // MARK: - Private Methods
    
    private func apply(option: TracerOption) {
        switch option {
        case .showSlowOnly(let threshold):
            showSlowOnly = true
            slowThreshold = threshold
        case .hideUltraFast(let threshold):
            hideUltraFast = true
            ultraFastThreshold = threshold
        case .groupSimilar(let threshold):
            groupSimilar = true
            similarThreshold = threshold
        case .minTotalDuration(let minDuration):
            printCondition = { tracer in
                return tracer.getTotalDuration() >= minDuration
            }
        case .minSpanDuration(let minDuration):
            printCondition = { tracer in
                return tracer.getMeasurements().contains { $0.duration >= minDuration }
            }
        case .enabled(let enabled):
            isEnabled = enabled
        case .silent(let silent):
            isSilent = silent
        case .style(let style):
            outputStyle = style
        case .customCondition(let condition):
            printCondition = condition
        }
    }
    
    private func generateOutput() -> String {
        switch outputStyle {
        case .default:
            return generateDefaultOutput()
        case .colorful:
            return generateColorfulOutput()
        case .minimal:
            return generateMinimalOutput()
        case .detailed:
            return generateDetailedOutput()
        case .table:
            return generateTableOutput()
        case .json:
            return generateJSONOutput()
        }
    }
}

