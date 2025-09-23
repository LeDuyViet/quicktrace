// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QuickTrace",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "QuickTrace",
            targets: ["QuickTrace"]),
        
        // Example executables
        .executable(name: "BasicExample", targets: ["BasicExample"]),
        .executable(name: "AdvancedExample", targets: ["AdvancedExample"]),
        .executable(name: "FilteringExample", targets: ["FilteringExample"]),
        .executable(name: "StylesExample", targets: ["StylesExample"]),
        .executable(name: "RuntimeControlExample", targets: ["RuntimeControlExample"]),
        .executable(name: "RealWorldExample", targets: ["RealWorldExample"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "QuickTrace",
            dependencies: []),
        .testTarget(
            name: "QuickTraceTests",
            dependencies: ["QuickTrace"]),
        
        // Example targets
        .executableTarget(
            name: "BasicExample",
            dependencies: ["QuickTrace"],
            path: "Examples/BasicExample"),
        .executableTarget(
            name: "AdvancedExample", 
            dependencies: ["QuickTrace"],
            path: "Examples/AdvancedExample"),
        .executableTarget(
            name: "FilteringExample",
            dependencies: ["QuickTrace"],
            path: "Examples/FilteringExample"),
        .executableTarget(
            name: "StylesExample",
            dependencies: ["QuickTrace"],
            path: "Examples/StylesExample"),
        .executableTarget(
            name: "RuntimeControlExample",
            dependencies: ["QuickTrace"],
            path: "Examples/RuntimeControlExample"),
        .executableTarget(
            name: "RealWorldExample",
            dependencies: ["QuickTrace"],
            path: "Examples/RealWorldExample"),
    ]
)

