package com.leduy.quicktrace;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

import java.io.PrintStream;
import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.function.Predicate;
import java.util.stream.Collectors;

/**
 * QuickTrace Tracer cho Java
 * A lightweight, colorful tracing library với smart filtering capabilities
 */
public class Tracer {
    
    // Default minimum duration để hiển thị trace
    public static final Duration DEFAULT_MIN_DURATION = Duration.ofMillis(100);
    
    private final String name;
    private final List<Measurement> measurements;
    private Instant lastTime;
    private final Instant totalTime;
    private boolean enabled;
    private boolean silent;
    private OutputStyle outputStyle;
    private Predicate<Tracer> printCondition;
    
    // Caller info
    private final String callerInfo;
    
    // Smart filtering options
    private boolean showSlowOnly;
    private Duration slowThreshold;
    private boolean hideUltraFast;
    private Duration ultraFastThreshold;
    private boolean groupSimilar;
    private Duration similarThreshold;
    
    private Tracer(Builder builder) {
        this.name = builder.name;
        this.measurements = new ArrayList<>();
        this.lastTime = Instant.now();
        this.totalTime = Instant.now();
        this.enabled = builder.enabled;
        this.silent = builder.silent;
        this.outputStyle = builder.outputStyle;
        this.printCondition = builder.printCondition;
        this.showSlowOnly = builder.showSlowOnly;
        this.slowThreshold = builder.slowThreshold;
        this.hideUltraFast = builder.hideUltraFast;
        this.ultraFastThreshold = builder.ultraFastThreshold;
        this.groupSimilar = builder.groupSimilar;
        this.similarThreshold = builder.similarThreshold;
        
        // Capture caller information
        this.callerInfo = captureCallerInfo();
    }
    
    /**
     * Tạo một Simple Tracer với default settings
     */
    public static Tracer newSimpleTracer(String name) {
        return new Builder(name).build();
    }
    
    /**
     * Tạo builder để customize tracer
     */
    public static Builder builder(String name) {
        return new Builder(name);
    }
    
    /**
     * Builder class cho Tracer
     */
    public static class Builder {
        private final String name;
        private boolean enabled = true;
        private boolean silent = false;
        private OutputStyle outputStyle = OutputStyle.DEFAULT;
        private Predicate<Tracer> printCondition = tracer -> 
            Duration.between(tracer.totalTime, Instant.now()).compareTo(DEFAULT_MIN_DURATION) >= 0;
        
        // Smart filtering
        private boolean showSlowOnly = false;
        private Duration slowThreshold = Duration.ZERO;
        private boolean hideUltraFast = false;
        private Duration ultraFastThreshold = Duration.ZERO;
        private boolean groupSimilar = false;
        private Duration similarThreshold = Duration.ZERO;
        
        public Builder(String name) {
            this.name = name;
        }
        
        public Builder enabled(boolean enabled) {
            this.enabled = enabled;
            return this;
        }
        
        public Builder silent(boolean silent) {
            this.silent = silent;
            return this;
        }
        
        public Builder outputStyle(OutputStyle style) {
            this.outputStyle = style;
            return this;
        }
        
        public Builder minTotalDuration(Duration minDuration) {
            this.printCondition = tracer -> 
                Duration.between(tracer.totalTime, Instant.now()).compareTo(minDuration) >= 0;
            return this;
        }
        
        public Builder minSpanDuration(Duration minDuration) {
            this.printCondition = tracer -> 
                tracer.measurements.stream()
                    .anyMatch(m -> m.getDuration().compareTo(minDuration) >= 0);
            return this;
        }
        
        public Builder customCondition(Predicate<Tracer> condition) {
            this.printCondition = condition;
            return this;
        }
        
        public Builder showSlowOnly(Duration threshold) {
            this.showSlowOnly = true;
            this.slowThreshold = threshold;
            return this;
        }
        
        public Builder hideUltraFast(Duration threshold) {
            this.hideUltraFast = true;
            this.ultraFastThreshold = threshold;
            return this;
        }
        
        public Builder groupSimilar(Duration threshold) {
            this.groupSimilar = true;
            this.similarThreshold = threshold;
            return this;
        }
        
        public Builder smartFilter(Duration slowThreshold, Duration ultraFastThreshold, Duration similarThreshold) {
            if (!slowThreshold.isZero()) {
                showSlowOnly(slowThreshold);
            }
            if (!ultraFastThreshold.isZero()) {
                hideUltraFast(ultraFastThreshold);
            }
            if (!similarThreshold.isZero()) {
                groupSimilar(similarThreshold);
            }
            return this;
        }
        
