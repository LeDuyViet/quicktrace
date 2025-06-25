package quicktrace

import (
	"bytes"
	"fmt"
	"io"
	"os"
	"runtime"
	"strings"
	"time"

	"github.com/k0kubun/pp/v3"
	"github.com/mattn/go-colorable"
)

// DefaultMinDuration là thời gian tối thiểu để hiển thị trace (mặc định 100ms)
const DefaultMinDuration = 100 * time.Millisecond

// ANSI color codes constants
const (
	// Reset
	Reset = "\033[0m"

	// Regular colors
	Black   = "\033[30m"
	Red     = "\033[31m"
	Green   = "\033[32m"
	Yellow  = "\033[33m"
	Blue    = "\033[34m"
	Magenta = "\033[35m"
	Cyan    = "\033[36m"
	White   = "\033[37m"

	// Bright colors
	BrightBlack   = "\033[90m"
	BrightRed     = "\033[91m"
	BrightGreen   = "\033[92m"
	BrightYellow  = "\033[93m"
	BrightBlue    = "\033[94m"
	BrightMagenta = "\033[95m"
	BrightCyan    = "\033[96m"
	BrightWhite   = "\033[97m"

	// Styles
	Bold      = "\033[1m"
	Dim       = "\033[2m"
	Italic    = "\033[3m"
	Underline = "\033[4m"
)

// colorize applies ANSI color codes to text
func colorize(text string, colorCode string) string {
	return colorCode + text + Reset
}

// colorizeWithStyle applies ANSI color codes with style to text
func colorizeWithStyle(text string, colorCode string, styleCode string) string {
	return styleCode + colorCode + text + Reset
}

type Measurement struct {
	Statement string
	Duration  time.Duration
}

// OutputStyle defines different output formats
type OutputStyle int

const (
	StyleDefault OutputStyle = iota
	StyleColorful
	StyleMinimal
	StyleDetailed
	StyleTable
	StyleJSON
)

type Tracer struct {
	name           string
	measurements   []Measurement
	lastTime       time.Time
	totalTime      time.Time
	enabled        bool
	silent         bool
	outputStyle    OutputStyle
	printCondition func(*Tracer) bool
	// Caller info
	callerFile string
	callerLine int
	// Smart filtering options
	showSlowOnly       bool
	slowThreshold      time.Duration
	hideUltraFast      bool
	ultraFastThreshold time.Duration
	groupSimilar       bool
	similarThreshold   time.Duration
}

type TracerOption func(*Tracer)

// ColorRule định nghĩa quy tắc màu cho các khoảng thời gian
type ColorRule struct {
	Threshold time.Duration
	Color     string
	Name      string
}

// PercentageColorRule định nghĩa quy tắc màu cho phần trăm
type PercentageColorRule struct {
	Threshold float64
	Color     string
	Name      string
}

// Predefined color rules for different time ranges (optimized for cross-platform compatibility)
var (
	// Cross-platform safe colors - tối ưu cho cả Windows và Linux, tránh nhầm lẫn màu sắc
	DurationColorRules = []ColorRule{
		{3 * time.Second, Red + Bold, "Very Slow"},        // > 3s - đỏ đậm (chỉ dùng cho thực sự chậm)
		{1 * time.Second, Red, "Slow"},                    // 1s-3s - đỏ
		{500 * time.Millisecond, Yellow, "Medium-Slow"},   // 500ms-1s - vàng (thay tím để rõ ràng hơn)
		{200 * time.Millisecond, BrightBlue, "Medium"},    // 200ms-500ms - xanh dương sáng (an toàn hơn)
		{100 * time.Millisecond, Cyan, "Normal"},          // 100ms-200ms - cyan (225ms sẽ thuộc Medium)
		{50 * time.Millisecond, Green, "Fast"},            // 50ms-100ms - xanh lá
		{10 * time.Millisecond, BrightGreen, "Very Fast"}, // 10ms-50ms - xanh lá sáng
		{0, BrightBlack, "Ultra Fast"},                    // < 10ms - xám sáng
	}

	// Progress bar color rules for percentages - cross-platform safe colors
	ProgressColorRules = []PercentageColorRule{
		{75, Red + Bold, "Critical"}, // > 75% - đỏ đậm
		{50, Red, "High"},            // 50-75% - đỏ
		{25, Magenta, "Medium"},      // 25-50% - tím
		{10, Blue, "Low"},            // 10-25% - xanh dương
		{5, Green, "Very Low"},       // 5-10% - xanh lá
		{0, Cyan, "Minimal"},         // < 5% - cyan
	}
)

// getSpanColorByRule trả về màu sắc dựa trên duration với quy tắc
func getSpanColorByRule(duration time.Duration) string {
	for _, rule := range DurationColorRules {
		if duration >= rule.Threshold {
			return rule.Color
		}
	}
	return White // Fallback
}

// getProgressBarColorByRule trả về màu sắc dựa trên percentage với quy tắc
func getProgressBarColorByRule(percentage float64) string {
	for _, rule := range ProgressColorRules {
		if percentage >= rule.Threshold {
			return rule.Color
		}
	}
	return White // Fallback
}

// getDurationColorName trả về tên mô tả màu cho duration
func getDurationColorName(duration time.Duration) string {
	for _, rule := range DurationColorRules {
		if duration >= rule.Threshold {
			return rule.Name
		}
	}
	return "Unknown"
}

