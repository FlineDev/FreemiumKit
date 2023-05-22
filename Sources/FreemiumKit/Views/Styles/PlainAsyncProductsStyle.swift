import StoreKit
import SwiftUI
import IdentifiedCollections

/// A very simple style using only plain SwiftUI types like ``Text``, ``Button``, or ``Label`` without fancy styling.
/// Don't use this directly – this is meant as a guide to help those who want to implement their custom ``AsyncProductsStyle`` styles.
public struct PlainAsyncProductsStyle: AsyncProductsStyle {
   private let verticalSpacing: CGFloat

   public init(verticalSpacing: CGFloat = 15) {
      self.verticalSpacing = verticalSpacing
   }

   public func productsLoadingPlaceholder() -> some View {
      ProgressView()
         .padding()
   }

   public func productsLoadFailed(
      reloadButtonTitle: String,
      loadFailedMessage: String,
      reloadRequested: @escaping () -> Void
   ) -> some View {
      VStack(spacing: self.verticalSpacing) {
         Text(loadFailedMessage)
         Button(reloadButtonTitle) { reloadRequested() }
      }
      .padding()
   }

   public func products(
      products: [FKProduct],
      purchasedTransactions: IdentifiedArray<String, FKTransaction>,
      purchaseInProgressProduct: FKProduct?,
      startPurchase: @escaping (FKProduct, Set<Product.PurchaseOption>) -> Void
   ) -> some View {
      List(products) { product in
         if let purchasedTransaction = purchasedTransactions[id: product.id], purchasedTransaction.purchaseDate > .now {
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
            // comment this out and comment the line below it to get SwiftUI previews with fake data (also change typealiases in PreviewTypes.swift)
//            products: try! PreviewProduct.products(for: ["A", "B", "C", "D"]),
            products: [],
            purchasedTransactions: .init(uniqueElements: [], id: \.productID),
            purchaseInProgressProduct: nil,
            startPurchase: { _, _ in }
         )
         .previewDisplayName("Products")
      }
   }
}
