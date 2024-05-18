![FreemiumKit Logo](https://github.com/FlineDev/FreemiumKit/blob/main/Logo.png?raw=true)

# FreemiumKit

The fastest & easiest way to provide in-app purchases & subscriptions in apps for iOS, macOS, tvOS, and visionOS.

This repo serves as the provider for your FreemiumKit SDK to include in your apps. The SDK takes away all the hard work to integrate with StoreKit and even provides configurable paywall UIs and convenient SwiftUI views to lock features in your app with low effort. 


## Getting Started

TODO

## FAQ

<details>
<summary>Does FreemiumKit do receipt validation?</summary>
<p>Yes: FreemiumKit is built on top of StoreKit 2 which automatically verifies any transaction is "signed by the App Store for my app for this device" (quote from WWDC22 session "Meet StoreKit 2") before passing them on. It leaves developers the choice to accept even unverified purchases or to ignore them, depending on their business needs. But FreemiumKit doesn't do that, it simply ALWAYS ignores them. When FreemiumKit passes a transaction to the UI component, it has already successfully passed validation. 💯</p>
</details>

<details>
<summary>How does FreemiumKit compare to RevenueCat?</summary>
<p>TODO (table)</p>
</details>

<details>
<summary>Can I use FreemiumKit and services like RevenueCat side-by-side?</summary>
<p>Yes, you can! TODO…</p>
</details>
