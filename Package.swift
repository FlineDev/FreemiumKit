// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "FreemiumKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v12), .tvOS(.v15), .visionOS(.v1)],
    products: [.library(name: "FreemiumKit", targets: ["FreemiumKit"])],
    dependencies: [.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")],
    targets: [
      .target(name: "FreemiumKit", dependencies: ["FreemiumKitSDK"]),
      .binaryTarget(name: "FreemiumKitSDK", path: "FreemiumKitSDK.xcframework.zip"),
    ]
)
