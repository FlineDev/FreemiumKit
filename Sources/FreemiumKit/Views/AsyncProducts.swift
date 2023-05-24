import SwiftUI
import StoreKit

public struct AsyncProducts<ProductID: RawRepresentableProductID, Style: AsyncProductsStyle>: View {
   public enum PurchaseFailed {
      case storeKitError(StoreKitError)
      case purchaseError(Product.PurchaseError)
   }

   private let updateID: String = "AsyncProducts"

   private let style: Style
   private let productIDs: [ProductID]

   @ObservedObject
   private var inAppPurchase: InAppPurchase<ProductID>
   private let autoFinishPurchases: Bool

   private let onPurchase: (FKTransaction) -> Void
   private let onPurchaseFailed: (PurchaseFailed) -> Void
   private let onLoadFailed: (StoreKitError) -> Void

   @State
   private var products: [FKProduct] = []

   @State
   private var productIDsEligibleForIntroductoryOffer: Set<Product.ID> = []

   @State
   private var purchaseInProgressProduct: FKProduct?

   @State
   private var loadProducts: Bool = false

   @State
   private var loadingInProgress: Bool = false

   @State
   private var loadingProductsFailed: Bool = false

   public init(
      style: Style,
      productIDs: [ProductID],
      inAppPurchase: InAppPurchase<ProductID>,
      autoFinishPurchases: Bool = true,
      onPurchase: @escaping (FKTransaction) -> Void = { _ in },
      onPurchaseFailed: @escaping (PurchaseFailed) -> Void = { _ in },
      onLoadFailed: @escaping (StoreKitError) -> Void = { _ in }
   ) {
      self.style = style
      self.productIDs = productIDs
      self.inAppPurchase = inAppPurchase
      self.autoFinishPurchases = autoFinishPurchases

      self.onPurchase = onPurchase
      self.onPurchaseFailed = onPurchaseFailed
      self.onLoadFailed = onLoadFailed
   }

   public var body: some View {
      Group {
         if self.loadingInProgress {
            self.style.productsLoadingPlaceholder()
         } else if self.loadingProductsFailed {
            self.style.productsLoadFailed(
               reloadButtonTitle: Loc.FreemiumKit.LoadingProductsFailed.ReloadButtonTitle.string,
               loadFailedMessage: Loc.FreemiumKit.LoadingProductsFailed.Message.string
            ) {
               self.loadProducts.toggle()
            }
         } else {
            self.style.products(
               products: self.products,
               productIDsEligibleForIntroductoryOffer: self.productIDsEligibleForIntroductoryOffer,
               purchasedTransactions: self.inAppPurchase.purchasedTransactions,
               purchaseInProgressProduct: self.purchaseInProgressProduct,
               startPurchase: self.handlePurchase(product:options:)
            )
         }
      }
      .task(id: self.loadProducts) {
         do {
            self.loadingInProgress = true
            self.loadingProductsFailed = false

            self.products = try await FKProduct.products(for: self.productIDs.map(\.rawValue))

            self.productIDsEligibleForIntroductoryOffer = []
            for product in self.products {
               if product.subscription?.introductoryOffer != nil, await product.subscription!.isEligibleForIntroOffer {
                  self.productIDsEligibleForIntroductoryOffer.insert(product.id)
               }
            }

            self.loadingInProgress = false
            self.loadingProductsFailed = false
         } catch {
            self.loadingInProgress = false
            self.loadingProductsFailed = true

            guard let storeKitError = error as? StoreKitError else {
               assertionFailure("Unexpected Error: According to the docs of `Product.products(for:)` this can't happen.")
               return
            }

            self.onLoadFailed(storeKitError)
         }
      }
   }

