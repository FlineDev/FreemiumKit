import Foundation
import StoreKit

/// Create an enum with a list of cases for all your different features that can be unlocked and conform it to this type.
///
/// Here's a real-world example taken from the app "Twoot it!":
/// ```
/// enum LockedFeature: Unlockable {
///    case twitterPostsPerDay
///    case extendedAttachments
///    case scheduledPosts
///
///    func permission(purchasedProductIDs: Set<Product.ID>) -> Permission {
///       switch self {
///       case .twitterPostsPerDay:
///          if purchasedProductIDs.containsAny(prefixedBy: "dev.fline.TwootIt.Pro3") {
///             return .limited(3)
///          } else if purchasedProductIDs.containsAny(prefixedBy: "dev.fline.TwootIt.Pro2") }) {
///             return .limited(2)
///          } else if purchasedProductIDs.containsAny(prefixedBy: "dev.fline.TwootIt.Pro1") }) {
///             return .limited(1)
///          } else {
///             return .denied
///          }
///
///       case .extendedAttachments:
///          return purchasedProductIDs.containsAny(containingAnyOf: ["TwootIt.Pro", "TwootIt.Lite"]) ? .unlimited : .denied
///
///       case .scheduledPosts:
///          return purchasedProductIDs.isEmpty ? .limit(1) : .unlimited
///       }
///    }
/// }
/// ```
public protocol Unlockable: Equatable, CaseIterable {
   func permission(purchasedProductIDs: Set<Product.ID>) -> Permission
}

extension Set<Product.ID> {
   /// Returns a Boolean value indicating whether the set contains an element that begins with the specified prefix.
   public func containsAny(prefixedBy prefix: String) -> Bool {
      self.contains { $0.hasPrefix(prefix) }
   }

   /// Returns a Boolean value indicating whether the set contains an element that begins with one of the specified prefixes.
   public func containsAny(prefixedByAnyOf prefixes: [String]) -> Bool {
      prefixes.contains { prefix in self.contains { $0.hasPrefix(prefix) } }
   }

   /// Returns a Boolean value indicating whether the set contains an element that contains the specified substring.
   public func containsAny(containing substring: String) -> Bool {
      self.contains { $0.contains(substring) }
   }

   /// Returns a Boolean value indicating whether the set contains an element that contains one of the specified substrings.
   public func containsAny(containingAnyOf substrings: [String]) -> Bool {
      substrings.contains { substring in self.contains { $0.contains(substring) } }
   }

   /// Returns a Boolean value indicating whether the set contains an element that ends with the specified suffix.
   public func containsAny(suffixedBy suffix: String) -> Bool {
      self.contains { $0.hasSuffix(suffix) }
   }

   /// Returns a Boolean value indicating whether the set contains an element that ends with one of the specified suffixes.
   public func containsAny(suffixedByAnyOf suffixes: [String]) -> Bool {
      suffixes.contains { suffix in self.contains { $0.hasSuffix(suffix) } }
   }
}
