import StoreKit
import SwiftUI
import IdentifiedCollections

/// The vertical "Paywall Blueprint" style implementing learnings from analyzing 20 different successful paywalls.
/// If you have only up to 3 products, note that ``HorizontalPickerProductsStyle`` can save some vertical space in your paywall UI.
public struct VerticalPickerProductsStyle<ProductID: RawRepresentableProductID>: AsyncProductsStyle {
   private struct ContinueButtonStyle: ButtonStyle {
      let tintColor: Color

      func makeBody(configuration: Configuration) -> some View {
         configuration.label.background { RoundedRectangle(cornerRadius: 100).fill(self.tintColor) }
            .font(.title3.weight(.medium))
            .opacity(configuration.isPressed ? 0.7 : 1)
      }
   }

   private let preselectedProductID: ProductID?
   private let tintColor: Color

   public init(preselectedProductID: ProductID? = nil, tintColor: Color = .blue) {
      self.preselectedProductID = preselectedProductID
      self.tintColor = tintColor
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
      VStack(spacing: 15) {
         Text(loadFailedMessage)
         Button(reloadButtonTitle) { reloadRequested() }
      }
      .padding()
   }

   public func products(
      products: [FKProduct],
      productIDsEligibleForIntroductoryOffer: Set<FKProduct.ID>,
      purchasedTransactions: IdentifiedArray<String, FKTransaction>,
      purchaseInProgressProduct: FKProduct?,
      startPurchase: @escaping (FKProduct, Set<Product.PurchaseOption>) -> Void
   ) -> some View {
      ProductsView(
         preselectedProductID: self.preselectedProductID?.rawValue,
         tintColor: self.tintColor,
         products: products,
         productIDsEligibleForIntroductoryOffer: productIDsEligibleForIntroductoryOffer,
         purchasedTransactions: purchasedTransactions,
         purchaseInProgressProduct: purchaseInProgressProduct,
         startPurchase: startPurchase
      )
   }

   // an extra type is needed to use the `@State` property for the selected product ID
   struct ProductsView: View {
      @State
      private var selectedProductID: FKProduct.ID?

      var preselectedProductID: FKProduct.ID?
      let tintColor: Color

      let products: [FKProduct]
      let productIDsEligibleForIntroductoryOffer: Set<FKProduct.ID>
      let purchasedTransactions: IdentifiedArray<String, FKTransaction>
      let purchaseInProgressProduct: FKProduct?
      let startPurchase: (FKProduct, Set<Product.PurchaseOption>) -> Void

      var body: some View {
         VStack {
            ForEach(products) { product in
               Button {
                  self.selectedProductID = product.id
               } label: {
                  HStack {
                     VStack(alignment: .leading, spacing: 4) {
                        Text(product.displayName)

                        if
                           let subscription = product.subscription, let introductoryOffer = subscription.introductoryOffer,
                           productIDsEligibleForIntroductoryOffer.contains(product.id), introductoryOffer.paymentMode == .freeTrial
                        {
                           Text(introductoryOffer.period.localizedFreeTrialDescription)
                              .font(.subheadline)
                        }
                     }

                     Spacer()

                     VStack {
                        Text(product.displayPricePerPeriodIfSubscription)
                     }
                  }
                  .font(.title3.weight(.light))
                  .opacity(product.id == self.selectedProductID ? 1 : 0.7)
                  .padding(.horizontal, 18)
                  .padding(.vertical, 14)
                  .background(product.id == self.selectedProductID ? self.tintColor.opacity(0.1) : .clear)
                  .overlay {
                     RoundedRectangle(cornerRadius: 12)
                        .stroke(product.id == self.selectedProductID ? self.tintColor : .gray.opacity(0.3), lineWidth: 2.5)
                  }
                  .frame(minHeight: 44)
               }
               .buttonStyle(.plain)
               .listRowSeparator(.hidden)
            }
            .padding(.vertical, 5)
            .listStyle(.plain)

            Spacer().frame(minHeight: 20)

            Button {
               if let selectedProduct = self.selectedProduct(products: products) {
                  startPurchase(selectedProduct, [])
               }
            } label: {
               Text(Loc.FreemiumKit.PickerProductsStyle.ContinueButtonTitle.string)
                  .foregroundColor(.white)
                  .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(ContinueButtonStyle(tintColor: self.tintColor))
            .opacity(self.selectedProduct(products: products) == nil ? 0.5 : 1)
            .disabled(self.selectedProduct(products: products) == nil)
         }
         .overlay {
            if self.purchaseInProgressProduct != nil {
               ProgressView()
            }
         }
         .padding(.horizontal, 30)
         .padding(.vertical, 20)
         .onAppear {
            self.selectedProductID = self.preselectedProductID
         }
      }

      private func selectedProduct(products: [FKProduct]) -> FKProduct? {
         products.first { $0.id == self.selectedProductID }
      }
   }
}

#if DEBUG
struct VerticalPickerProductsStyle_Previews: PreviewProvider {
   private enum ProductID: String, RawRepresentableProductID {
      case liteMonthly = "Lite.Monthly"
      case liteYearly = "Lite.Yearly"
      case proMonthly = "Pro.Monthly"
      case proYearly = "Pro.Yearly"
      case proLifetime = "Pro.Lifetime"
   }

   static var previews: some View {
      Group {
         VerticalPickerProductsStyle(preselectedProductID: ProductID.liteYearly).productsLoadingPlaceholder()
            .previewDisplayName("Placeholder")

         VerticalPickerProductsStyle(preselectedProductID: ProductID.liteYearly).productsLoadFailed(
            reloadButtonTitle: "Reload",
            loadFailedMessage: "Loading products failed.",
            reloadRequested: {}
         )
         .previewDisplayName("Load Failed")

         VerticalPickerProductsStyle(preselectedProductID: ProductID.liteYearly).products(
            products: FKProduct.mockedProducts,
            productIDsEligibleForIntroductoryOffer: Set(FKProduct.mockedProducts.map(\.id)),
            purchasedTransactions: .init(uniqueElements: [], id: \.productID),
            purchaseInProgressProduct: nil,
            startPurchase: { _, _ in }
         )
         .previewDisplayName("Products")
      }
   }
}
#endif
