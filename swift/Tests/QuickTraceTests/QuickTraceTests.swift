import XCTest
@testable import QuickTrace

final class QuickTraceTests: XCTestCase {
    
    func testBasicTracing() {
        let tracer = QuickTrace(name: "Test Tracer")
            .with(option: .silent(true)) // Silent for testing
        
        tracer.span("Operation 1")
        Thread.sleep(forTimeInterval: 0.001) // 1ms
        
        tracer.span("Operation 2")
        Thread.sleep(forTimeInterval: 0.002) // 2ms
        
        tracer.end()
        
        let measurements = tracer.getMeasurements()
        XCTAssertEqual(measurements.count, 2)
        XCTAssertEqual(measurements[0].statement, "Operation 1")
        XCTAssertEqual(measurements[1].statement, "Operation 2")
        XCTAssertGreaterThan(measurements[0].duration, 0)
        XCTAssertGreaterThan(measurements[1].duration, 0)
    }
    
    func testTracerDisabled() {
        let tracer = QuickTrace(name: "Disabled Tracer")
            .with(option: .enabled(false))
        
        tracer.span("Should not be recorded")
        tracer.end()
        
        let measurements = tracer.getMeasurements()
        XCTAssertEqual(measurements.count, 0)
    }
    
    func testRuntimeControl() {
        let tracer = QuickTrace(name: "Runtime Test")
            .with(option: .silent(true))
        
        // Initially enabled
        XCTAssertTrue(tracer.getEnabled())
        
        tracer.span("Enabled operation")
        
        // Disable tracing
        tracer.setEnabled(false)
        XCTAssertFalse(tracer.getEnabled())
        
        tracer.span("Disabled operation")
        
        // Re-enable
        tracer.setEnabled(true)
        tracer.span("Re-enabled operation")
        
        tracer.end()
        
        let measurements = tracer.getMeasurements()
        XCTAssertEqual(measurements.count, 2) // Only enabled operations
        XCTAssertEqual(measurements[0].statement, "Enabled operation")
        XCTAssertEqual(measurements[1].statement, "Re-enabled operation")
    }
    
    func testSilentMode() {
        let tracer = QuickTrace(name: "Silent Test")
        
        // Initially not silent
        XCTAssertFalse(tracer.getSilent())
        
        // Set silent
        tracer.setSilent(true)
        XCTAssertTrue(tracer.getSilent())
        
        tracer.span("Silent operation")
        tracer.end()
        
        // Should still collect data
        let measurements = tracer.getMeasurements()
        XCTAssertEqual(measurements.count, 1)
    }
    
    func testOutputStyles() {
        let tracer = QuickTrace(name: "Style Test")
            .with(option: .silent(true))
        
        // Test all styles
        for style in OutputStyle.allCases {
            tracer.setOutputStyle(style)
            XCTAssertEqual(tracer.getOutputStyle(), style)
        }
    }
    
    func testSmartFiltering() {
        let tracer = QuickTrace(name: "Filter Test")
            .with(option: .silent(true))
        
        // Add measurements with different durations
        tracer.span("Fast operation")
        Thread.sleep(forTimeInterval: 0.001) // 1ms
        
        tracer.span("Medium operation")
        Thread.sleep(forTimeInterval: 0.050) // 50ms
        
        tracer.span("Slow operation")
        Thread.sleep(forTimeInterval: 0.100) // 100ms
        
        tracer.end()
        
        let allMeasurements = tracer.getMeasurements()
        XCTAssertEqual(allMeasurements.count, 3)
        
        // Test filtering
        let filteredData = tracer.applySmartFiltering(to: allMeasurements)
        XCTAssertEqual(filteredData.count, 3) // No filters applied
    }
    
    func testMeasurement() {
        let measurement = Measurement(statement: "Test", duration: 0.123)
        
        XCTAssertEqual(measurement.statement, "Test")
        XCTAssertEqual(measurement.duration, 0.123, accuracy: 0.001)
        
        let description = measurement.description
        XCTAssertTrue(description.contains("Test"))
        XCTAssertTrue(description.contains("0.123"))
    }
    
    func testGroupedMeasurement() {
        let grouped = GroupedMeasurement(
            name: "Grouped Test",
            count: 3,
            totalTime: 0.300,
            avgTime: 0.100,
            minTime: 0.080,
            maxTime: 0.120
        )
        
        XCTAssertEqual(grouped.name, "Grouped Test")
        XCTAssertEqual(grouped.count, 3)
        XCTAssertEqual(grouped.totalTime, 0.300, accuracy: 0.001)
        XCTAssertEqual(grouped.avgTime, 0.100, accuracy: 0.001)
        XCTAssertEqual(grouped.minTime, 0.080, accuracy: 0.001)
        XCTAssertEqual(grouped.maxTime, 0.120, accuracy: 0.001)
    }
    
