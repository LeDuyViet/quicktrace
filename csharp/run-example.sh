#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: ./run-example.sh <example_name>"
    echo "Available examples: basic, advanced, styles, filtering, runtime, realworld, all"
    exit 1
fi

cd Examples
dotnet run "$1"
cd ..
