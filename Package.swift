// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "FreemiumKit",
    platforms: [.iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v8)],
    products: [.library(name: "FreemiumKit", targets: ["FreemiumKit"])],
    dependencies: [],
    targets: [.target(name: "FreemiumKit", dependencies: [])]
)
