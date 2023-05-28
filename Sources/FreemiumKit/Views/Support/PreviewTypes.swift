import Foundation
import StoreKit
import IdentifiedCollections

#warning("🧑‍💻 find a better way to develop with SwiftUI previews, this commenting in/out isn't great")
// To instantiate fake products during development for SwiftUI previews, simply change the right hand side to `PreviewProduct` & `PreviewTransaction`.
public typealias FKProduct = PreviewProduct
public typealias FKTransaction = PreviewTransaction

#if DEBUG
/// A replica of ``StoreKit.Product`` to instantiate fake products during development for SwiftUI previews.
public struct PreviewProduct: Identifiable, Hashable, Sendable {
   /// Properties and functionality specific to auto-renewable subscriptions.
   public struct SubscriptionInfo: Hashable, Sendable {
      /// The renewal status information for an auto-renewable subscription.
      struct Status: Hashable, Sendable {
         /// The signed renewal information for the auto-renewable subscription.
         let renewalInfo: VerificationResult<RenewalInfo>
      }

      /// The renewal information for an auto-renewable subscription.
      public struct RenewalInfo: Hashable, Sendable {
         /// A Boolean value that indicates whether the subscription will automatically renew in the next period.
         let willAutoRenew: Bool
      }

      /// An optional introductory offer that will automatically be applied if the user is eligible.
      let introductoryOffer: SubscriptionOffer?

      /// An array of all the promotional offers configured for this subscription.
      let promotionalOffers: [SubscriptionOffer]

      /// The duration that this subscription lasts before auto-renewing.
      let subscriptionPeriod: SubscriptionPeriod

      /// Whether the user is eligible to have an introductory offer applied to their purchase.
      var isEligibleForIntroOffer: Bool { true }

      /// An array that contains status information for a subscription group, including renewal and transaction information.
      let status: [Status]
   }

   /// Information about a subscription offer configured in App Store Connect.
   struct SubscriptionOffer: Hashable, Sendable {
      /// The type of the offer.
      let type: Product.SubscriptionOffer.OfferType

      /// The discounted price that the offer provides in local currency.
      ///
      /// This is the price per period in the case of `.payAsYouGo`
      let price: Decimal

      /// A localized string representation of `price`.
      let displayPrice: String

      /// The duration that this offer lasts before auto-renewing or changing to standard subscription renewals.
      let period: SubscriptionPeriod

      /// The number of periods this offer will renew for.
      ///
      /// Always 1 except for `.payAsYouGo`.
      let periodCount: Int

      /// How the user is charged for this offer.
      let paymentMode: Product.SubscriptionOffer.PaymentMode
   }

   struct SubscriptionPeriod: Hashable, Sendable {
      /// The unit of time that this period represents.
      let unit: Product.SubscriptionPeriod.Unit

      /// The number of units that the period represents.
      let value: Int
   }

   enum PurchaseResult {
       /// The purchase succeeded with a `Transaction`.
       case success(VerificationResult<PreviewTransaction>)

       /// The user cancelled the purchase.
       case userCancelled

       /// The purchase is pending some user action.
       ///
       /// These purchases may succeed in the future, and the resulting `Transaction` will be delivered via `Transaction.updates`
       case pending
   }

   /// The unique product identifier.
   public let id: String

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

   static func products(for identifiers: [String]) throws -> [PreviewProduct] {
      return [
         PreviewProduct(
            id: "Lite.Monthly",
            type: .autoRenewable,
            displayName: "Lite (Monthly)",
            description: "Up to 50 documents, 1 team member",
            price: 0.99,
            displayPrice: "$0.99",
            isFamilyShareable: false,
            subscription: SubscriptionInfo(
               introductoryOffer: nil,
               promotionalOffers: [],
               subscriptionPeriod: SubscriptionPeriod(unit: .month, value: 1),
               status: []
            )
         ),
         PreviewProduct(
            id: "Lite.Yearly",
            type: .autoRenewable,
            displayName: "Lite (Yearly)",
            description: "Up to 50 documents, 1 team member",
            price: 9.99,
            displayPrice: "$9.99",
            isFamilyShareable: false,
            subscription: SubscriptionInfo(
               introductoryOffer: nil,
               promotionalOffers: [],
               subscriptionPeriod: SubscriptionPeriod(unit: .year, value: 1),
               status: []
            )
         ),
         PreviewProduct(
            id: "Pro.Monthly",
            type: .autoRenewable,
            displayName: "Pro (Monthly)",
            description: "Unlimited documents, up to 5 team members",
            price: 2.99,
            displayPrice: "$2.99",
            isFamilyShareable: false,
            subscription: SubscriptionInfo(
               introductoryOffer: SubscriptionOffer(
                  type: .introductory,
                  price: 0,
                  displayPrice: "$0.00",
                  period: SubscriptionPeriod(unit: .day, value: 3),
                  periodCount: 1,
                  paymentMode: .freeTrial
               ),
               promotionalOffers: [],
               subscriptionPeriod: SubscriptionPeriod(unit: .month, value: 1),
               status: [.init(renewalInfo: .verified(.init(willAutoRenew: false)))]
            )
         ),
         PreviewProduct(
            id: "Pro.Yearly",
            type: .autoRenewable,
            displayName: "Pro (Yearly)",
            description: "Unlimited documents, up to 5 team members",
            price: 29.99,
            displayPrice: "$29.99",
            isFamilyShareable: false,
            subscription: SubscriptionInfo(
               introductoryOffer: SubscriptionOffer(
                  type: .introductory,
                  price: 0,
                  displayPrice: "$0.00",
                  period: SubscriptionPeriod(unit: .day, value: 7),
                  periodCount: 1,
                  paymentMode: .freeTrial
               ),
               promotionalOffers: [],
               subscriptionPeriod: SubscriptionPeriod(unit: .year, value: 1),
               status: [.init(renewalInfo: .verified(.init(willAutoRenew: true)))]
            )
         ),
         PreviewProduct(
            id: "Pro.Lifetime",
            type: .nonConsumable,
            displayName: "Pro (Lifetime)",
            description: "Unlimited documents, up to 5 team members, forever",
            price: 74.99,
            displayPrice: "$74.99",
            isFamilyShareable: false,
            subscription: nil
         ),
      ]
   }

