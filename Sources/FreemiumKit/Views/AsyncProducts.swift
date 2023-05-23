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
               purchasedTransactions: self.inAppPurchase.purchasedTransactions,
               purchaseInProgressProduct: self.purchaseInProgressProduct
            ) { product, options in
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
      }
      .task(id: self.loadProducts) {
         do {
            self.loadingInProgress = true
            self.loadingProductsFailed = false

//             replace 'Product' with 'PreviewProduct' for SwiftUI previews during development
            self.products = try await PreviewProduct.products(for: self.productIDs.map(\.rawValue))

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
}

struct AsyncProductsView_Previews: PreviewProvider {
   enum ProductID: String, RawRepresentableProductID {
      case pro
      case lite

      var subscriptionLevel: Int? {
         switch self {
         case .pro: return 1
         case .lite: return 2
         }
      }
   }

   static var previews: some View {
      AsyncProducts(style: PlainProductsStyle(), productIDs: ProductID.allCases, inAppPurchase: InAppPurchase<ProductID>())
   }
}

extension Bundle {
   /// Returns a localized version of the string designated by the specified key and residing in the default table "Localizable".
   func localizedString(forKey key: String) -> String {
      self.localizedString(forKey: key, value: nil, table: "Localizable")
   }
}