// getProgressColorName trả về tên mô tả màu cho percentage
func getProgressColorName(percentage float64) string {
	for _, rule := range ProgressColorRules {
		if percentage >= rule.Threshold {
			return rule.Name
		}
	}
	return "Unknown"
}

// getCallerInfo lấy thông tin file và line number của caller
func getCallerInfo() (string, int, bool) {
	_, file, line, ok := runtime.Caller(2) // Skip 2 levels: getCallerInfo -> NewSimpleTracer -> user code
	return file, line, ok
}

// formatCallerInfo format thông tin caller thành string đẹp
func formatCallerInfo(file string, line int) string {
	if file == "" {
		return ""
	}
	// Chỉ lấy tên file, không lấy full path
	parts := strings.Split(file, "/")
	if len(parts) > 0 {
		fileName := parts[len(parts)-1]
		return fmt.Sprintf("%s:%d", fileName, line)
	}
	return fmt.Sprintf("%s:%d", file, line)
}

// WithEnabled tắt/bật tracing
func WithEnabled(enabled bool) TracerOption {
	return func(t *Tracer) {
		t.enabled = enabled
	}
}

// WithSilent tắt/bật việc in console (vẫn thu thập data nhưng không in)
func WithSilent(silent bool) TracerOption {
	return func(t *Tracer) {
		t.silent = silent
	}
}

// WithOutputStyle thiết lập style output
func WithOutputStyle(style OutputStyle) TracerOption {
	return func(t *Tracer) {
		t.outputStyle = style
	}
}

// WithMinTotalDuration chỉ in khi tổng thời gian >= duration
func WithMinTotalDuration(minDuration time.Duration) TracerOption {
	return func(t *Tracer) {
		t.printCondition = func(tracer *Tracer) bool {
			return time.Since(tracer.totalTime) >= minDuration
		}
	}
}

// WithMinSpanDuration chỉ in khi có span nào >= duration
func WithMinSpanDuration(minDuration time.Duration) TracerOption {
	return func(t *Tracer) {
		t.printCondition = func(tracer *Tracer) bool {
			for _, m := range tracer.measurements {
				if m.Duration >= minDuration {
					return true
				}
			}
			return false
		}
	}
}

// WithCustomCondition cho phép custom condition bất kỳ
func WithCustomCondition(condition func(*Tracer) bool) TracerOption {
	return func(t *Tracer) {
		t.printCondition = condition
	}
}

// WithShowSlowOnly chỉ hiển thị operations chậm hơn threshold
func WithShowSlowOnly(threshold time.Duration) TracerOption {
	return func(t *Tracer) {
		t.showSlowOnly = true
		t.slowThreshold = threshold
	}
}

// WithHideUltraFast ẩn operations nhanh hơn threshold (mặc định < 1ms)
func WithHideUltraFast(threshold time.Duration) TracerOption {
	return func(t *Tracer) {
		t.hideUltraFast = true
		t.ultraFastThreshold = threshold
	}
}

// WithGroupSimilar nhóm các operations tương tự (có duration gần nhau)
func WithGroupSimilar(threshold time.Duration) TracerOption {
	return func(t *Tracer) {
		t.groupSimilar = true
		t.similarThreshold = threshold
	}
}

// WithSmartFilter kết hợp các filter thông minh
func WithSmartFilter(slowThreshold, ultraFastThreshold, similarThreshold time.Duration) TracerOption {
	return func(t *Tracer) {
		if slowThreshold > 0 {
			t.showSlowOnly = true
			t.slowThreshold = slowThreshold
		}
		if ultraFastThreshold > 0 {
			t.hideUltraFast = true
			t.ultraFastThreshold = ultraFastThreshold
		}
		if similarThreshold > 0 {
			t.groupSimilar = true
			t.similarThreshold = similarThreshold
		}
	}
}

func NewSimpleTracer(name string, opts ...TracerOption) *Tracer {
	t := &Tracer{
		name:        name,
		lastTime:    time.Now(),
		totalTime:   time.Now(),
		enabled:     true,  // mặc định bật
		silent:      false, // mặc định in console
		outputStyle: StyleDefault,
		printCondition: func(tracer *Tracer) bool {
			return time.Since(tracer.totalTime) >= DefaultMinDuration
		}, // mặc định chỉ in khi >= 100ms
	}

	// Capture caller information
	if file, line, ok := getCallerInfo(); ok {
		t.callerFile = file
		t.callerLine = line
	}

	for _, opt := range opts {
		opt(t)
	}

	return t
}

func (t *Tracer) Span(statement string) {
	if !t.enabled {
		return
	}

	now := time.Now()
	duration := now.Sub(t.lastTime)
	t.measurements = append(t.measurements, Measurement{
		Statement: statement,
		Duration:  duration,
	})
	t.lastTime = now
}