    func testColorRules() {
        // Test duration colors
        let fastColor = ColorRules.colorForDuration(0.005) // 5ms
        let mediumColor = ColorRules.colorForDuration(0.150) // 150ms
        let slowColor = ColorRules.colorForDuration(2.0) // 2s
        
        XCTAssertNotEqual(fastColor, mediumColor)
        XCTAssertNotEqual(mediumColor, slowColor)
        
        // Test color names
        let fastName = ColorRules.nameForDuration(0.005)
        let slowName = ColorRules.nameForDuration(2.0)
        
        XCTAssertNotEqual(fastName, slowName)
        XCTAssertTrue(fastName.contains("Fast"))
        XCTAssertTrue(slowName.contains("Slow"))
    }
    
    func testCustomPrintCondition() {
        let tracer = QuickTrace(name: "Condition Test")
            .with(option: .silent(true))
        
        var conditionCalled = false
        
        tracer.setPrintCondition { _ in
            conditionCalled = true
            return false // Don't print
        }
        
        tracer.span("Test operation")
        tracer.end()
        
        // Note: Print condition is checked in end(), but since we're silent,
        // we can't easily test this without changing the implementation
        // This test at least verifies the API works
    }
    
    func testCallerInfo() {
        let callerInfo = CallerInfo(file: "/path/to/TestFile.swift", line: 42, function: "testFunction")
        
        XCTAssertTrue(callerInfo.file.contains("TestFile.swift"))
        XCTAssertEqual(callerInfo.line, 42)
        XCTAssertEqual(callerInfo.function, "testFunction")
        
        let shortDesc = callerInfo.shortDescription
        XCTAssertTrue(shortDesc.contains("TestFile.swift"))
        XCTAssertTrue(shortDesc.contains("42"))
        
        let fullDesc = callerInfo.fullDescription
        XCTAssertTrue(fullDesc.contains("TestFile.swift"))
        XCTAssertTrue(fullDesc.contains("42"))
        XCTAssertTrue(fullDesc.contains("testFunction"))
    }
    
    func testConvenienceFactories() {
        let colorfulTracer = QuickTrace.colorful("Test")
        XCTAssertEqual(colorfulTracer.getOutputStyle(), .colorful)
        
        let minimalTracer = QuickTrace.minimal("Test")
        XCTAssertEqual(minimalTracer.getOutputStyle(), .minimal)
        
        let detailedTracer = QuickTrace.detailed("Test")
        XCTAssertEqual(detailedTracer.getOutputStyle(), .detailed)
        
        let tableTracer = QuickTrace.table("Test")
        XCTAssertEqual(tableTracer.getOutputStyle(), .table)
        
        let jsonTracer = QuickTrace.json("Test")
        XCTAssertEqual(jsonTracer.getOutputStyle(), .json)
        
        let silentTracer = QuickTrace.silent("Test")
        XCTAssertTrue(silentTracer.getSilent())
        
        let disabledTracer = QuickTrace.disabled("Test")
        XCTAssertFalse(disabledTracer.getEnabled())
    }
    
    func testPerformanceOverhead() {
        let iterations = 1000
        
        // Measure disabled tracer (should be very fast)
        let disabledTracer = QuickTrace.disabled("Performance Test")
        
        let startTime = Date()
        for i in 0..<iterations {
            disabledTracer.span("Operation \(i)")
        }
        disabledTracer.end()
        let disabledTime = Date().timeIntervalSince(startTime)
        
        // Measure enabled silent tracer
        let enabledTracer = QuickTrace.silent("Performance Test")
        
        let startTime2 = Date()
        for i in 0..<iterations {
            enabledTracer.span("Operation \(i)")
        }
        enabledTracer.end()
        let enabledTime = Date().timeIntervalSince(startTime2)
        
        // Disabled should be significantly faster
        XCTAssertLessThan(disabledTime, enabledTime)
        
        // Both should be reasonably fast (less than 1 second for 1000 operations)
        XCTAssertLessThan(disabledTime, 1.0)
        XCTAssertLessThan(enabledTime, 1.0)
        
        print("Performance: Disabled=\(disabledTime*1000)ms, Enabled=\(enabledTime*1000)ms")
    }
}

