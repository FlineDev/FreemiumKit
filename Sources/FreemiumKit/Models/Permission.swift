import Foundation

/// The level of permission that is given to the current user according to their purchases.
public enum Permission: Codable, Hashable, Sendable {
   /// The permission is locked.
   case locked
   /// The permission is granted for a limited count.
   case limited(Int)
   /// The permission is granted without any limits.
   case unlimited

   /// Returns the permission limit if set to ``limited``. Returns `0` if set to ``locked``. Returns ``Int.max`` if set to ``unlimited``.
   public var limit: Int {
      switch self {
      case .locked:
         return 0

      case .limited(let limit):
         return limit

      case .unlimited:
         return Int.max
      }
   }

   /// Returns `true` if the user has not reached their limit yet. Else, returns `false`. Always returns `false` for ``locked``, always returns `true` for ``unlimited``.
   public func isDenied(current: Int) -> Bool {
      switch self {
      case .locked:
         return false

      case .limited(let limit):
         return limit > current

      case .unlimited:
         return true
      }
   }

   /// Returns `true` if the user has not reached their limit yet. Else, returns `false`. Always returns `false` for ``locked``, always returns `true` for ``unlimited``.
   public func isGranted(current: Int) -> Bool {
      switch self {
      case .locked:
         return false

      case .limited(let limit):
         return limit > current

      case .unlimited:
         return true
      }
   }

   /// Returns `true` if the user has unlimited permission for the provided unlockable feature. Else, returns `false` (for both ``locked`` and ``limited``).
   public var isAlwaysGranted: Bool { self == .unlimited }

   /// Returns `true` if the user has no permission for the provided unlockable feature. Else, returns `false` (for both ``unlimited`` and ``limited``).
   public var isAlwaysDenied: Bool { self == .locked }
}
