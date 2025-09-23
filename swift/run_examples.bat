@echo off
REM QuickTrace Swift Examples Runner for Windows
REM This script runs all examples in sequence with pauses between them

echo 🚀 QuickTrace for Swift - Examples Runner
echo ========================================

REM Function to run an example
:run_example
set name=%1
set target=%2

echo.
echo =================== %name% ===================
echo.

swift run %target%
if %errorlevel% neq 0 (
    echo ❌ %name% failed
    goto :eof
) else (
    echo ✅ %name% completed successfully
)

echo.
echo Press Enter to continue to next example...
pause >nul
goto :eof

REM Check if we're in the right directory
if not exist "Package.swift" (
    echo Error: Package.swift not found. Please run this script from the swift\ directory.
    pause
    exit /b 1
)

echo.
echo Building QuickTrace package...
swift build
if %errorlevel% neq 0 (
    echo Failed to build package. Please check for errors.
    pause
    exit /b 1
)

echo ✅ Package built successfully
echo.
echo This script will run all QuickTrace examples in sequence.
echo Each example demonstrates different features and capabilities.
echo.
echo Press Enter to start...
pause >nul

REM Run all examples
call :run_example "Basic Example" "BasicExample"
call :run_example "Advanced Example with Smart Filtering" "AdvancedExample"
call :run_example "Filtering Capabilities" "FilteringExample"
call :run_example "Output Styles Comparison" "StylesExample"
call :run_example "Runtime Control Features" "RuntimeControlExample"
call :run_example "Real-World HTTP API Simulation" "RealWorldExample"

echo.
echo 🎉 All examples completed!
echo.
echo What you've seen:
echo • Basic tracing with different output styles
echo • Smart filtering to focus on important operations
echo • Runtime control and configuration
echo • Real-world API server simulation
echo.
echo Next steps:
echo • Integrate QuickTrace into your Swift projects
echo • Customize filtering rules for your use case
echo • Use silent mode for production analytics
echo • Check the README.md for more advanced usage
echo.
echo Happy tracing! 🚀
pause

