import StoreKit
import SwiftUI
import IdentifiedCollections

/// The horizontal "Paywall Blueprint" style implementing learnings from analyzing 20 different successful paywalls.
/// If you have more than 3 products, consider using ``VerticalProductsStyle`` instead. It also scales better for longer (localized) product names.
public struct HorizontalProductsStyle: AsyncProductsStyle {
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

struct HorizontalProductsStyle_Previews: PreviewProvider {
   static var previews: some View {
      Group {
         HorizontalProductsStyle().productsLoadingPlaceholder()
            .previewDisplayName("Placeholder")

         HorizontalProductsStyle(verticalSpacing: 20).productsLoadFailed(
            reloadButtonTitle: "Reload",
            loadFailedMessage: "Loading products failed.",
            reloadRequested: {}
         )
         .previewDisplayName("Load Failed")

         HorizontalProductsStyle(verticalSpacing: 25).products(
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
