import StoreKit
import SwiftUI
import IdentifiedCollections

/// A very simple style using only plain SwiftUI types like ``Text``, ``Button``, or ``Label`` without fancy styling.
/// Don't use this directly – this is meant as a guide to help those who want to implement their custom ``AsyncProductsStyle`` styles.
public struct PlainProductsStyle: AsyncProductsStyle {
   public init() {}

   public func productsLoadingPlaceholder() -> some View {
      ProgressView()
         .padding()
   }

   public func productsLoadFailed(
      reloadButtonTitle: String,
      loadFailedMessage: String,
      reloadRequested: @escaping () -> Void
   ) -> some View {
      VStack(spacing: 15) {
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
         if let purchasedTransaction = purchasedTransactions[id: product.id] {
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

struct PlainProductsStyle_Previews: PreviewProvider {
   static var previews: some View {
      Group {
         PlainProductsStyle().productsLoadingPlaceholder()
            .previewDisplayName("Placeholder")

         PlainProductsStyle().productsLoadFailed(
            reloadButtonTitle: "Reload",
            loadFailedMessage: "Loading products failed.",
            reloadRequested: {}
         )
         .previewDisplayName("Load Failed")

         PlainProductsStyle().products(
            // comment this out and comment the line below it to get SwiftUI previews with fake data (also change typealiases in PreviewTypes.swift)
            products: try! PreviewProduct.products(for: ["A", "B", "C", "D"]),
//            products: [],
            purchasedTransactions: .init(uniqueElements: [], id: \.productID),
            purchaseInProgressProduct: nil,
            startPurchase: { _, _ in }
         )
         .previewDisplayName("Products")
      }
   }
}
