@echo off
REM QuickTrace Java Build Script for Windows

echo 🚀 Building QuickTrace Java...

REM Check if Maven is installed
where mvn >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Maven is not installed. Please install Maven first.
    exit /b 1
)

REM Clean and compile
echo 🧹 Cleaning previous builds...
call mvn clean

echo 🔨 Compiling sources...
call mvn compile

REM Run tests
echo 🧪 Running tests...
call mvn test

REM Package
echo 📦 Packaging JAR...
call mvn package

REM Run examples
echo 🎯 Running examples...

echo.
echo 📝 Basic Example:
call mvn exec:java -Dexec.mainClass="com.leduy.quicktrace.examples.BasicExample" -q

echo.
echo ✅ Build completed successfully!
echo 💡 You can run individual examples with:
echo    mvn exec:java -Dexec.mainClass="com.leduy.quicktrace.examples.BasicExample"
echo    mvn exec:java -Dexec.mainClass="com.leduy.quicktrace.examples.AdvancedExample"
echo    mvn exec:java -Dexec.mainClass="com.leduy.quicktrace.examples.StylesExample"
echo    mvn exec:java -Dexec.mainClass="com.leduy.quicktrace.examples.FilteringExample"
echo    mvn exec:java -Dexec.mainClass="com.leduy.quicktrace.examples.RuntimeControlExample"
echo.
echo 📋 Generated JAR: target\quicktrace-1.0.0.jar

pause
