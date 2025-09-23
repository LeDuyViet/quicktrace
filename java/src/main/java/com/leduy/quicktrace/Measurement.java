package com.leduy.quicktrace;

import java.time.Duration;

/**
 * Đại diện cho một measurement trong trace
 */
public class Measurement {
    private final String statement;
    private final Duration duration;
    
    public Measurement(String statement, Duration duration) {
        this.statement = statement;
        this.duration = duration;
    }
    
    public String getStatement() {
        return statement;
    }
    
    public Duration getDuration() {
        return duration;
    }
    
    @Override
    public String toString() {
        return String.format("Measurement{statement='%s', duration=%s}", statement, duration);
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        
        Measurement that = (Measurement) o;
        return statement.equals(that.statement) && duration.equals(that.duration);
    }
    
    @Override
    public int hashCode() {
        return statement.hashCode() * 31 + duration.hashCode();
    }
}