        public Tracer build() {
            return new Tracer(this);
        }
    }
    
    /**
     * Ghi lại một span với statement
     */
    public void span(String statement) {
        if (!enabled) {
            return;
        }
        
        Instant now = Instant.now();
        Duration duration = Duration.between(lastTime, now);
        measurements.add(new Measurement(statement, duration));
        lastTime = now;
    }
    
    /**
     * Kết thúc tracing và in output nếu cần
     */
    public void end() {
        if (!enabled) {
            return;
        }
        
        span("End");
        
        if (silent) {
            return;
        }
        
        // Kiểm tra print condition
        if (printCondition != null && !printCondition.test(this)) {
            return;
        }
        
        // Print output theo style
        String output = getOutput();
        System.out.print(output);
    }
    
    /**
     * Lấy output theo style hiện tại
     */
    private String getOutput() {
        switch (outputStyle) {
            case COLORFUL:
                return getColorfulOutput();
            case MINIMAL:
                return getMinimalOutput();
            case DETAILED:
                return getDetailedOutput();
            case TABLE:
                return getTableOutput();
            case JSON:
                return getJSONOutput();
            default:
                return getDefaultOutput();
        }
    }
    
    /**
     * Capture caller information cho debugging
     */
    private String captureCallerInfo() {
        StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
        // Skip: getStackTrace() -> captureCallerInfo() -> constructor -> newSimpleTracer/builder -> user code
        if (stackTrace.length > 4) {
            StackTraceElement caller = stackTrace[4];
            String fileName = caller.getFileName();
            int lineNumber = caller.getLineNumber();
            return String.format("%s:%d", fileName != null ? fileName : "Unknown", lineNumber);
        }
        return "Unknown:0";
    }
    
    // Getters
    public String getName() { return name; }
    public List<Measurement> getMeasurements() { return new ArrayList<>(measurements); }
    public Duration getTotalDuration() { return Duration.between(totalTime, Instant.now()); }
    public boolean isEnabled() { return enabled; }
    public boolean isSilent() { return silent; }
    public OutputStyle getOutputStyle() { return outputStyle; }
    public String getCallerInfo() { return callerInfo; }
    
    // Setters for runtime control
    public void setEnabled(boolean enabled) { this.enabled = enabled; }
    public void setSilent(boolean silent) { this.silent = silent; }
    public void setOutputStyle(OutputStyle style) { this.outputStyle = style; }
    public void setPrintCondition(Predicate<Tracer> condition) { this.printCondition = condition; }
    
    // Output methods using OutputRenderer
    private String getDefaultOutput() {
        return OutputRenderer.renderDefault(this);
    }
    
    private String getColorfulOutput() {
        return OutputRenderer.renderColorful(this);
    }
    
    private String getMinimalOutput() {
        return OutputRenderer.renderMinimal(this);
    }
    
    private String getDetailedOutput() {
        return OutputRenderer.renderDetailed(this);
    }
    
    private String getTableOutput() {
        return OutputRenderer.renderTable(this);
    }
    
    private String getJSONOutput() {
        try {
            ObjectMapper mapper = new ObjectMapper();
            ObjectNode root = mapper.createObjectNode();
            
            root.put("tracer_name", name);
            root.put("total_duration", getTotalDuration().toString());
            root.put("total_ns", getTotalDuration().toNanos());
            
            if (!callerInfo.equals("Unknown:0")) {
                ObjectNode callerNode = mapper.createObjectNode();
                callerNode.put("file", callerInfo);
                root.set("caller_info", callerNode);
            }
            
            ArrayNode spansArray = mapper.createArrayNode();
            Duration totalDur = getTotalDuration();
            
            for (Measurement m : measurements.subList(0, measurements.size() - 1)) {
                ObjectNode span = mapper.createObjectNode();
                span.put("name", m.getStatement());
                span.put("duration", m.getDuration().toString());
                span.put("ns", m.getDuration().toNanos());
                span.put("percent", (double) m.getDuration().toNanos() / totalDur.toNanos() * 100);
                
                // Add color classification
                String colorClass = getColorClass(m.getDuration());
                span.put("color_class", colorClass);
                
                spansArray.add(span);
            }
            
            root.set("spans", spansArray);
            
            return ColorRules.colorizeWithStyle("📄 JSON Output:", ColorRules.MAGENTA, ColorRules.BOLD) + "\n" +
                   mapper.writerWithDefaultPrettyPrinter().writeValueAsString(root) + "\n";
                   
        } catch (Exception e) {
            return "Error generating JSON output: " + e.getMessage() + "\n";
        }
    }
    
