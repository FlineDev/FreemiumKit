import StoreKit
import SwiftUI
import IdentifiedCollections

/// A very simple style using only plain SwiftUI types like ``Text``, ``Button``, or ``Label`` without fancy styling.
/// Don't use this directly – this is meant as a guide to help those who want to implement their custom ``AsyncProductsStyle`` styles.
public struct PlainProductsStyle: AsyncProductsStyle {
   public init() {}

   public func productsLoadingPlaceholder() -> some View {
      ProgressView()
         .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
   }

   public func products(
      products: [FKProduct],
      productIDsEligibleForIntroductoryOffer: Set<FKProduct.ID>,
      purchasedTransactions: IdentifiedArray<String, FKTransaction>,
      renewalInfoByProductID: Dictionary<FKProduct.ID, FKProduct.SubscriptionInfo.RenewalInfo>,
      purchaseInProgressProductID: FKProduct.ID?,
      startPurchase: @escaping (FKProduct) -> Void
   ) -> some View {
      List(products) { product in
         if purchasedTransactions.contains(where: \.productID, equalTo: product.id) {
            Label(product.displayName, systemImage: "checkmark")
         } else {
            Button {
               startPurchase(product)
            } label: {
               if purchaseInProgressProductID == product.id {
                  ProgressView()
               } else {
                  HStack {
                     Text(product.displayName)
                     Spacer()
                     Text(product.displayPrice)
                  }
               }
            }
            .disabled(purchaseInProgressProductID != nil)
         }
      }
   }
}

#if DEBUG
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
            products: FKProduct.mockedProducts,
            productIDsEligibleForIntroductoryOffer: Set(FKProduct.mockedProducts.map(\.id)),
            purchasedTransactions: .init(uniqueElements: [], id: \.productID),
            renewalInfoByProductID: [:],
            purchaseInProgressProductID: nil,
            startPurchase: { _ in }
         )
         .previewDisplayName("Products")
      }
   }
}
#endif
