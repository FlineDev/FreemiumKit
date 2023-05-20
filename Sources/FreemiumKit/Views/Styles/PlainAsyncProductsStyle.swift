import StoreKit
import SwiftUI

/// A very simple style using only plain SwiftUI types like ``Text``, ``Button``, or ``Label`` without fancy styling.
/// Don't use this directly – this is meant as a guide to help those who want to implement their custom ``AsyncProductsStyle`` styles.
public struct PlainAsyncProductsStyle: AsyncProductsStyle {
   private let verticalSpacing: CGFloat

   public init(verticalSpacing: CGFloat = 15) {
      self.verticalSpacing = verticalSpacing
   }

   public func productsLoadingPlaceholder() -> some View {
      ProgressView()
   }

   public func productsLoadFailed(
      reloadButtonTitle: LocalizedStringKey,
      loadFailedMessage: LocalizedStringKey,
      reloadRequested: @escaping () -> Void
   ) -> some View {
      VStack(spacing: self.verticalSpacing) {
         Text(loadFailedMessage)
         Button(reloadButtonTitle) { reloadRequested() }
      }
   }

   public func products(
      products: [Product],
      purchasedTransactions: [StoreKit.Transaction],
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

         PlainAsyncProductsStyle(verticalSpacing: 20).productsLoadFailed(
            reloadButtonTitle: "Reload",
            loadFailedMessage: "Loading products failed.",
            reloadRequested: {}
         )
         .previewDisplayName("Load Failed")

         PlainAsyncProductsStyle(verticalSpacing: 25).products(
            products: [],
            purchasedTransactions: [],
            purchaseInProgressProduct: nil,
            startPurchase: { _, _ in }
         )
         .previewDisplayName("Products")
      }
   }
}
