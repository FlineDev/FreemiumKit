import Foundation
import StoreKit

/// A manager that handles fetching, caching, and updating purchases from StoreKit.
///
/// Here's a simplified example taken from the app "Twoot it!":
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
///       // ...
///    }
/// }
///
/// // on app start
/// let iap = InAppPurchase<ProductID, LockedFeature>
///
/// // in SwiftUI
/// Button(...).disabled(iap.permission(for: .twitterPostsPerDay).isGranted(current: 1).isFalse)
/// Button(...).disabled(iap.permission(for: .extendedAttachments).isAlwaysDenied)
/// Button(...).disabled(iap.permission(for: .scheduledPosts).isAlwaysDenied)
/// ```
public final class InAppPurchase<ProductID: RawRepresentableProductID> {
   public enum Update {
      case purchased
      case expired
      case revoked
      case upgraded
   }

   private var updates: Task<Void, Never>?

   private let onPurchase: (Transaction) -> Void
   private let onExpire: (Transaction) -> Void
   private let onRevoke: (Transaction) -> Void
   private let onUpgrade: (Transaction) -> Void

   private var updateSubscribers: [String: (Transaction, Update) -> Void] = [:]

   /// The currently active purchased transactions.
   public var purchasedTransactions: Set<Transaction> = []

   /// The IDs of the currently active purchased products wrapped in your ``RawRepresentableProductID`` product enum type.
   public var purchasedProductIDs: Set<ProductID> {
      Set(self.purchasedTransactions.map(\.productID).compactMap(ProductID.init(rawValue:)))
   }

   /// The expired previously purchased transactions.
   public var expiredTransactions: Set<Transaction> = []

   /// The IDs of the expired previously purchased products wrapped in your ``RawRepresentableProductID`` product enum type.
   public var expiredProductIDs: Set<ProductID> {
      Set(self.expiredTransactions.map(\.productID).compactMap(ProductID.init(rawValue:)))
   }

   /// The revoked previously purchased transactions.
   public var revokedTransactions: Set<Transaction> = []

   /// The IDs of the revoked previously purchased products wrapped in your ``RawRepresentableProductID`` product enum type.
   public var revokedProductIDs: Set<ProductID> {
      Set(self.revokedTransactions.map(\.productID).compactMap(ProductID.init(rawValue:)))
   }

   /// The upgraded previously purchased transactions.
   public var upgradedTransactions: Set<Transaction> = []

   /// The IDs of the upgraded previously purchased products wrapped in your ``RawRepresentableProductID`` product enum type.
   public var upgradedProductIDs: Set<ProductID> {
      Set(self.upgradedTransactions.map(\.productID).compactMap(ProductID.init(rawValue:)))
   }

   /// Initializes a manager that automatically loads current purchases on init & subscribes to StoreKit changes to update itself automatically.
   /// - Parameters:
   ///   - onPurchase: Invoked for new successful transactions. ``TransactionManager`` handles updating permissions automatically, but you can attach custom logic.
   ///   - onExpire: Invoked for transactions that expired. ``TransactionManager`` handles updating permissions automatically, but you can attach custom logic.
   ///   - onRevoke: Invoked for transactions that got revoked. ``TransactionManager`` handles updating permissions automatically, but you can attach custom logic.
   ///   - onUpgrade: Invoked for transactions that got upgraded. ``TransactionManager`` handles updating permissions automatically, but you can attach custom logic.
   public init(
      onPurchase: @escaping (Transaction) -> Void = { _ in },
      onExpire: @escaping (Transaction) -> Void = { _ in },
      onRevoke: @escaping (Transaction) -> Void = { _ in },
      onUpgrade: @escaping (Transaction) -> Void = { _ in }
   ) {
      self.onPurchase = onPurchase
      self.onExpire = onExpire
      self.onRevoke = onRevoke
      self.onUpgrade = onUpgrade

      self.updates = Task(priority: .background) {
         for await verificationResult in Transaction.updates {
            self.handle(verificationResult: verificationResult)
         }
      }

      Task {
         for await verificationResult in Transaction.currentEntitlements {
            self.handle(verificationResult: verificationResult)
         }
      }
   }

   /// Returns the users current permission for the provided unlockable feature.
   public func permission<LockedFeature: Unlockable>(for feature: LockedFeature) -> Permission where LockedFeature.ProductID == ProductID {
      feature.permission(purchasedProductIDs: self.purchasedProductIDs)
   }

   deinit {
      self.updates?.cancel()
   }

   public func subscribeToUpdates(id: String, onUpdate: @escaping (Transaction, Update) -> Void) {
      self.updateSubscribers[id] = onUpdate
   }

   public func unsubscribeFromUpdates(id: String) {
      self.updateSubscribers.removeValue(forKey: id)
   }

   private func handle(verificationResult: VerificationResult<Transaction>) {
      guard case .verified(let transaction) = verificationResult else { return }  // ignore unverified transactions

      if transaction.revocationDate != nil {
         self.revokedTransactions.insert(transaction)
         self.onRevoke(transaction)
         self.updateSubscribers.values.forEach { $0(transaction, .revoked) }
      } else if let expirationDate = transaction.expirationDate, expirationDate < Date.now {
         self.expiredTransactions.insert(transaction)
         self.purchasedTransactions.remove(transaction)
         self.onExpire(transaction)
         self.updateSubscribers.values.forEach { $0(transaction, .expired) }
      } else if transaction.isUpgraded {
         self.upgradedTransactions.insert(transaction)
         self.purchasedTransactions.remove(transaction)
         self.onUpgrade(transaction)
         self.updateSubscribers.values.forEach { $0(transaction, .upgraded) }
      } else {
         self.purchasedTransactions.insert(transaction)
         self.onPurchase(transaction)
         self.updateSubscribers.values.forEach { $0(transaction, .purchased) }
      }
   }
}
