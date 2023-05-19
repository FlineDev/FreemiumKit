import StoreKit
import SwiftUI

public struct PlainAsyncProductsStyle: AsyncProductsStyle {
   public init() {}

   public func productsLoadingPlaceholder() -> some View {
      ProgressView()
   }

   public func productsLoadFailed(
      reloadButtonTitle: LocalizedStringKey,
      loadFailedMessage: LocalizedStringKey,
      reloadRequested: @escaping () -> Void
   ) -> some View {
      VStack(spacing: 15) {
         Text(loadFailedMessage)
         Button(reloadButtonTitle) { reloadRequested() }
      }
   }

   public func products(
      products: [Product],
      purchasedTransactions: Set<StoreKit.Transaction>,
      purchaseInProgressProduct: Product?,
      startPurchase: @escaping (Product, Set<Product.PurchaseOption>) -> Void
   ) -> some View {
      List(products) { product in
         if purchasedTransactions.map(\.productID).contains(product.id) {
            Label(product.displayName, systemImage: "checkmark")
         } else {
            Button(product.displayName) { startPurchase(product, []) }
         }
      }
      .overlay {
         if purchaseInProgressProduct != nil {
            ProgressView()
         }
      }
   }
}

struct PlainAsyncProductsStyle_Previews: PreviewProvider {
   static var previews: some View {
      Group {
         PlainAsyncProductsStyle().productsLoadingPlaceholder()
            .previewDisplayName("Placeholder")

         PlainAsyncProductsStyle().productsLoadFailed(reloadButtonTitle: "Reload", loadFailedMessage: "Loading products failed.", reloadRequested: {})
            .previewDisplayName("Load Failed")

         PlainAsyncProductsStyle().products(
            products: [],
            purchasedTransactions: [],
            purchaseInProgressProduct: nil,
            startPurchase: { _, _ in }
         )
         .previewDisplayName("Products")
      }
   }
}
