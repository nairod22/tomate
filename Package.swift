// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Tomate",
    platforms: [.macOS(.v26)],
    targets: [
        // Timer state machine, scheduling, settings and formatting. No AppKit, fully testable.
        .target(
            name: "TomateCore",
            path: "Sources/TomateCore"
        ),
        // Menu bar app: status item, popover, overlay (AppKit + SwiftUI).
        .executableTarget(
            name: "Tomate",
            dependencies: ["TomateCore"],
            path: "Sources/Tomate"
        ),
        // Functional tests and wake-up budgets (Swift Testing, fake clock).
        .testTarget(
            name: "TomateCoreTests",
            dependencies: ["TomateCore"],
            path: "Tests/TomateCoreTests"
        ),
        // Rendering cost of the menu bar icon (XCTest measure).
        .testTarget(
            name: "TomatePerfTests",
            dependencies: ["Tomate", "TomateCore"],
            path: "Tests/TomatePerfTests"
        ),
    ]
)
