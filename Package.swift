// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "FreemiumKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v8)],
    products: [.library(name: "FreemiumKit", targets: ["FreemiumKit"])],
    dependencies: [
      .package(url: "https://github.com/pointfreeco/swift-identified-collections.git", from: "0.7.1"),
    ],
    targets: [.target(
      name: "FreemiumKit",
      dependencies: [
         .product(name: "IdentifiedCollections", package: "swift-identified-collections")
      ],
      resources: [.process("Resources")]
    )]
)
