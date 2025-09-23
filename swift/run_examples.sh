#!/bin/bash

# QuickTrace Swift Examples Runner
# This script runs all examples in sequence with pauses between them

echo "🚀 QuickTrace for Swift - Examples Runner"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to run an example with colored output
run_example() {
    local name=$1
    local target=$2
    
    echo ""
    echo -e "${BLUE}=================== $name ===================${NC}"
    echo ""
    
    if swift run $target; then
        echo -e "${GREEN}✅ $name completed successfully${NC}"
    else
        echo -e "${RED}❌ $name failed${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${YELLOW}Press Enter to continue to next example...${NC}"
    read
}

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    echo -e "${RED}Error: Package.swift not found. Please run this script from the swift/ directory.${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}Building QuickTrace package...${NC}"
if ! swift build; then
    echo -e "${RED}Failed to build package. Please check for errors.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Package built successfully${NC}"
echo ""
echo "This script will run all QuickTrace examples in sequence."
echo "Each example demonstrates different features and capabilities."
echo ""
echo -e "${YELLOW}Press Enter to start...${NC}"
read

# Run all examples
run_example "Basic Example" "BasicExample"
run_example "Advanced Example with Smart Filtering" "AdvancedExample"
run_example "Filtering Capabilities" "FilteringExample"
run_example "Output Styles Comparison" "StylesExample"
run_example "Runtime Control Features" "RuntimeControlExample"
run_example "Real-World HTTP API Simulation" "RealWorldExample"

echo ""
echo -e "${PURPLE}🎉 All examples completed!${NC}"
echo ""
echo "What you've seen:"
echo "• Basic tracing with different output styles"
echo "• Smart filtering to focus on important operations"
echo "• Runtime control and configuration"
echo "• Real-world API server simulation"
echo ""
echo "Next steps:"
echo "• Integrate QuickTrace into your Swift projects"
echo "• Customize filtering rules for your use case"
echo "• Use silent mode for production analytics"
echo "• Check the README.md for more advanced usage"
echo ""
echo -e "${GREEN}Happy tracing! 🚀${NC}"

