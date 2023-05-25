import Foundation

/// Create an enum with a list of cases for all your different features that can be unlocked and conform it to this type.
///
/// Here's a real-world example taken from the app "Twoot it!":
/// ```
/// enum ProductID: String, RawRepresentableProductID {
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
///          return purchasedProductIDs.containsAny(prefixedBy: "dev.fline.TwootIt.Pro") ? .limited(3) : .locked
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

extension Set where Element: RawRepresentable<String> {
   /// Returns a Boolean value indicating whether the set contains an element that begins with the specified prefix.
   public func containsAny(prefixedBy prefix: String) -> Bool {
      self.contains(where: \.rawValue, prefixedBy: prefix)
   }

   /// Returns a Boolean value indicating whether the set contains an element that begins with one of the specified prefixes.
   public func containsAny(prefixedByAnyOf prefixes: [String]) -> Bool {
      self.contains(where: \.rawValue, prefixedByOneOf: prefixes)
   }

   /// Returns a Boolean value indicating whether the set contains an element that contains the specified substring.
   public func containsAny(containing substring: String) -> Bool {
      self.contains(where: \.rawValue, contains: substring)
   }

   /// Returns a Boolean value indicating whether the set contains an element that contains one of the specified substrings.
   public func containsAny(containingAnyOf substrings: [String]) -> Bool {
      self.contains(where: \.rawValue, containsOneOf: substrings)
   }

   /// Returns a Boolean value indicating whether the set contains an element that ends with the specified suffix.
   public func containsAny(suffixedBy suffix: String) -> Bool {
      self.contains(where: \.rawValue, suffixedBy: suffix)
   }

   /// Returns a Boolean value indicating whether the set contains an element that ends with one of the specified suffixes.
   public func containsAny(suffixedByAnyOf suffixes: [String]) -> Bool {
      self.contains(where: \.rawValue, suffixedByOneOf: suffixes)
   }
}
