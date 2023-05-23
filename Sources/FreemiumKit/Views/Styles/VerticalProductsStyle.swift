import StoreKit
import SwiftUI
import IdentifiedCollections

/// The vertical "Paywall Blueprint" style implementing learnings from analyzing 20 different successful paywalls.
/// If you have only up to 3 products, note that ``HorizontalProductsStyle`` can save some vertical space in your paywall UI.
public struct VerticalProductsStyle: AsyncProductsStyle {
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
      VStack {
         List(products) { product in
            HStack {
               VStack(alignment: .leading, spacing: 4) {
                  Text(product.displayName).font(.title3)

                  if
                     let subscription = product.subscription, subscription.isEligibleForIntroOffer,
                     let introductoryOffer = subscription.introductoryOffer, introductoryOffer.paymentMode == .freeTrial
                  {
                     Text(introductoryOffer.period.localizedFreeTrialDescription).font(.subheadline)
                  }
               }

               Spacer()

               VStack {
                  Text(product.displayPricePerPeriodIfSubscription).font(.title3)
               }
            }
            .frame(minHeight: 58)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .overlay {
               RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.3), lineWidth: 2)
            }
            .listRowSeparator(.hidden)
         }
         .padding()
         .listStyle(.plain)
         .overlay {
            if purchaseInProgressProduct != nil {
               ProgressView()
            }
         }

//         Button("Continue") { startPurchase(product, []) }
      }
   }
}

struct VerticalProductsStyle_Previews: PreviewProvider {
   static var previews: some View {
      Group {
         VerticalProductsStyle().productsLoadingPlaceholder()
            .previewDisplayName("Placeholder")

         VerticalProductsStyle(verticalSpacing: 20).productsLoadFailed(
            reloadButtonTitle: "Reload",
            loadFailedMessage: "Loading products failed.",
            reloadRequested: {}
         )
         .previewDisplayName("Load Failed")

         VerticalProductsStyle(verticalSpacing: 25).products(
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
