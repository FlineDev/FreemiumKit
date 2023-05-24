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
      products: [FKProduct],
      productIDsEligibleForIntroductoryOffer: Set<FKProduct.ID>,
      purchasedTransactions: IdentifiedArray<String, FKTransaction>,
      startPurchase: @escaping (FKProduct, Set<Product.PurchaseOption>) -> Void
   ) -> Products
}
