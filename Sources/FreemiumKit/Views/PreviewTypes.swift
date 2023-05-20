import Foundation

#if DEBUG
/// A replica of ``StoreKit.Product`` to instantiate fake products during development for SwiftUI previews.
struct PreviewProduct: Identifiable, Hashable, Sendable {
   /// Properties and functionality specific to auto-renewable subscriptions.
   struct SubscriptionInfo: Hashable, Sendable {
      /// The duration that this subscription lasts before auto-renewing.
      let subscriptionPeriod: Product.SubscriptionPeriod

      #warning("✨ add `introductoryOffer` & `promotionalOffers` support here")
   }

   /// The unique product identifier.
   let id: String

   /// The type of the product.
   let type: Product.ProductType

   /// A localized display name of the product.
   let displayName: String

   /// A localized description of the product.
   let description: String

   /// The price of the product in local currency.
   let price: Decimal

   /// A localized string representation of `price`.
   let displayPrice: String

   /// Whether the product is available for family sharing.
   let isFamilyShareable: Bool

   /// Properties and functionality specific to auto-renewable subscriptions.
   ///
   /// This is never `nil` if `type` is `.autoRenewable`, and always `nil` for all other product types.
   let subscription: SubscriptionInfo?
}

/// A replica of ``StoreKit.Transaction`` to instantiate fake transactions during development for SwiftUI previews.
struct PreviewTransaction: Hashable, Sendable {
   /// Identifies the product the transaction is for.
   let productID: String

   /// The date this transaction occurred on.
   let purchaseDate: Date

   /// The date the original transaction for `productID` or`subscriptionGroupID` occurred on.
   let originalPurchaseDate: Date

   /// The date the users access to `productID` expires
   /// - Note: Only for subscriptions.
   let expirationDate: Date?

   /// Quantity of `productID` purchased in the transaction.
   /// - Note: Always 1 for non-consumables and auto-renewable suscriptions.
   let purchasedQuantity: Int

   /// The type of `productID`.
   let productType: Product.ProductType

   #warning("✨ add `offerType` and `offerID` support here")
}
#endif
