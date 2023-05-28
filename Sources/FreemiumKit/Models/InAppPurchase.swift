import Foundation
import StoreKit
import IdentifiedCollections

/// A manager that handles fetching, caching, and updating purchases from StoreKit.
///
/// Here's a simplified example how permission checking works taken from the app "Twoot it!":
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
///       // ...
///    }
/// }
///
/// // on app start
/// let iap = InAppPurchase<ProductID>
///
/// // in SwiftUI
/// Button(...).disabled(iap.permission(for: LockedFeature.twitterPostsPerDay).isGranted(current: 1).isFalse)
/// Button(...).disabled(iap.permission(for: LockedFeature.extendedAttachments).isAlwaysDenied)
/// Button(...).disabled(iap.permission(for: LockedFeature.scheduledPosts).isAlwaysDenied)
/// ```
public final class InAppPurchase<ProductID: RawRepresentableProductID>: ObservableObject {
   /// The currently active purchased transactions with duplicate transactions for same ``productID`` removed.
   @Published
   public var purchasedTransactions: IdentifiedArray<String, FKTransaction> = .init(uniqueElements: [], id: \.productID)

   /// The IDs of the currently active purchased products wrapped in your ``RawRepresentableProductID`` product enum type.
   public var purchasedProductIDs: Set<ProductID> {
      Set(self.purchasedTransactions.map(\.productID).compactMap(ProductID.init(rawValue:)))
   }

   private var updates: Task<Void, Never>?

   /// Initializes a manager that automatically loads current purchases on init & subscribes to StoreKit changes to update itself automatically.
   @MainActor
   public init() {
      self.updates = Task(priority: .background) {
         for await verificationResult in FKTransaction.updates { self.handle(verificationResult: verificationResult) }
      }

      Task { await self.loadCurrentEntitlements() }
   }

   deinit { self.updates?.cancel() }

   /// Returns the users current permission for the provided unlockable feature.
   public func permission<LockedFeature: Unlockable>(for feature: LockedFeature) -> Permission where LockedFeature.ProductID == ProductID {
      feature.permission(purchasedProductIDs: self.purchasedProductIDs)
   }

   @MainActor
   func handle(verificationResult: VerificationResult<FKTransaction>) {
      guard case .verified(let transaction) = verificationResult else { return }  // ignore unverified transactions

      if transaction.revocationDate != nil {
         self.purchasedTransactions.remove(id: transaction.productID)
         Task { await self.loadCurrentEntitlements() }
      } else if let expirationDate = transaction.expirationDate, expirationDate < Date.now {
         self.purchasedTransactions.remove(id: transaction.productID)
         Task { await self.loadCurrentEntitlements() }
      } else if transaction.isUpgraded {
         self.purchasedTransactions.remove(id: transaction.productID)
      } else {
         self.purchasedTransactions[id: transaction.productID] = transaction
         self.purchasedTransactions.sort { $0.purchaseDate < $1.purchaseDate }
      }
   }

   @MainActor
   func loadCurrentEntitlements() async {
      if #available(iOS 16, *), Xcode.isRunningForPreviews {
         try? await Task.sleep(for: .seconds(1))
      } else {
         for await verificationResult in FKTransaction.currentEntitlements {
            self.handle(verificationResult: verificationResult)
         }
      }
   }
}

enum Xcode {
   static var isRunningForPreviews: Bool {
      ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
   }
}
