import Foundation

/// Create an enum with a list of products you've setup for your app on App Store Connect and provide the product IDs as raw values.
///
/// Here's a real-world example taken from the app "Twoot it!":
/// ```
/// enum ProductID: String, CaseIterable, RawRepresentableProductID {
///    case pro3Yearly = "dev.fline.TwootIt.Pro3.Yearly"
///    case pro2Yearly = "dev.fline.TwootIt.Pro2.Yearly"
///    case pro1Yearly = "dev.fline.TwootIt.Pro1.Yearly"
///    case liteYearly = "dev.fline.TwootIt.Lite.Yearly"
///    case pro3Monthly = "dev.fline.TwootIt.Pro3.Monthly"
///    case pro2Monthly = "dev.fline.TwootIt.Pro2.Monthly"
///    case pro1Monthly = "dev.fline.TwootIt.Pro1.Monthly"
///    case liteMonthly = "dev.fline.TwootIt.Lite.Monthly"
/// }
/// ```
public protocol RawRepresentableProductID: Hashable, RawRepresentable<String> {}
