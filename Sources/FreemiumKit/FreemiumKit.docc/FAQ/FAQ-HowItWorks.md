# How does FreemiumKit work? Can I trust it?

Learn why you can trust FreemiumKit to scale with your app and why there's no long-term lock-in risk for your app.

@Metadata {
   @TitleHeading("FAQs")
   @PageKind(sampleCode)
}

## Short Answer

FreemiumKit is built on top of StoreKit 2 and official App Store Connect APIs. Therefore, most of what FreemiumKit does is following modern Apple best practices, without being dependent on our servers. For the paywall remote configuration, we use a Content Delivery Network (CN) for fast global distribution – but there's also a local fallback in your project, in case of downtimes.

## Full Answer

FreemiumKit is here to automate the cumbersome and fiddly steps in setting up and maintaining purchases for your app. Our goal is not to cover every possible pricing model, neither is it to support all technological stacks. For example, we will probably never support Android. Instead, we keep the scope focused on the most modern Apple technologies and pricing concepts.

We will always try to support all Apple platforms you can choose as a destination for your target in Xcode and keep up with the latest OS releases. We will always prefer official APIs over private APIs and keep every dependency out that is not absolutely needed. This means, we stick to official Apple APIs wherever possible.

This lead to the following current tech stack:

- Native apps for iOS, macOS, and visionOS (tvOS has no biometric authentication)
- App connects to official [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi/) endpoints to handle purchases
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) SDK targeting iOS, macOS, visionOS, and tvOS (watchOS is not a destination)
- SDK is built on top of [StoreKit 2](https://developer.apple.com/storekit/) and SwiftUI 3 (supporting iOS/tvOS 15+, macOS 12+)
- [Vapor](https://vapor.codes)-based server for push notifications when purchases are made (reported by SDK)
- [Supabase](https://supabase.com)-based Content Delivery Network (CDN) for remote configuration of paywalls
- [CloudKit](https://developer.apple.com/icloud/cloudkit/)-based persistence of purchase history in your Apple Account for backup & sync

The only non-Apple technologies here are our server and CDN. We included these dependencies in a thoughtful manner – let's suppose both are down, then:

- ❌ You would no longer receive **live push notifications** when users make purchases
- ❌ You would no longer be able to **remotely configure** your paywall or A/B test
- ✅ The Paywall UI would continue to work, using the local "fallback" configuration
- ✅ Users can continue to make purchases, as the SDK only needs StoreKit 2 for that
- ✅ Even paying users will continue to have access to paid features (via StoreKit 2)

Of course, we don't expect our servers to be down any significant amount of time. This was just to show you that we have considered all cases when designing FreemiumKit conceptually. And because all the purchases are directly configured on App Store Connect, you could even decide to move away from FreemiumKit entirely if you find our feature set does not fulfill your needs. There are no lock-in features. But beware, you will miss all our built-in conveniences! 😉

## Contact

Have questions or need support? Reach out to me at [freemiumkit@fline.dev](mailto:freemiumkit@fline.dev).

---

## Legal

@Small {
   Cihat Gündüz © 2024. All rights reserved.
   Privacy: No personal data is tracked on this site.
   [Imprint](https://www.fline.dev/imprint/)
}