func (t *Tracer) End() {
	if !t.enabled {
		return
	}

	t.Span("End")

	if t.silent {
		return
	}

	// Kiểm tra custom condition
	if t.printCondition != nil && !t.printCondition(t) {
		return
	}

	// Set colorable output for better server compatibility
	colorableOutput := colorable.NewColorableStdout()

	// Buffer toàn bộ output trước khi print một lần
	var output string
	switch t.outputStyle {
	case StyleColorful:
		output = t.getColorfulOutput()
	case StyleMinimal:
		output = t.getMinimalOutput()
	case StyleDetailed:
		output = t.getDetailedOutput()
	case StyleTable:
		output = t.getTableOutput()
	case StyleJSON:
		output = t.getJSONOutput()
	default:
		output = t.getDetailedOutput()
	}

	// Print toàn bộ output trong một lần để tránh race condition
	fmt.Fprint(colorableOutput, output)
}

// getSpanColor trả về màu sắc dựa trên duration của span (legacy function)
func getSpanColor(duration time.Duration) string {
	return getSpanColorByRule(duration)
}

// formatDurationWithColor format duration với màu sắc
func formatDurationWithColor(duration time.Duration) string {
	spanColor := getSpanColor(duration)
	return colorize(duration.String(), spanColor)
}

func (t *Tracer) printDefault() {
	totalDuration := time.Since(t.totalTime)

	fmt.Println(colorizeWithStyle(strings.Repeat("=", 70), Cyan, Bold))
	fmt.Printf(colorizeWithStyle("| %-66s \n", Yellow, Bold), t.name)
	fmt.Println(colorizeWithStyle(strings.Repeat("=", 70), Cyan, Bold))
	fmt.Printf(colorizeWithStyle("| %-20s | ", Green, Bold), "Total time")
	fmt.Printf(colorize("%-45v \n", Green), totalDuration)
	fmt.Println(colorize(strings.Repeat("-", 70), Cyan))
	fmt.Printf(colorizeWithStyle("| %-45s | %-20s \n", Magenta, Bold), "Span", "Execution time")
	fmt.Println(colorize(strings.Repeat("-", 70), Cyan))

	for _, m := range t.measurements[:len(t.measurements)-1] { // Exclude the "End" measurement
		spanColor := getSpanColor(m.Duration)
		fmt.Printf("| ")
		fmt.Printf(colorize("%-45s", spanColor), m.Statement)
		fmt.Printf(" | ")
		fmt.Printf(colorize("%-20v", spanColor), m.Duration)
		fmt.Println(" |")
	}

	fmt.Println(colorizeWithStyle(strings.Repeat("=", 70), Cyan, Bold))
}

func (t *Tracer) printColorful() {
	totalDuration := time.Since(t.totalTime)

	// Calculate column widths for consistency - simplified design
	const (
		nameWidth     = 35 // Span name
		durationWidth = 25 // Duration (increased, no right border)
	)

	totalTableWidth := nameWidth + durationWidth + 4 // 1 left border + 1 separator + 2 spaces

	// Modern Unicode borders inspired by go-pretty
	topBorder := "┌" + strings.Repeat("─", totalTableWidth-2) + "┐"
	separator := "├" + strings.Repeat("─", totalTableWidth-2) + "┤"
	bottomBorder := "└" + strings.Repeat("─", totalTableWidth-2) + "┘"

	// Header with colorful styling
	fmt.Println(colorizeWithStyle(topBorder, Cyan, Bold))

	// Title row with improved centering
	titleText := "🚀 " + t.name
	titlePadding := (totalTableWidth - len(titleText) - 2) / 2
	if titlePadding < 1 {
		titlePadding = 1
	}
	remainingPadding := totalTableWidth - len(titleText) - titlePadding - 2
	if remainingPadding < 1 {
		remainingPadding = 1
	}

	titleStr := fmt.Sprintf("│%s%s%s│",
		strings.Repeat(" ", titlePadding),
		titleText,
		strings.Repeat(" ", remainingPadding))
	fmt.Println(colorizeWithStyle(titleStr, Yellow, Bold))

	// Add caller info if available
	if t.callerFile != "" {
		callerInfo := fmt.Sprintf("📍 File: %s:%d", t.callerFile, t.callerLine)
		callerPadding := (totalTableWidth - len(callerInfo) - 2) / 2
		if callerPadding < 1 {
			callerPadding = 1
		}
		remainingCallerPadding := totalTableWidth - len(callerInfo) - callerPadding - 2
		if remainingCallerPadding < 1 {
			remainingCallerPadding = 1
		}

		callerStr := fmt.Sprintf("│%s%s%s│",
			strings.Repeat(" ", callerPadding),
			callerInfo,
			strings.Repeat(" ", remainingCallerPadding))
		fmt.Println(colorize(callerStr, BrightBlack))
	}

	fmt.Println(colorizeWithStyle(separator, Cyan, Bold))

	// Total time row with proper formatting
	totalTimeStr := totalDuration.String()
	totalLine := fmt.Sprintf("│ ⏱️  Total Time: %-*s │ %s",
		nameWidth-16, "",
		totalTimeStr)
	fmt.Println(colorizeWithStyle(totalLine, Green, Bold))

	fmt.Println(colorize(separator, Cyan))

	// Column headers with precise alignment
	headerLine := fmt.Sprintf("│ %-*s │ %s",
		nameWidth, "📋 Span",
		"⏰ Duration")
	fmt.Println(colorizeWithStyle(headerLine, Magenta, Bold))

	fmt.Println(colorize(separator, Cyan))

	// Spans with colorful formatting and precise alignment
	for _, m := range t.measurements[:len(t.measurements)-1] {
		spanColor := getSpanColor(m.Duration)

		// Truncate span name if too long
		spanName := m.Statement
		if len(spanName) > nameWidth {
			spanName = spanName[:nameWidth-3] + "..."
		}

		// Format each column precisely
		fmt.Printf("│ ")
		fmt.Printf(colorize("%-*s", spanColor), nameWidth, spanName)
		fmt.Printf(" │ ")
		fmt.Printf(colorize("%s", spanColor), m.Duration)
		fmt.Printf("\n")
	}

	fmt.Println(colorizeWithStyle(bottomBorder, Cyan, Bold))
}

