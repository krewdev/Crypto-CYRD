// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RelayVault",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "RelayVault",
            targets: ["RelayVault"]),
    ],
    dependencies: [
        // QR Code scanning
        .package(url: "https://github.com/twostraws/CodeScanner", from: "2.3.0"),
        // Networking
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.8.0"),
        // Keychain wrapper
        .package(url: "https://github.com/evgenyneu/keychain-swift", from: "20.0.0"),
        // Web3 Swift
        .package(url: "https://github.com/web3swift-team/web3swift", from: "3.0.0"),
        // Lottie for animations
        .package(url: "https://github.com/airbnb/lottie-ios", from: "4.3.0")
    ],
    targets: [
        .target(
            name: "RelayVault",
            dependencies: [
                "CodeScanner",
                "Alamofire",
                .product(name: "KeychainSwift", package: "keychain-swift"),
                "web3swift",
                .product(name: "Lottie", package: "lottie-ios")
            ]),
        .testTarget(
            name: "RelayVaultTests",
            dependencies: ["RelayVault"]),
    ]
)