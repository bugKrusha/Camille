// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "SlackBot",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "SlackBot", targets: ["SlackBot"]),
        .library(name: "SlackBotKit", targets: ["SlackBotKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ChameleonBot/Chameleon.git", .branch("revamp")),
        .package(url: "https://github.com/mxcl/LegibleError.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "SlackBot", dependencies: [
            "SlackBotKit",
            .product(name: "VaporProviders", package: "Chameleon"),
            .product(name: "LegibleError", package: "LegibleError"),
        ]),
        .target(name: "SlackBotKit", dependencies: [.product(name: "ChameleonKit", package: "Chameleon")]),
        .testTarget(name: "SlackBotKitTests", dependencies: ["SlackBotKit"]),
    ]
)