func (t *Tracer) printMinimal() {
	totalDuration := time.Since(t.totalTime)

	// Simple box for minimal style with better proportions
	const nameWidth = 35
	const durationWidth = 25 // Increased width, no right border needed

	totalWidth := nameWidth + durationWidth + 4 // 1 left border + 1 separator + 2 spaces

	topBorder := "┌" + strings.Repeat("─", totalWidth-2) + "┐"
	separator := "├" + strings.Repeat("─", totalWidth-2) + "┤"
	bottomBorder := "└" + strings.Repeat("─", totalWidth-2) + "┘"

	fmt.Println(colorizeWithStyle(topBorder, Cyan, Bold))

	// Title and total time with proper alignment
	titleText := "⚡ " + t.name
	if len(titleText) > nameWidth {
		titleText = titleText[:nameWidth-3] + "..."
	}

	totalTimeStr := totalDuration.String()

	// Create title line without right border
	titleLine := fmt.Sprintf("│ %-*s │ %s",
		nameWidth, titleText, totalTimeStr)
	fmt.Println(colorizeWithStyle(titleLine, Cyan, Bold))

	// Add caller info if available (chỉ hiển thị tên file và số dòng)
	if t.callerFile != "" {
		shortCallerInfo := formatCallerInfo(t.callerFile, t.callerLine)
		callerInfo := fmt.Sprintf("📍 File: %s", shortCallerInfo)
		if len(callerInfo) > nameWidth {
			callerInfo = callerInfo[:nameWidth-3] + "..."
		}

		callerLine := fmt.Sprintf("│ %-*s │ %s",
			nameWidth, callerInfo, "")
		fmt.Println(colorize(callerLine, BrightBlack))
	}

	// Simple separator line
	fmt.Println(colorize(separator, Cyan))

	// Minimal span listing with consistent formatting
	for _, m := range t.measurements[:len(t.measurements)-1] {
		spanColor := getSpanColor(m.Duration)

		// Format span name with tree structure
		spanName := "  └─ " + m.Statement
		if len(spanName) > nameWidth {
			spanName = spanName[:nameWidth-3] + "..."
		}

		fmt.Printf("│ ")
		fmt.Printf(colorize("%-*s", spanColor), nameWidth, spanName)
		fmt.Printf(" │ ")
		fmt.Printf(colorize("%s", spanColor), m.Duration)
		fmt.Printf("\n")
	}

	fmt.Println(colorizeWithStyle(bottomBorder, Cyan, Bold))
}

