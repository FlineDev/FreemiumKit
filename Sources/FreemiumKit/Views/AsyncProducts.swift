import SwiftUI
import StoreKit

//public enum PlaceholderType {
//   case plaloadInProgressView
//   Loadcase custom
//}
//
//public enum InProgressType {
//   case
//}

public struct AsyncProducts<
   ProductID: RawRepresentableProductID,
   Products: ProductsView,
   Placeholder: PlaceholderView,
   LoadFailed: LoadFailedView
>: View {
   public enum PurchaseFailed {
      case storeKitError(StoreKitError)
      case purchaseError(Product.PurchaseError)
   }

   private let productIDs: [ProductID]
   private let purchasedTransactions: Set<StoreKit.Transaction>
   private let automaticallyFinishTransactions: Bool

   private let onPurchase: (StoreKit.Transaction) -> Void
   private let onPurchaseFailed: (PurchaseFailed) -> Void
   private let onLoadFailed: (StoreKitError) -> Void

   @State
   private var newPurchases: Set<StoreKit.Transaction> = []

   @State
   private var products: [Product] = []

   @State
   private var purchaseInProgressProduct: Product?

   @State
   private var loadProducts: Bool = false

   @State
   private var loadingInProgress: Bool = false

   @State
   private var loadingProductsFailed: Bool = false

   public init(
      productIDs: [ProductID],
      purchasedTransactions: Set<StoreKit.Transaction>,
      automaticallyFinishTransactions: Bool = true,
      onPurchase: @escaping (StoreKit.Transaction) -> Void = { _ in },
      onPurchaseFailed: @escaping (PurchaseFailed) -> Void = { _ in },
      onLoadFailed: @escaping (StoreKitError) -> Void = { _ in },
      productsType: Products.Type,
      placeholderType: Placeholder.Type,
      loadFailedType: LoadFailed.Type
   ) {
      self.productIDs = productIDs
      self.purchasedTransactions = purchasedTransactions
      self.automaticallyFinishTransactions = automaticallyFinishTransactions

      self.onPurchase = onPurchase
      self.onPurchaseFailed = onPurchaseFailed
      self.onLoadFailed = onLoadFailed
   }

   public var body: some View {
      Group {
         if self.loadingInProgress {
            Placeholder()
         } else if self.loadingProductsFailed {
            #warning("🧑‍💻 localize texts")
            LoadFailed(reloadButtonTitle: "Reload", loadFailedMessage: "Failed to load products from App Store.") {
               self.loadProducts.toggle()
            }
         } else {
            Products(
               products: self.products,
               purchasedTransactions: self.purchasedTransactions.union(self.newPurchases),
               purchaseInProgressProduct: self.purchaseInProgressProduct
            ) { product, options in
               Task {
                  do {
                     self.purchaseInProgressProduct = product
                     let purchaseResult = try await product.purchase(options: options)
                     self.purchaseInProgressProduct = nil

                     switch purchaseResult {
                     case .success(.verified(let transaction)):
                        if self.automaticallyFinishTransactions { await transaction.finish() }

                        self.newPurchases.insert(transaction)
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

            self.products = try await Product.products(for: self.productIDs.map(\.rawValue))

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
   }

   static var previews: some View {
      AsyncProducts(productIDs: ProductID.allCases, purchasedTransactions: [], productsType: <#T##ProductsView.Protocol#>, placeholderType: <#T##PlaceholderView.Protocol#>, loadFailedType: <#T##LoadFailedView.Protocol#>)
   }
}