    private String getColorClass(Duration duration) {
        if (duration.compareTo(Duration.ofSeconds(1)) > 0) {
            return "slow";
        } else if (duration.compareTo(Duration.ofMillis(100)) > 0) {
            return "medium";
        } else if (duration.compareTo(Duration.ofMillis(10)) > 0) {
            return "fast";
        } else {
            return "very_fast";
        }
    }
    
    /**
     * Áp dụng smart filtering lên measurements
     */
    public List<Object> applySmartFiltering(List<Measurement> measurements) {
        if (measurements.isEmpty()) {
            return new ArrayList<>();
        }
        
        // Bước 1: Filter theo slow threshold
        List<Measurement> filtered = measurements;
        if (showSlowOnly) {
            filtered = measurements.stream()
                    .filter(m -> m.getDuration().compareTo(slowThreshold) >= 0)
                    .collect(Collectors.toList());
        }
        
        // Bước 2: Filter bỏ ultra fast
        if (hideUltraFast) {
            filtered = filtered.stream()
                    .filter(m -> m.getDuration().compareTo(ultraFastThreshold) >= 0)
                    .collect(Collectors.toList());
        }
        
        // Bước 3: Group similar nếu cần
        List<Object> result = new ArrayList<>();
        if (groupSimilar && !filtered.isEmpty()) {
            List<GroupedMeasurement> groups = groupSimilarMeasurements(filtered);
            result.addAll(groups);
        } else {
            result.addAll(filtered);
        }
        
        return result;
    }
    
    /**
     * Nhóm các measurements có duration tương tự
     */
    private List<GroupedMeasurement> groupSimilarMeasurements(List<Measurement> measurements) {
        if (measurements.isEmpty()) {
            return new ArrayList<>();
        }
        
        List<GroupedMeasurement> groups = new ArrayList<>();
        Set<Integer> processed = new HashSet<>();
        
        for (int i = 0; i < measurements.size(); i++) {
            if (processed.contains(i)) {
                continue;
            }
            
            Measurement m1 = measurements.get(i);
            
            // Tạo nhóm mới
            String groupName = m1.getStatement();
            int count = 1;
            Duration totalTime = m1.getDuration();
            Duration minTime = m1.getDuration();
            Duration maxTime = m1.getDuration();
            
            processed.add(i);
            List<String> similarNames = new ArrayList<>();
            
            // Tìm các measurements tương tự
            for (int j = i + 1; j < measurements.size(); j++) {
                if (processed.contains(j)) {
                    continue;
                }
                
                Measurement m2 = measurements.get(j);
                
                // Kiểm tra nếu duration gần nhau
                Duration diff = m1.getDuration().compareTo(m2.getDuration()) >= 0 
                    ? m1.getDuration().minus(m2.getDuration())
                    : m2.getDuration().minus(m1.getDuration());
                
                if (diff.compareTo(similarThreshold) <= 0) {
                    count++;
                    totalTime = totalTime.plus(m2.getDuration());
                    if (m2.getDuration().compareTo(minTime) < 0) {
                        minTime = m2.getDuration();
                    }
                    if (m2.getDuration().compareTo(maxTime) > 0) {
                        maxTime = m2.getDuration();
                    }
                    similarNames.add(m2.getStatement());
                    processed.add(j);
                }
            }
            
            // Tính average time
            Duration avgTime = totalTime.dividedBy(count);
            
            // Nếu có nhiều operations tương tự, cập nhật tên group
            if (!similarNames.isEmpty()) {
                if (similarNames.size() <= 2) {
                    groupName = String.format("%s + %d similar", groupName, similarNames.size());
                } else {
                    groupName = String.format("%s + %d others", groupName, similarNames.size());
                }
            }
            
            groups.add(new GroupedMeasurement(groupName, count, totalTime, avgTime, minTime, maxTime));
        }
        
        return groups;
    }
    
    // Getters for smart filtering info
    public boolean hasActiveFilters() {
        return showSlowOnly || hideUltraFast || groupSimilar;
    }
    
    public String getActiveFiltersInfo() {
        List<String> activeFilters = new ArrayList<>();
        if (showSlowOnly) {
            activeFilters.add("slow>" + slowThreshold);
        }
        if (hideUltraFast) {
            activeFilters.add("hide<" + ultraFastThreshold);
        }
        if (groupSimilar) {
            activeFilters.add("group±" + similarThreshold);
        }
        return String.join(", ", activeFilters);
    }
}