func (t *Tracer) printDetailed() {
	totalDuration := time.Since(t.totalTime)

	// Calculate column widths for precise alignment - bỏ statusWidth
	const (
		indexWidth    = 3  // "1."
		nameWidth     = 30 // Operation name (tăng để bù cột Performance)
		durationWidth = 15 // Duration
		percentWidth  = 8  // Percentage
		barWidth      = 12 // Progress bar (tăng một chút)
	)

	// Calculate total width - bỏ statusWidth
	totalWidth := indexWidth + nameWidth + durationWidth + percentWidth + barWidth + 12 // separators + borders

	// Modern Unicode borders
	topBorder := "╔" + strings.Repeat("═", totalWidth-2) + "╗"
	separator := "╠" + strings.Repeat("═", totalWidth-2) + "╣"
	thinSeparator := "╟" + strings.Repeat("─", totalWidth-2) + "╢"
	bottomBorder := "╚" + strings.Repeat("═", totalWidth-2) + "╝"

	// Header - sử dụng màu tối hơn cho nền trắng
	fmt.Println(colorizeWithStyle(topBorder, Blue, Bold))

	// Title row
	titleText := "🎯 TRACE: " + t.name
	titlePadding := (totalWidth - len(titleText) - 2) / 2
	if titlePadding < 1 {
		titlePadding = 1
	}
	remainingPadding := totalWidth - len(titleText) - titlePadding - 2
	if remainingPadding < 1 {
		remainingPadding = 1
	}

	titleStr := fmt.Sprintf("║%s%s%s",
		strings.Repeat(" ", titlePadding),
		titleText,
		strings.Repeat(" ", remainingPadding))
	fmt.Println(colorizeWithStyle(titleStr, Magenta, Bold)) // Thay BrightYellow bằng Magenta

	fmt.Println(colorizeWithStyle(separator, Blue, Bold))

	// Summary section
	fmt.Printf(colorizeWithStyle("║ 📊 SUMMARY%s\n", Green, Bold), strings.Repeat(" ", totalWidth-13)) // Thay BrightGreen bằng Green

	// Total execution time với căn chỉnh chính xác
	totalTimeStr := totalDuration.String()
	prefix := "║ • Total Execution Time: "
	usedWidth := len(prefix) + len(totalTimeStr) // Tính độ dài text thuần
	paddingRight := totalWidth - usedWidth - 1   // -1 cho ║ cuối

	// Ensure paddingRight is never negative
	if paddingRight < 0 {
		paddingRight = 0
	}

	fmt.Print(prefix)
	fmt.Print(colorizeWithStyle(totalTimeStr, Green, Bold))
	fmt.Printf("%s\n", strings.Repeat(" ", paddingRight))

	// Number of spans với căn chỉnh chính xác
	spanCount := len(t.measurements) - 1
	spanCountStr := fmt.Sprintf("%d", spanCount)
	prefix = "║ • Number of Spans: "
	usedWidth = len(prefix) + len(spanCountStr) // Tính độ dài text thuần
	paddingRight = totalWidth - usedWidth - 1   // -1 cho ║ cuối

	// Ensure paddingRight is never negative
	if paddingRight < 0 {
		paddingRight = 0
	}

	fmt.Print(prefix)
	fmt.Print(colorizeWithStyle(spanCountStr, Blue, Bold))
	fmt.Printf("%s\n", strings.Repeat(" ", paddingRight))

	// Find slowest operation
	var slowest Measurement
	for _, m := range t.measurements[:len(t.measurements)-1] {
		if m.Duration > slowest.Duration {
			slowest = m
		}
	}

	slowestName := slowest.Statement
	if len(slowestName) > 25 {
		slowestName = slowestName[:22] + "..."
	}

	// Print với màu đỏ cho Slowest Operation
	prefix = "║ • Slowest Operation: "
	usedWidth = len(prefix) + len(slowestName) // Tính độ dài text thuần
	paddingRight = totalWidth - usedWidth - 1  // -1 cho ║ cuối

	// Ensure paddingRight is never negative
	if paddingRight < 0 {
		paddingRight = 0
	}

	fmt.Print(prefix)
	fmt.Print(colorizeWithStyle(slowestName, Red, Bold))
	fmt.Printf("%s\n", strings.Repeat(" ", paddingRight))

	slowestDurStr := slowest.Duration.String()
	prefix = "║ • Slowest Duration: "
	usedWidth = len(prefix) + len(slowestDurStr) // Tính độ dài text thuần
	paddingRight = totalWidth - usedWidth - 1    // -1 cho ║ cuối

	// Ensure paddingRight is never negative
	if paddingRight < 0 {
		paddingRight = 0
	}

	fmt.Print(prefix)
	fmt.Print(colorizeWithStyle(slowestDurStr, Red, Bold))
	fmt.Printf("%s\n", strings.Repeat(" ", paddingRight))

	// Add caller info if available
	if t.callerFile != "" {
		callerInfoStr := fmt.Sprintf("%s:%d", t.callerFile, t.callerLine)

		prefix = "║ • File: "
		fmt.Print(prefix)
		fmt.Print(colorizeWithStyle(callerInfoStr, BrightBlack, Bold))
		fmt.Printf("\n")
	}

	fmt.Println(colorizeWithStyle(separator, Blue, Bold))

	// Detailed breakdown header
	fmt.Printf(colorizeWithStyle("║ 🔍 DETAILED BREAKDOWN%s\n", Magenta, Bold), strings.Repeat(" ", totalWidth-23)) // Thay BrightMagenta bằng Magenta
	fmt.Println(colorizeWithStyle(thinSeparator, Blue, Bold))

	// Column headers - bỏ Performance column, sử dụng màu tối hơn
	fmt.Printf("║")
	fmt.Printf(colorizeWithStyle(" %*s", Magenta, Bold), indexWidth, "#") // Thay BrightMagenta bằng Magenta
	fmt.Printf(" │")
	fmt.Printf(colorizeWithStyle(" %-*s", Magenta, Bold), nameWidth-1, "Operation")
	fmt.Printf(" │")
	fmt.Printf(colorizeWithStyle(" %*s", Magenta, Bold), durationWidth-1, "Duration")
	fmt.Printf(" │")
	fmt.Printf(colorizeWithStyle(" %*s", Magenta, Bold), percentWidth-1, "Percent")
	fmt.Printf(" │")
	fmt.Printf(colorizeWithStyle(" %-*s", Magenta, Bold), barWidth-1, "Progress")
	fmt.Printf(" \n")

	fmt.Println(colorize(thinSeparator, Cyan))

	// Apply smart filtering to measurements
	filteredData := t.applySmartFiltering(t.measurements[:len(t.measurements)-1])

	// Data rows với smart filtering
	for i, item := range filteredData {
		var operationName string
		var duration time.Duration
		var isGrouped bool

		// Check if it's a grouped measurement or regular measurement
		switch v := item.(type) {
		case GroupedMeasurement:
			operationName = v.Name
			duration = v.AvgTime
			isGrouped = true
		case Measurement:
			operationName = v.Statement
			duration = v.Duration
			isGrouped = false
		default:
			continue
		}

		percentage := float64(duration) / float64(totalDuration) * 100

		// Progress bar
		barLength := int(percentage / 8) // 8% per character để phù hợp với barWidth = 12
		if barLength > barWidth-1 {
			barLength = barWidth - 1
		}
		if barLength < 0 {
			barLength = 0
		}

		progressBar := strings.Repeat("█", barLength)
		if barLength < barWidth-1 {
			progressBar += strings.Repeat("░", (barWidth-1)-barLength)
		}

		// Truncate operation name if too long
		if len(operationName) > nameWidth-1 {
			operationName = operationName[:nameWidth-4] + "..."
		}

		// Format percentage
		percentStr := fmt.Sprintf("%.1f%%", percentage)

		// Colors - sử dụng màu khác nhau cho span và progress bar
		spanColor := getSpanColor(duration)
		// Progress bar sử dụng màu xanh đậm thay vì bright blue cho nền trắng
		progressColor := Blue + Bold

		// Add icon for grouped items
		displayName := operationName
		if isGrouped {
			displayName = "📦 " + operationName
		}

		fmt.Printf("║")
		fmt.Printf(" %*d", indexWidth, i+1)
		fmt.Printf(" │ ")
		fmt.Printf(colorize("%-*s", spanColor), nameWidth-1, displayName)
		fmt.Printf(" │ ")
		fmt.Printf(colorize("%*v", spanColor), durationWidth-2, duration)
		fmt.Printf(" │ ")
		fmt.Printf(colorize("%*s", spanColor), percentWidth-2, percentStr) // percentage cùng màu với duration
		fmt.Printf(" │ ")
		fmt.Printf(colorize("%-*s", progressColor), barWidth-1, progressBar) // progress bar màu xanh
		fmt.Printf(" \n")
	}

	// Show filtering summary if any filters are applied
	if t.showSlowOnly || t.hideUltraFast || t.groupSimilar {
		fmt.Println(colorize(thinSeparator, Cyan))

		originalCount := len(t.measurements) - 1
		filteredCount := len(filteredData)

		// Show active filters info
		var activeFilters []string
		if t.showSlowOnly {
			activeFilters = append(activeFilters, fmt.Sprintf("slow>%v", t.slowThreshold))
		}
		if t.hideUltraFast {
			activeFilters = append(activeFilters, fmt.Sprintf("hide<%v", t.ultraFastThreshold))
		}
		if t.groupSimilar {
			activeFilters = append(activeFilters, fmt.Sprintf("group±%v", t.similarThreshold))
		}

		filterInfo := fmt.Sprintf("🔍 Filtered: %d/%d spans | Active: %s",
			filteredCount, originalCount, strings.Join(activeFilters, ", "))

		fmt.Printf("║ ")
		fmt.Printf(colorize("%-*s", BrightBlack), totalWidth-4, filterInfo)
		fmt.Printf(" ║\n")
	}

	fmt.Println(colorizeWithStyle(bottomBorder, Blue, Bold)) // Thay BrightCyan bằng Blue
}

