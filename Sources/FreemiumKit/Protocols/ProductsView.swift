import StoreKit
import SwiftUI

public protocol ProductsView: View {
   init(
      products: [Product],
      purchasedTransactions: Set<StoreKit.Transaction>,
      purchaseInProgressProduct: Product?,
      startPurchase: (Product, Set<Product.PurchaseOption>) -> Void
   )
}
