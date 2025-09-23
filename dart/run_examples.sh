#!/bin/bash

echo "🚀 QuickTrace Dart Examples Runner"
echo "=================================="

echo ""
echo "Installing dependencies..."
dart pub get

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies. Make sure Dart is installed and in PATH."
    exit 1
fi

echo ""
echo "✅ Dependencies installed successfully!"
echo ""

while true; do
    echo "Choose an example to run:"
    echo "1. Demo (comprehensive showcase)"
    echo "2. Basic Example"
    echo "3. Styles Example (all 6 styles)"
    echo "4. Filtering Example (smart filtering)"
    echo "5. Runtime Control Example"
    echo "6. Real World Example (API simulation)"
    echo "7. Advanced Example"
    echo "8. Run All Examples"
    echo "9. Exit"
    
    read -p "Enter your choice (1-9): " choice
    
    case $choice in
        1)
            echo ""
            echo "Running Demo..."
            dart run example/demo.dart
            ;;
        2)
            echo ""
            echo "Running Basic Example..."
            dart run example/basic_example.dart
            ;;
        3)
            echo ""
            echo "Running Styles Example..."
            dart run example/styles_example.dart
            ;;
        4)
            echo ""
            echo "Running Filtering Example..."
            dart run example/filtering_example.dart
            ;;
        5)
            echo ""
            echo "Running Runtime Control Example..."
            dart run example/runtime_control_example.dart
            ;;
        6)
            echo ""
            echo "Running Real World Example..."
            dart run example/real_world_example.dart
            ;;
        7)
            echo ""
            echo "Running Advanced Example..."
            dart run example/advanced_example.dart
            ;;
        8)
            echo ""
            echo "Running All Examples..."
            echo ""
            echo "=== Demo ==="
            dart run example/demo.dart
            echo ""
            echo "=== Basic ==="
            dart run example/basic_example.dart
            echo ""
            echo "=== Styles ==="
            dart run example/styles_example.dart
            echo ""
            echo "=== Filtering ==="
            dart run example/filtering_example.dart
            echo ""
            echo "=== Runtime Control ==="
            dart run example/runtime_control_example.dart
            echo ""
            echo "=== Advanced ==="
            dart run example/advanced_example.dart
            echo ""
            echo "=== Real World ==="
            dart run example/real_world_example.dart
            echo ""
            echo "✅ All examples completed!"
            ;;
        9)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
    echo ""
done