func (t *Tracer) printTable() {
	totalDuration := time.Since(t.totalTime)

	// Calculate column widths for consistent alignment
	const (
		indexWidth    = 4  // "No."
		nameWidth     = 45 // Span name
		durationWidth = 20 // Duration (increased, no right border)
	)

	// Simplified table style without right border
	totalTableWidth := indexWidth + nameWidth + durationWidth + 3 // 2 separators + 1 left border

	topBorder := "┌" + strings.Repeat("─", indexWidth) + "┬" + strings.Repeat("─", nameWidth) + "┬" + strings.Repeat("─", durationWidth) + "┐"
	headerSeparator := "├" + strings.Repeat("─", indexWidth) + "┼" + strings.Repeat("─", nameWidth) + "┼" + strings.Repeat("─", durationWidth) + "┤"
	bottomBorder := "└" + strings.Repeat("─", indexWidth) + "┴" + strings.Repeat("─", nameWidth) + "┴" + strings.Repeat("─", durationWidth) + "┘"

	// Header với colors - sử dụng màu tối hơn cho nền trắng
	fmt.Println(colorizeWithStyle(topBorder, Blue, Bold))

	// Table title trong header
	titlePadding := (totalTableWidth - len(t.name) - 4) / 2 // 4 for "🚀 "
	if titlePadding < 1 {
		titlePadding = 1
	}
	remainingPadding := totalTableWidth - len(t.name) - titlePadding - 4
	if remainingPadding < 1 {
		remainingPadding = 1
	}

	titleStr := fmt.Sprintf("│%s🚀 %s%s",
		strings.Repeat(" ", titlePadding),
		t.name,
		strings.Repeat(" ", remainingPadding))
	fmt.Println(colorizeWithStyle(titleStr, Magenta, Bold)) // Thay BrightYellow bằng Magenta

	// Add caller info if available
	if t.callerFile != "" {
		callerInfo := fmt.Sprintf("📍 File: %s:%d", t.callerFile, t.callerLine)
		callerPadding := (totalTableWidth - len(callerInfo) - 2) / 2
		if callerPadding < 1 {
			callerPadding = 1
		}
		remainingCallerPadding := totalTableWidth - len(callerInfo) - callerPadding - 2
		if remainingCallerPadding < 1 {
			remainingCallerPadding = 1
		}

		callerStr := fmt.Sprintf("│%s%s%s",
			strings.Repeat(" ", callerPadding),
			callerInfo,
			strings.Repeat(" ", remainingCallerPadding))
		fmt.Println(colorize(callerStr, BrightBlack))
	}

	fmt.Println(colorizeWithStyle(headerSeparator, Blue, Bold)) // Thay BrightCyan bằng Blue

	// Column headers với proper alignment - sử dụng màu tối hơn
	fmt.Print("│")
	fmt.Printf(colorizeWithStyle(" %-2s ", Magenta, Bold), "No") // Thay BrightMagenta bằng Magenta
	fmt.Print("│")
	fmt.Printf(colorizeWithStyle(" %-*s", Magenta, Bold), nameWidth-1, "Span Name")
	fmt.Print("│")
	fmt.Printf(colorizeWithStyle(" %s", Magenta, Bold), "Duration")
	fmt.Println("")

	fmt.Println(colorize(headerSeparator, Cyan))

	// Summary row với total duration - sử dụng màu tối hơn
	fmt.Print("│")
	fmt.Printf(colorizeWithStyle(" %-2s ", Green, Bold), "") // Thay BrightGreen bằng Green
	fmt.Print("│")
	fmt.Printf(colorizeWithStyle(" %-*s", Green, Bold), nameWidth-1, "📊 TOTAL EXECUTION TIME")
	fmt.Print("│ ")

	totalColor := getSpanColor(totalDuration)
	fmt.Printf(colorize("%s", totalColor), totalDuration)
	fmt.Println("")

	fmt.Println(colorize(headerSeparator, Cyan))

	// Data rows với spans (exclude "End" measurement)
	for i, m := range t.measurements[:len(t.measurements)-1] {
		spanColor := getSpanColor(m.Duration)

		// Row border
		fmt.Print("│")

		// Index column với right alignment
		fmt.Printf(" %*d ", indexWidth-2, i+1)
		fmt.Print("│ ")

		// Span name với truncation nếu quá dài và left alignment
		spanName := m.Statement
		if len(spanName) > nameWidth-2 {
			spanName = spanName[:nameWidth-5] + "..."
		}
		fmt.Printf(colorize("%-*s", spanColor), nameWidth-1, spanName)
		fmt.Print("│ ")

		// Duration với color
		fmt.Printf(colorize("%s", spanColor), m.Duration)
		fmt.Println("")
	}

	// Bottom border
	fmt.Println(colorizeWithStyle(bottomBorder, Blue, Bold)) // Thay BrightCyan bằng Blue

	// Summary statistics dưới table
	fmt.Println()
	fmt.Printf(colorize("📈 Spans: %d | ", BrightBlack), len(t.measurements)-1)

	// Find slowest span
	var slowest Measurement
	for _, m := range t.measurements[:len(t.measurements)-1] {
		if m.Duration > slowest.Duration {
			slowest = m
		}
	}
	fmt.Printf(colorize("🐌 Slowest: %s (%v)", BrightBlack), slowest.Statement, slowest.Duration)
	fmt.Println()
}

