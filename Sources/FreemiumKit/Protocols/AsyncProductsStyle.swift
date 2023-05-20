import SwiftUI
import StoreKit
import IdentifiedCollections

public protocol AsyncProductsStyle {
   associatedtype Placeholder: View
   associatedtype LoadFailed: View
   associatedtype Products: View

   func productsLoadingPlaceholder() -> Placeholder

   func productsLoadFailed(
      reloadButtonTitle: String,
      loadFailedMessage: String,
      reloadRequested: @escaping () -> Void
   ) -> LoadFailed

   func products(
      products: [Product],
      purchasedTransactions: IdentifiedArray<String, StoreKit.Transaction>,
      purchaseInProgressProduct: Product?,
      startPurchase: @escaping (Product, Set<Product.PurchaseOption>) -> Void
   ) -> Products
}
