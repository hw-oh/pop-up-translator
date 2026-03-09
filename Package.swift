// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PopUpTranslator",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey", from: "0.2.1")
    ],
    targets: [
        .executableTarget(
            name: "PopUpTranslator",
            dependencies: ["HotKey"],
            path: "PopUpTranslator",
            exclude: ["Info.plist", "PopUpTranslator.entitlements", "Assets.xcassets"]
        )
    ]
)