func (t *Tracer) printJSON() {
	totalDuration := time.Since(t.totalTime)

	fmt.Println(colorizeWithStyle("📄 JSON Output:", Magenta, Bold)) // Thay BrightMagenta bằng Magenta

	// Create a structured data for pretty printing
	data := map[string]interface{}{
		"tracer_name":    t.name,
		"total_duration": totalDuration.String(),
		"total_ns":       totalDuration.Nanoseconds(),
		"spans":          make([]map[string]interface{}, 0),
	}

	// Add caller info if available
	if t.callerFile != "" {
		data["caller_info"] = map[string]interface{}{
			"file":      fmt.Sprintf("%s:%d", t.callerFile, t.callerLine),
			"full_path": t.callerFile,
			"line":      t.callerLine,
		}
	}

	for _, m := range t.measurements[:len(t.measurements)-1] {
		// Thêm color classification cho JSON
		var colorClass string
		if m.Duration > 1000*time.Millisecond {
			colorClass = "slow" // > 1s
		} else if m.Duration > 100*time.Millisecond {
			colorClass = "medium" // 100ms-1s
		} else if m.Duration > 10*time.Millisecond {
			colorClass = "fast" // 10ms-100ms
		} else {
			colorClass = "very_fast" // < 10ms
		}

		span := map[string]interface{}{
			"name":        m.Statement,
			"duration":    m.Duration.String(),
			"ns":          m.Duration.Nanoseconds(),
			"percent":     float64(m.Duration) / float64(totalDuration) * 100,
			"color_class": colorClass,
		}
		data["spans"] = append(data["spans"].([]map[string]interface{}), span)
	}

	pp.Println(data)
}

// SetEnabled cho phép tắt/bật tracing trong runtime
func (t *Tracer) SetEnabled(enabled bool) {
	t.enabled = enabled
}

// SetSilent cho phép tắt/bật việc in console trong runtime
func (t *Tracer) SetSilent(silent bool) {
	t.silent = silent
}

// SetOutputStyle cho phép thay đổi style output trong runtime
func (t *Tracer) SetOutputStyle(style OutputStyle) {
	t.outputStyle = style
}

// SetPrintCondition cho phép thay đổi condition trong runtime
func (t *Tracer) SetPrintCondition(condition func(*Tracer) bool) {
	t.printCondition = condition
}

// IsEnabled kiểm tra tracing có được bật không
func (t *Tracer) IsEnabled() bool {
	return t.enabled
}

// IsSilent kiểm tra silent mode có được bật không
func (t *Tracer) IsSilent() bool {
	return t.silent
}

