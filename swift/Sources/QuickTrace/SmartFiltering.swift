import Foundation

// MARK: - Smart Filtering Extension

extension QuickTrace {
    
    /// Applies smart filtering to measurements
    /// - Parameter measurements: The measurements to filter
    /// - Returns: Filtered measurements (can be Measurement or GroupedMeasurement)
    internal func applySmartFiltering(to measurements: [Measurement]) -> [Any] {
        guard !measurements.isEmpty else { return [] }
        
        // Step 1: Filter by slow threshold
        var filtered = measurements
        if showSlowOnly {
            filtered = measurements.filter { $0.duration >= slowThreshold }
        }
        
        // Step 2: Filter out ultra fast
        if hideUltraFast {
            filtered = filtered.filter { $0.duration >= ultraFastThreshold }
        }
        
        // Step 3: Group similar if needed
        var result: [Any] = []
        if groupSimilar && !filtered.isEmpty {
            let groups = groupSimilarMeasurements(filtered)
            result = groups
        } else {
            result = filtered
        }
        
        return result
    }
    
    /// Groups measurements with similar durations
    /// - Parameter measurements: The measurements to group
    /// - Returns: Array of grouped measurements
    internal func groupSimilarMeasurements(_ measurements: [Measurement]) -> [GroupedMeasurement] {
        guard !measurements.isEmpty else { return [] }
        
        var groups: [GroupedMeasurement] = []
        var processed = Set<Int>()
        
        for (i, measurement1) in measurements.enumerated() {
            if processed.contains(i) { continue }
            
            // Create new group
            var group = GroupedMeasurement(
                name: measurement1.statement,
                count: 1,
                totalTime: measurement1.duration,
                avgTime: measurement1.duration,
                minTime: measurement1.duration,
                maxTime: measurement1.duration
            )
            processed.insert(i)
            
            // Find similar measurements
            var similarNames: [String] = []
            for (j, measurement2) in measurements.enumerated() {
                if i != j && !processed.contains(j) {
                    let diff = abs(measurement1.duration - measurement2.duration)
                    
                    if diff <= similarThreshold {
                        // Update group statistics
                        let newCount = group.count + 1
                        let newTotalTime = group.totalTime + measurement2.duration
                        let newAvgTime = newTotalTime / Double(newCount)
                        let newMinTime = min(group.minTime, measurement2.duration)
                        let newMaxTime = max(group.maxTime, measurement2.duration)
                        
                        group = GroupedMeasurement(
                            name: group.name,
                            count: newCount,
                            totalTime: newTotalTime,
                            avgTime: newAvgTime,
                            minTime: newMinTime,
                            maxTime: newMaxTime
                        )
                        
                        similarNames.append(measurement2.statement)
                        processed.insert(j)
                    }
                }
            }
            
            // Update group name if there are similar operations
            if !similarNames.isEmpty {
                let groupName = if similarNames.count <= 2 {
                    "\(group.name) + \(similarNames.count) similar"
                } else {
                    "\(group.name) + \(similarNames.count) others"
                }
                
                group = GroupedMeasurement(
                    name: groupName,
                    count: group.count,
                    totalTime: group.totalTime,
                    avgTime: group.avgTime,
                    minTime: group.minTime,
                    maxTime: group.maxTime
                )
            }
            
            groups.append(group)
        }
        
        return groups
    }
}

// MARK: - Filtering Summary

extension QuickTrace {
    
    /// Gets a summary of active filters
    /// - Returns: Array of filter descriptions
    internal func getActiveFilters() -> [String] {
        var filters: [String] = []
        
        if showSlowOnly {
            filters.append("slow>\(String(format: "%.3f", slowThreshold))s")
        }
        
        if hideUltraFast {
            filters.append("hide<\(String(format: "%.3f", ultraFastThreshold))s")
        }
        
        if groupSimilar {
            filters.append("group±\(String(format: "%.3f", similarThreshold))s")
        }
        
        return filters
    }
    
    /// Checks if any filters are active
    /// - Returns: True if any smart filters are enabled
    internal func hasActiveFilters() -> Bool {
        return showSlowOnly || hideUltraFast || groupSimilar
    }
}

