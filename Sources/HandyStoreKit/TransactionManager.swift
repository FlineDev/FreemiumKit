import Foundation
import StoreKit

/// A manager that handles fetching, caching, and updating purchases from StoreKit.
public final class TransactionManager<U: Unlockable> {
   private var updates: Task<Void, Never>?

   private let onPurchase: (Transaction) -> Void
   private let onExpire: (Transaction) -> Void
   private let onRevoke: (Transaction) -> Void
   private let onUpgrade: (Transaction) -> Void

   /// The currently active purchased transactions.
   public var purchasedTransactions: Set<Transaction> = []

   /// The IDs of the currently active purchased products.
   public var purchasedProductIDs: Set<Product.ID> {
      Set(self.purchasedTransactions.map(\.productID))
   }

   /// The expired previously purchased transactions.
   public var expiredTransactions: Set<Transaction> = []

   /// The IDs of the expired previously purchased products.
   public var expiredProductIDs: Set<Product.ID> {
      Set(self.expiredTransactions.map(\.productID))
   }

   /// The revoked previously purchased transactions.
   public var revokedTransactions: Set<Transaction> = []

   /// The IDs of the revoked previously purchased products.
   public var revokedProductIDs: Set<Product.ID> {
      Set(self.revokedTransactions.map(\.productID))
   }

   /// The upgraded previously purchased transactions.
   public var upgradedTransactions: Set<Transaction> = []

   /// The IDs of the upgraded previously purchased products.
   public var upgradedProductIDs: Set<Product.ID> {
      Set(self.upgradedTransactions.map(\.productID))
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
   ) async {
      self.onPurchase = onPurchase
      self.onExpire = onExpire
      self.onRevoke = onRevoke
      self.onUpgrade = onUpgrade

      for await verificationResult in Transaction.currentEntitlements {
         self.handle(verificationResult: verificationResult)
      }

      Task(priority: .background) {
         for await verificationResult in Transaction.updates {
            self.handle(verificationResult: verificationResult)
         }
      }
   }

   /// Returns the users current permission for the provided unlockable feature.
   public func permission(for unlockable: U) -> Permission {
      unlockable.permission(purchasedProductIDs: self.purchasedProductIDs)
   }

   /// Returns `true` if the user has unlimited permission for the provided unlockable feature. Returns `false` if
   public func permissionIsUnlimited(for unlockable: U) -> Bool {
      unlockable.permission(purchasedProductIDs: self.purchasedProductIDs) == .unlimited
   }

   /// Returns the users current permission limit for the provided unlockable feature. Returns `0` for `denied` or `Int.max` for `unlimited`.
   public func permissionLimit(for unlockable: U) -> Int {
      switch unlockable.permission(purchasedProductIDs: self.purchasedProductIDs) {
      case .denied:
         return 0

      case .limited(let limit):
         return limit

      case .unlimited:
         return Int.max
      }
   }

   deinit {
      self.updates?.cancel()
   }

   private func handle(verificationResult: VerificationResult<Transaction>) {
      guard case .verified(let transaction) = verificationResult else { return }  // ignore unverified transactions

      if transaction.revocationDate != nil {
         self.revokedTransactions.insert(transaction)
         self.onRevoke(transaction)
      } else if let expirationDate = transaction.expirationDate, expirationDate < Date.now {
         self.expiredTransactions.insert(transaction)
         self.purchasedTransactions.remove(transaction)
         self.onExpire(transaction)
      } else if transaction.isUpgraded {
         self.upgradedTransactions.insert(transaction)
         self.purchasedTransactions.remove(transaction)
         self.onUpgrade(transaction)
      } else {
         self.purchasedTransactions.insert(transaction)
         self.onPurchase(transaction)
      }
   }
}
