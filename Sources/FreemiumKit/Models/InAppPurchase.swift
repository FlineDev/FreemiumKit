import Foundation
import StoreKit
import IdentifiedCollections

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
   public enum Change {
      case purchased
      case expired
      case revoked
      case upgraded
   }

   private var updates: Task<Void, Never>?

   private var purchaseObservers: [String: (Transaction) -> Void] = [:]
   private var expireObservers:  [String: (Transaction) -> Void] = [:]
   private var revokeObservers: [String: (Transaction) -> Void] = [:]
   private var upgradeObservers: [String: (Transaction) -> Void] = [:]

   /// The currently active purchased transactions with duplicate transactions for same ``productID`` removed.
   public var purchasedTransactions: IdentifiedArray<String, Transaction> = .init(uniqueElements: [], id: \.productID)

   /// The IDs of the currently active purchased products wrapped in your ``RawRepresentableProductID`` product enum type.
   public var purchasedProductIDs: Set<ProductID> {
      Set(self.purchasedTransactions.map(\.productID).compactMap(ProductID.init(rawValue:)))
   }

   /// The expired previously purchased transactions with duplicate transactions for same ``productID`` removed.
   public var expiredTransactions: IdentifiedArray<String, Transaction> = .init(uniqueElements: [], id: \.productID)

   /// The IDs of the expired previously purchased products wrapped in your ``RawRepresentableProductID`` product enum type.
   public var expiredProductIDs: Set<ProductID> {
      Set(self.expiredTransactions.map(\.productID).compactMap(ProductID.init(rawValue:)))
   }

   /// The revoked previously purchased transactions with duplicate transactions for same ``productID`` removed.
   public var revokedTransactions: IdentifiedArray<String, Transaction> = .init(uniqueElements: [], id: \.productID)

   /// The IDs of the revoked previously purchased products wrapped in your ``RawRepresentableProductID`` product enum type.
   public var revokedProductIDs: Set<ProductID> {
      Set(self.revokedTransactions.map(\.productID).compactMap(ProductID.init(rawValue:)))
   }

   /// The upgraded previously purchased transactions with duplicate transactions for same ``productID`` removed.
   public var upgradedTransactions: IdentifiedArray<String, Transaction> = .init(uniqueElements: [], id: \.productID)

   /// The IDs of the upgraded previously purchased products wrapped in your ``RawRepresentableProductID`` product enum type.
   public var upgradedProductIDs: Set<ProductID> {
      Set(self.upgradedTransactions.map(\.productID).compactMap(ProductID.init(rawValue:)))
   }

   /// Initializes a manager that automatically loads current purchases on init & subscribes to StoreKit changes to update itself automatically.
   public init() {
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

   public func observeChanges(id: String, onChange: @escaping (Transaction, Change) -> Void) {
      self.observePurchases(id: id, onPurchase: { onChange($0, .purchased) })
      self.observeExpires(id: id, onExpire: { onChange($0, .purchased) })
      self.observeRevokes(id: id, onRevoke: { onChange($0, .purchased) })
      self.observeUpgrades(id: id, onUpgrade: { onChange($0, .purchased) })
   }

   public func observePurchases(id: String, onPurchase: @escaping (Transaction) -> Void) {
      self.purchaseObservers[id] = onPurchase
   }

   public func observeExpires(id: String, onExpire: @escaping (Transaction) -> Void) {
      self.expireObservers[id] = onExpire
   }

   public func observeRevokes(id: String, onRevoke: @escaping (Transaction) -> Void) {
      self.revokeObservers[id] = onRevoke
   }

   public func observeUpgrades(id: String, onUpgrade: @escaping (Transaction) -> Void) {
      self.upgradeObservers[id] = onUpgrade
   }

   public func removeObserver(id: String) {
      self.purchaseObservers.removeValue(forKey: id)
      self.expireObservers.removeValue(forKey: id)
      self.revokeObservers.removeValue(forKey: id)
      self.upgradeObservers.removeValue(forKey: id)
   }

   func handle(verificationResult: VerificationResult<Transaction>) {
      guard case .verified(let transaction) = verificationResult else { return }  // ignore unverified transactions

      if transaction.revocationDate != nil {
         self.revokedTransactions[id: transaction.productID] = transaction
         self.revokedTransactions.sort { ($0.revocationDate ?? .distantPast) < ($1.revocationDate ?? .distantPast) }

         self.purchasedTransactions.remove(id: transaction.productID)
         self.revokeObservers.values.forEach { $0(transaction) }
      } else if let expirationDate = transaction.expirationDate, expirationDate < Date.now {
         self.expiredTransactions[id: transaction.productID] = transaction
         self.expiredTransactions.sort { ($0.expirationDate ?? .distantPast) < ($1.expirationDate ?? .distantPast) }

         self.purchasedTransactions.remove(id: transaction.productID)
         self.expireObservers.values.forEach { $0(transaction) }
      } else if transaction.isUpgraded {
         self.upgradedTransactions[id: transaction.productID] = transaction
         self.purchasedTransactions.remove(id: transaction.productID)
         self.upgradeObservers.values.forEach { $0(transaction) }
      } else {
         // remove any older subscriptions of the same subscription level
         if let newProductID = ProductID(rawValue: transaction.productID) {
            for oldProductID in self.purchasedProductIDs {
               if oldProductID.onSameSubscriptionLevel(as: newProductID) {
                  self.purchasedTransactions.remove(id: oldProductID.rawValue)
               }
            }
         }

         self.purchasedTransactions[id: transaction.productID] = transaction
         self.purchasedTransactions.sort { $0.purchaseDate < $1.purchaseDate }
         self.purchaseObservers.values.forEach { $0(transaction) }
      }
   }
}