   private func handlePurchase(product: FKProduct, options: Set<Product.PurchaseOption>) {
      Task {
         do {
            self.purchaseInProgressProduct = product
            let purchaseResult = try await product.purchase(options: options)
            self.purchaseInProgressProduct = nil

            switch purchaseResult {
            case .success(.verified(let transaction)):
               if self.autoFinishPurchases {
                  await transaction.finish()
               }

               self.inAppPurchase.handle(verificationResult: .verified(transaction))
               self.onPurchase(transaction)

            case .pending, .userCancelled, .success(.unverified):
               break

            @unknown default:
               print("warning: A new purchase result case was added but is not yet supported – please upgrade FreemiumKit or report this.")
               break
            }
         } catch {
            self.purchaseInProgressProduct = nil

            if let storeKitError = error as? StoreKitError {
               self.onPurchaseFailed(.storeKitError(storeKitError))
            } else if let purchaseError = error as? Product.PurchaseError {
               self.onPurchaseFailed(.purchaseError(purchaseError))
            } else {
               assertionFailure("Unexpected Error: According to the docs of `Product.purchase(options:)` this can't happen.")
               return
            }
         }
      }
   }
}

struct AsyncProductsView_Previews: PreviewProvider {
   private enum ProductID: String, RawRepresentableProductID {
      case pro
      case lite
   }

   static var previews: some View {
      AsyncProducts(style: PlainProductsStyle(), productIDs: ProductID.allCases, inAppPurchase: InAppPurchase<ProductID>())
   }
}

extension Product {
   var displayPricePerPeriodIfSubscription: String {
      guard let subscription else { return self.displayPrice }

      switch subscription.subscriptionPeriod.unit {
      case .day:
         return Loc.FreemiumKit.DisplayPriceIfSubscription.PerDay(displayPrice: self.displayPrice).string

      case .week:
         return Loc.FreemiumKit.DisplayPriceIfSubscription.PerWeek(displayPrice: self.displayPrice).string

      case .month:
         return Loc.FreemiumKit.DisplayPriceIfSubscription.PerMonth(displayPrice: self.displayPrice).string

      case .year:
         return Loc.FreemiumKit.DisplayPriceIfSubscription.PerYear(displayPrice: self.displayPrice).string

      @unknown default:
         return "\(self.displayPrice)/\(String(describing: subscription.subscriptionPeriod.unit).lowercased())"
      }
   }
}

extension Product.SubscriptionPeriod {
   var localizedFreeTrialDescription: String {
      switch self.unit {
      case .day:
         return Loc.FreemiumKit.SubscriptionPeriod.FreeTrialDays(count: self.value).string

      case .week:
         return Loc.FreemiumKit.SubscriptionPeriod.FreeTrialWeeks(count: self.value).string

      case .month:
         return Loc.FreemiumKit.SubscriptionPeriod.FreeTrialMonths(count: self.value).string

      case .year:
         return Loc.FreemiumKit.SubscriptionPeriod.FreeTrialYears(count: self.value).string

      @unknown default:
         return "\(self.value) \(String(describing: self.unit).lowercased())s free"
      }
   }
}

#if DEBUG
extension PreviewProduct {
   var displayPricePerPeriodIfSubscription: String {
      guard let subscription else { return self.displayPrice }

      switch subscription.subscriptionPeriod.unit {
      case .day:
         return Loc.FreemiumKit.DisplayPriceIfSubscription.PerDay(displayPrice: self.displayPrice).string

      case .week:
         return Loc.FreemiumKit.DisplayPriceIfSubscription.PerWeek(displayPrice: self.displayPrice).string

      case .month:
         return Loc.FreemiumKit.DisplayPriceIfSubscription.PerMonth(displayPrice: self.displayPrice).string

      case .year:
         return Loc.FreemiumKit.DisplayPriceIfSubscription.PerYear(displayPrice: self.displayPrice).string

      @unknown default:
         return "\(self.displayPrice)/\(String(describing: subscription.subscriptionPeriod.unit).lowercased())"
      }
   }
}

extension PreviewProduct.SubscriptionPeriod {
   var localizedFreeTrialDescription: String {
      switch self.unit {
      case .day:
         return Loc.FreemiumKit.SubscriptionPeriod.FreeTrialDays(count: self.value).string

      case .week:
         return Loc.FreemiumKit.SubscriptionPeriod.FreeTrialWeeks(count: self.value).string

      case .month:
         return Loc.FreemiumKit.SubscriptionPeriod.FreeTrialMonths(count: self.value).string

      case .year:
         return Loc.FreemiumKit.SubscriptionPeriod.FreeTrialYears(count: self.value).string

      @unknown default:
         return "\(self.value) \(String(describing: self.unit).lowercased())s free"
      }
   }
}
#endif