// GetOutputStyle lấy style output hiện tại
func (t *Tracer) GetOutputStyle() OutputStyle {
	return t.outputStyle
}

// GetTotalDuration lấy tổng thời gian hiện tại
func (t *Tracer) GetTotalDuration() time.Duration {
	return time.Since(t.totalTime)
}

// GetMeasurements lấy danh sách measurements
func (t *Tracer) GetMeasurements() []Measurement {
	return t.measurements
}

// getColorfulOutput trả về colorful output dưới dạng string
func (t *Tracer) getColorfulOutput() string {
	return t.captureOutput(func() { t.printColorful() })
}

// getMinimalOutput trả về minimal output dưới dạng string
func (t *Tracer) getMinimalOutput() string {
	return t.captureOutput(func() { t.printMinimal() })
}

// getDetailedOutput trả về detailed output dưới dạng string
func (t *Tracer) getDetailedOutput() string {
	return t.captureOutput(func() { t.printDetailed() })
}

// getTableOutput trả về table output dưới dạng string
func (t *Tracer) getTableOutput() string {
	return t.captureOutput(func() { t.printTable() })
}

// getJSONOutput trả về JSON output dưới dạng string
func (t *Tracer) getJSONOutput() string {
	return t.captureOutput(func() { t.printJSON() })
}

// captureOutput captures all stdout output from the given function
func (t *Tracer) captureOutput(fn func()) string {
	// Create a pipe to capture output
	r, w, _ := os.Pipe()

	// Store original stdout
	originalStdout := os.Stdout

	// Redirect stdout to our pipe
	os.Stdout = w

	// Create a channel to receive captured output
	outputChan := make(chan string, 1)

	// Start a goroutine to read from pipe
	go func() {
		var buf bytes.Buffer
		io.Copy(&buf, r)
		outputChan <- buf.String()
	}()

	// Execute the function
	fn()

	// Restore stdout
	w.Close()
	os.Stdout = originalStdout

	// Get captured output
	output := <-outputChan
	return output
}

// GroupedMeasurement đại diện cho một nhóm measurements tương tự
type GroupedMeasurement struct {
	Name      string
	Count     int
	TotalTime time.Duration
	AvgTime   time.Duration
	MinTime   time.Duration
	MaxTime   time.Duration
}

// applySmartFiltering áp dụng các filter thông minh lên measurements
func (t *Tracer) applySmartFiltering(measurements []Measurement) []interface{} {
	if len(measurements) == 0 {
		return []interface{}{}
	}

	// Bước 1: Filter theo slow threshold
	var filtered []Measurement
	if t.showSlowOnly {
		for _, m := range measurements {
			if m.Duration >= t.slowThreshold {
				filtered = append(filtered, m)
			}
		}
	} else {
		filtered = measurements
	}

	// Bước 2: Filter bỏ ultra fast
	if t.hideUltraFast {
		var temp []Measurement
		for _, m := range filtered {
			if m.Duration >= t.ultraFastThreshold {
				temp = append(temp, m)
			}
		}
		filtered = temp
	}

	// Bước 3: Group similar nếu cần
	var result []interface{}
	if t.groupSimilar && len(filtered) > 0 {
		groups := t.groupSimilarMeasurements(filtered)
		for _, group := range groups {
			result = append(result, group)
		}
	} else {
		// Convert to interface{} slice
		for _, m := range filtered {
			result = append(result, m)
		}
	}

	return result
}

// groupSimilarMeasurements nhóm các measurements có duration tương tự
func (t *Tracer) groupSimilarMeasurements(measurements []Measurement) []GroupedMeasurement {
	if len(measurements) == 0 {
		return []GroupedMeasurement{}
	}

	var groups []GroupedMeasurement
	processed := make(map[int]bool)

	for i, m1 := range measurements {
		if processed[i] {
			continue
		}

		// Tạo nhóm mới
		group := GroupedMeasurement{
			Name:      m1.Statement,
			Count:     1,
			TotalTime: m1.Duration,
			MinTime:   m1.Duration,
			MaxTime:   m1.Duration,
		}
		processed[i] = true

		// Tìm các measurements tương tự
		var similarNames []string
		for j, m2 := range measurements {
			if i != j && !processed[j] {
				// Kiểm tra nếu duration gần nhau (trong khoảng similarThreshold)
				diff := m1.Duration - m2.Duration
				if diff < 0 {
					diff = -diff
				}

				if diff <= t.similarThreshold {
					group.Count++
					group.TotalTime += m2.Duration
					if m2.Duration < group.MinTime {
						group.MinTime = m2.Duration
					}
					if m2.Duration > group.MaxTime {
						group.MaxTime = m2.Duration
					}
					similarNames = append(similarNames, m2.Statement)
					processed[j] = true
				}
			}
		}

		// Tính average time
		group.AvgTime = group.TotalTime / time.Duration(group.Count)

		// Nếu có nhiều operations tương tự, cập nhật tên group
		if len(similarNames) > 0 {
			if len(similarNames) <= 2 {
				group.Name = fmt.Sprintf("%s + %d similar", group.Name, len(similarNames))
			} else {
				group.Name = fmt.Sprintf("%s + %d others", group.Name, len(similarNames))
			}
		}

		groups = append(groups, group)
	}

	return groups
}