   func purchase(options: Set<Product.PurchaseOption> = []) async throws -> PurchaseResult {
      try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
      return .pending
   }
}

/// A replica of ``StoreKit.Transaction`` to instantiate fake transactions during development for SwiftUI previews.
public struct PreviewTransaction: Hashable, Sendable {
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

   /// If this transaction was upgraded to a subscription with a higher level of service.
   /// - Important: If this property is `true`, look for a new transaction for a subscription with a
   ///              higher level of service.
   /// - Note: Only for subscriptions.
   let isUpgraded: Bool

   #warning("%@ add `offerType` and `offerID` support here?")

   /// The date the transaction was revoked, or `nil` if it was not revoked.
   let revocationDate: Date?

   /// The reason the transaction was revoked, or `nil` if it was not revoked.
   let revocationReason: Transaction.RevocationReason?

   /// The type of `productID`.
   let productType: Product.ProductType

   /// Call this method after giving the user access to `productID`.
   public func finish() async {}

   /// A sequence that emits a transaction each time it is created or updated.
   /// - Important: Create a `Task` to iterate this sequence as early as possible when your app
   ///              launches. This is important, for example, to handle transactions that may have
   ///              occured after `purchase` returns, like an adult approving a child's purchase
   ///              request or a purchase made on another device.
   /// - Note: Any unfinished transactions will be emitted from `updates` when you first iterate the
   ///         sequence.
   static var updates: AsyncStream<VerificationResult<PreviewTransaction>> {
      AsyncStream {
         VerificationResult.verified(
            PreviewTransaction(
               productID: "Pro.Monthly",
               purchaseDate: .now.addingTimeInterval(-3 * 24 * 60 * 60),
               originalPurchaseDate: .now.addingTimeInterval(-33 * 24 * 60 * 60),
               expirationDate: .now.addingTimeInterval(27 * 24 * 60 * 60),
               purchasedQuantity: 1,
               isUpgraded: false,
               revocationDate: nil,
               revocationReason: nil,
               productType: .autoRenewable
            )
         )
      }
   }

   /// i.e. all currently-subscribed transactions, and all purchased (and not refunded) non-consumables
   static var currentEntitlements: AsyncStream<VerificationResult<PreviewTransaction>> {
      AsyncStream {
         VerificationResult.verified(
            PreviewTransaction(
               productID: "Pro.Monthly",
               purchaseDate: .now.addingTimeInterval(-3 * 24 * 60 * 60),
               originalPurchaseDate: .now.addingTimeInterval(-33 * 24 * 60 * 60),
               expirationDate: .now.addingTimeInterval(27 * 24 * 60 * 60),
               purchasedQuantity: 1,
               isUpgraded: false,
               revocationDate: nil,
               revocationReason: nil,
               productType: .autoRenewable
            )
         )
      }
   }
}

extension PreviewProduct {
   static var mockedProducts: [Self] { try! Self.products(for: []) }
}

extension Product {
   static let mockedProducts: [Self] = []
}

extension PreviewTransaction {
   static var mockedTransactions: IdentifiedArray<String, Self> {
      IdentifiedArray<String, Self>(
         uniqueElements: [PreviewTransaction(
            productID: PreviewProduct.mockedProducts.first?.id ?? "",
            purchaseDate: .now.advanced(by: -3 * 24 * 60 * 60),
            originalPurchaseDate: .now.advanced(by: -3 * 24 * 60 * 60),
            expirationDate: .now.advanced(by: 27 * 24 * 60 * 60),
            purchasedQuantity: 1,
            isUpgraded: false,
            revocationDate: nil,
            revocationReason: nil,
            productType: PreviewProduct.mockedProducts.first?.type ?? .autoRenewable
         )],
         id: \.productID
      )
   }
}

extension StoreKit.Transaction {
   static let mockedTransactions: IdentifiedArray<String, Self> = .init(uniqueElements: [], id: \.productID)
}
#endif
