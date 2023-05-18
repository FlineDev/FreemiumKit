import Foundation

/// The level of permission that is given to the current user according to their purchases.
public enum Permission: Codable, Hashable, Sendable {
   /// The permission is denied.
   case denied
   /// The permission is granted for a limited count.
   case limited(Int)
   /// The permission is granted without any limits.
   case unlimited

   /// Returns the permission limit if set to ``limited``. Returns `0` if set to ``denied``. Returns ``Int.max`` if set to ``unlimited``.
   public var limit: Int {
      switch self {
      case .denied:
         return 0

      case .limited(let limit):
         return limit

      case .unlimited:
         return Int.max
      }
   }

   /// Returns `true` if the user has not reached their limit yet. Else, returns `false`. Always returns `false` for ``denied``, always returns `true` for ``unlimited``.
   public func isGranted(current: Int) -> Bool {
      switch self {
      case .denied:
         return false

      case .limited(let limit):
         return limit > current

      case .unlimited:
         return true
      }
   }

   /// Returns `true` if the user has unlimited permission for the provided unlockable feature. Else, returns `false` (for both ``denied`` and ``limited``).
   public var isUnlimited: Bool { self == .unlimited }
}
