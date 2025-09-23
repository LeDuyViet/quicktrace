package com.leduy.quicktrace;

import java.time.Duration;

/**
 * Đại diện cho một nhóm measurements tương tự
 */
public class GroupedMeasurement {
    private final String name;
    private final int count;
    private final Duration totalTime;
    private final Duration avgTime;
    private final Duration minTime;
    private final Duration maxTime;
    
    public GroupedMeasurement(String name, int count, Duration totalTime, 
                             Duration avgTime, Duration minTime, Duration maxTime) {
        this.name = name;
        this.count = count;
        this.totalTime = totalTime;
        this.avgTime = avgTime;
        this.minTime = minTime;
        this.maxTime = maxTime;
    }
    
    public String getName() {
        return name;
    }
    
    public int getCount() {
        return count;
    }
    
    public Duration getTotalTime() {
        return totalTime;
    }
    
    public Duration getAvgTime() {
        return avgTime;
    }
    
    public Duration getMinTime() {
        return minTime;
    }
    
    public Duration getMaxTime() {
        return maxTime;
    }
    
    @Override
    public String toString() {
        return String.format("GroupedMeasurement{name='%s', count=%d, avgTime=%s}", 
                           name, count, avgTime);
    }
}
