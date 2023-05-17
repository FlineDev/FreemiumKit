import Foundation

/// The level of permission that is given to the current user according to their purchases.
public enum Permission: Codable, Hashable, Sendable {
   /// The permission is denied.
   case denied
   /// The permission is granted for a limited count.
   case limited(Int)
   /// The permission is granted without any limits.
   case unlimited
}
