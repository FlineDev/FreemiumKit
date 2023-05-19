import Foundation

/// Create an enum with a list of products you've setup for your app on App Store Connect and provide the product IDs as raw values.
///
/// Here's a real-world example taken from the app "Twoot it!":
/// ```
/// enum ProductID: String, RawRepresentableProductID {
///    case pro3Yearly = "dev.fline.TwootIt.Pro3.Yearly"
///    case pro2Yearly = "dev.fline.TwootIt.Pro2.Yearly"
///    case pro1Yearly = "dev.fline.TwootIt.Pro1.Yearly"
///    case liteYearly = "dev.fline.TwootIt.Lite.Yearly"
///    case pro3Monthly = "dev.fline.TwootIt.Pro3.Monthly"
///    case pro2Monthly = "dev.fline.TwootIt.Pro2.Monthly"
///    case pro1Monthly = "dev.fline.TwootIt.Pro1.Monthly"
///    case liteMonthly = "dev.fline.TwootIt.Lite.Monthly"
///
///    var subscriptionLevel: Int? {
///       switch self {
///       case .pro3Yearly, .pro3Monthly: return 1
///       case .pro2Yearly, .pro2Monthly: return 2
///       case .pro1Yearly, .pro1Monthly: return 3
///       case .liteYearly, .liteMonthly: return 4
///       }
///    }
/// }
/// ```
public protocol RawRepresentableProductID: Hashable, CaseIterable, RawRepresentable<String> {
   /// A ranking system of subscriptions within a subscription group that determines the upgrade, downgrade, and crossgrade path available to subscribers. Level 1 offers most.
   /// See: https://developer.apple.com/help/app-store-connect/manage-subscriptions/offer-auto-renewable-subscriptions
   var subscriptionLevel: Int? { get }
}

extension RawRepresentableProductID {
   func onSameSubscriptionLevel(as other: Self) -> Bool {
      guard let ownLevel = self.subscriptionLevel, let otherLevel = other.subscriptionLevel else { return false }
      return ownLevel == otherLevel
   }
}
