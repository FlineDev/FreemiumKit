// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "FreemiumKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v12), .tvOS(.v16), .visionOS(.v1)],
    products: [.library(name: "FreemiumKit", targets: ["FreemiumKit"])],
    targets: [
      .target(name: "FreemiumKit", dependencies: ["FreemiumKitSDK"]),
      .binaryTarget(name: "FreemiumKitSDK", path: "FreemiumKitSDK.xcframework.zip"),
    ]
)
