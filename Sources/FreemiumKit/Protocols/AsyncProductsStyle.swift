import SwiftUI

public protocol AsyncProductsStyle {
   associatedtype Placeholder: View
   associatedtype LoadFailed: View
   associatedtype Products: View

   func productsLoadingPlaceholder() -> Placeholder

   func productsLoadFailed(
      reloadButtonTitle: LocalizedStringKey,
      loadFailedMessage: LocalizedStringKey,
      reloadRequested: @escaping () -> Void
   ) -> LoadFailed

   func products(
      products: [Product],
      purchasedTransactions: Set<StoreKit.Transaction>,
      purchaseInProgressProduct: Product?,
      startPurchase: (Product, Set<Product.PurchaseOption>) -> Void
   ) -> Products
}
