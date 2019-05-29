// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlackBot",
    products: [
        .executable(name: "SlackBot", targets: ["SlackBot"]),
        .library(name: "SlackBotKit", targets: ["SlackBotKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ChameleonBot/Chameleon.git", .upToNextMinor(from: "0.0.2")),
    ],
    targets: [
        .target(name: "SlackBot", dependencies: ["SlackBotKit"]),
        .target(name: "SlackBotKit", dependencies: ["Chameleon"]),
        .testTarget(name: "SlackBotKitTests", dependencies: ["SlackBotKit"]),
    ]
)
