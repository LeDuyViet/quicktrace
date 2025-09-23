#!/bin/bash

# QuickTrace Java Build Script

echo "🚀 Building QuickTrace Java..."

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven is not installed. Please install Maven first."
    exit 1
fi

# Clean and compile
echo "🧹 Cleaning previous builds..."
mvn clean

echo "🔨 Compiling sources..."
mvn compile

# Run tests
echo "🧪 Running tests..."
mvn test

# Package
echo "📦 Packaging JAR..."
mvn package

# Run examples
echo "🎯 Running examples..."

echo ""
echo "📝 Basic Example:"
mvn exec:java -Dexec.mainClass="com.leduy.quicktrace.examples.BasicExample" -q

echo ""
echo "🎨 Styles Example (first few styles):"
timeout 10s mvn exec:java -Dexec.mainClass="com.leduy.quicktrace.examples.StylesExample" -q || true

echo ""
echo "✅ Build completed successfully!"
echo "💡 You can run individual examples with:"
echo "   mvn exec:java -Dexec.mainClass=\"com.leduy.quicktrace.examples.BasicExample\""
echo "   mvn exec:java -Dexec.mainClass=\"com.leduy.quicktrace.examples.AdvancedExample\""
echo "   mvn exec:java -Dexec.mainClass=\"com.leduy.quicktrace.examples.StylesExample\""
echo "   mvn exec:java -Dexec.mainClass=\"com.leduy.quicktrace.examples.FilteringExample\""
echo "   mvn exec:java -Dexec.mainClass=\"com.leduy.quicktrace.examples.RuntimeControlExample\""
echo ""
echo "📋 Generated JAR: target/quicktrace-1.0.0.jar"
