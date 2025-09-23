@echo off
if "%1"=="" (
    echo Usage: run-example.cmd ^<example_name^>
    echo Available examples: basic, advanced, styles, filtering, runtime, realworld, all
    exit /b 1
)

cd Examples
dotnet run %1
cd ..
