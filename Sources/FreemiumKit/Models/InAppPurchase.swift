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
   public enum Failure: LocalizedError, Identifiable {
      case productFetchFailedWithNoMatches(productID: String)

      public var errorDescription: String? {
         switch self {
         case .productFetchFailedWithNoMatches(let productID):
            return Loc.FreemiumKit.InAppPurchase.ProductFetchNoMatches(productID: productID).string
         }
      }

      public var id: String {
         switch self {
         case .productFetchFailedWithNoMatches: return "P"
         }
      }
   }

   /// The currently active purchased transactions with duplicate transactions for same ``productID`` removed.
   @Published
   public var purchasedTransactions: IdentifiedArray<String, FKTransaction> = .init(uniqueElements: [], id: \.productID)

   /// The IDs of the currently active purchased products wrapped in your ``RawRepresentableProductID`` product enum type.
   public var purchasedProductIDs: Set<ProductID> {
      Set(self.purchasedTransactions.map(\.productID).compactMap(ProductID.init(rawValue:)))
   }

   /// A `UUID` passed to StoreKit on purchasing to recognize same paying user even after app reinstalls for more reliable usage limits in permission checking.
   /// Make sure to store this `UUID` on your server when a user purchased a product and track usage server-side and fetch the current usage on app start for reliable limits.
   /// - NOTE: Do not change this value after a purchase has been made. If you want to provide a custom value here, make sure to set it before any purchase is made, e.g. on app start.
   public var appAccountToken: UUID = UUID()

   private var productsCache: IdentifiedArrayOf<FKProduct> = []

   private var updates: Task<Void, Never>?

   /// Initializes a manager that automatically loads current purchases on init & subscribes to StoreKit changes to update itself automatically.
   @MainActor
   public init() {
      self.updates = Task(priority: .background) {
         for await verificationResult in FKTransaction.updates { self.handle(verificationResult: verificationResult) }
      }
   }

   deinit { self.updates?.cancel() }

   /// Call this when your app has launched, e.g. in `application(_:willFinishLaunchingWithOptions:)`.
   public func appLaunched() {
      Task { await self.loadCurrentEntitlements() }
   }

   /// Returns the users current permission for the provided unlockable feature.
   public func permission<LockedFeature: Unlockable>(for feature: LockedFeature) -> Permission where LockedFeature.ProductID == ProductID {
      feature.permission(purchasedProductIDs: self.purchasedProductIDs)
   }

   /// Requests product data from the App Store or from the internal cache and returns it.
   /// - Throws: Either a ``StoreKitError`` if fetching fails, or ``InAppPurchase.Failure.receivedProductsAreEmpty`` if the App Store response was empty.
   public func product(productID: ProductID) async throws -> FKProduct {
      if let product = self.productsCache[id: productID.rawValue] {
         return product
      } else {
         guard let product = try await FKProduct.products(for: [productID.rawValue]).first else {
            throw Failure.productFetchFailedWithNoMatches(productID: productID.rawValue)
         }

         self.cacheProducts([product])
         return product
      }
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

         if let appAccountToken = transaction.appAccountToken {
            self.appAccountToken = appAccountToken
         }
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

   func cacheProducts(_ products: [FKProduct]) {
      for product in products {
         self.productsCache[id: product.id] = product
      }
   }
}

enum Xcode {
   static var isRunningForPreviews: Bool {
      ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
   }
}
