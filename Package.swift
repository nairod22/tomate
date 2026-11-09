// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Tomate",
    platforms: [.macOS(.v26)],
    targets: [
        .executableTarget(
            name: "Tomate",
            path: "Sources/Tomate"
        )
    ]
)
