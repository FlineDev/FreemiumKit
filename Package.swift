// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "HandyStoreKit",
    platforms: [.iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v8)],
    products: [.library(name: "HandyStoreKit", targets: ["HandyStoreKit"])],
    dependencies: [],
    targets: [.target(name: "HandyStoreKit", dependencies: [])]
)
