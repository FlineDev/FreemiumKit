import Foundation

/// Create an enum with a list of cases for all your different features that can be unlocked and conform it to this type.
///
/// Here's a real-world example taken from the app "Twoot it!":
/// ```
/// enum ProductID: String, CaseIterable, RawRepresentableProductID {
///    case proYearly = "dev.fline.TwootIt.Pro.Yearly"
///    case proMonthly = "dev.fline.TwootIt.Pro.Monthly"
///    case liteYearly = "dev.fline.TwootIt.Lite.Yearly"
///    case liteMonthly = "dev.fline.TwootIt.Lite.Monthly"
/// }
///
/// enum LockedFeature: Unlockable {
///    case twitterPostsPerDay
///    case extendedAttachments
///    case scheduledPosts
///
///    func permission(purchasedProductIDs: Set<ProductID>) -> Permission {
///       switch self {
///       case .twitterPostsPerDay:
///          return purchasedProductIDs.contains(where: \.rawValue, prefixedBy: "dev.fline.TwootIt.Pro") ? .limited(3) : .locked
///       case .extendedAttachments:
///          return purchasedProductIDs.isEmpty ? .locked : .unlimited
///       case .scheduledPosts:
///          return purchasedProductIDs.isEmpty ? .limited(1) : .unlimited
///       }
///    }
/// }
/// ```
public protocol Unlockable: Equatable, CaseIterable {
   associatedtype ProductID: RawRepresentableProductID

   func permission(purchasedProductIDs: Set<ProductID>) -> Permission
}
