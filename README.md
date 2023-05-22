TODO: add Swift Package Index badges

# FreemiumKit

Lightweight layer on top of [StoreKit 2](https://developer.apple.com/videos/play/wwdc2021/10114/) + built-in permission engine & built-in UI components for your SwiftUI paywall.

Read [this introductory article]() for a full step-by-step guide on how to setup in-app purchases for your app + some basic thoughts on pricing.


## Scope

The purpose of this project is to make common In-App Purchase scenarios as easy as possible. But it's not the goal to cover every single feature of StoreKit 2.
For example, FreemiumKit automatically handles expired & revoked purchases without passing on details like revocation/expiration date to the app. Instead, it defaults to what most developers probably want.

So, if you're missing a feature in FreemiumKit, you are free to request the feature in the Issues tab. But please provide a reason why you think that feature is needed by many developers or it might be ignored.
Always remember though: Except for the UI components, this library is really lightweight and the core logic is unlikely to get many changes. So forking the library is a viable option.


## Quick Setup

Here are the minimum steps you need to take to make use of FreemiumKit:

TODO: initialize `InAppPurchase` on app start (AppDelegate), types conforming to `Unlockable` and `RawRepresentableProductID`, demo project available


## Provided UI Components

To get you up and running fast, FreemiumKit ships with a set of community-provided UI components that you can use in your SwiftUI paywall: 

TODO: table with a preview image fore each and which features are supported (like showing subscriptions, consumables, etc.) + original author


## Implementing a Custom UI

While FreemiumKit ships with the above UI components that you can use out of the box, you can provide your entirely custom UI:

TODO: explain how to conform to `AsyncProductsStyle` and it's recommended to copy & adjust `PlainAsyncProdcutsStyle` which is its whhole purpose

Note: If you implemented a somewhat different UI and have the chance to share it with the community, I'm happy to review your PR!    


## TODOs

While basic In-App Purchases are already covered, there are several extra features I'd like to add over time. These include:

- [ ] Fix localized texts not working properly
- [ ] Introductory Offer support (hiding away the eligibility check)
- [ ] Promotional Offers support


## Contributing

If you find any issues with this project, make sure to report them in the Issues tab. Any questions should be asked in the Discussions tab.

If you want to share your custom UI component with the community, that's also highly encouraged!
It can even be a cool SwiftUI programming challenge to find a paywall design you like and trying to implement it & sharing with the community.


## FAQ

<details>
<summary>Does FreemiumKit do receipt validation?</summary>
<p>Yes: FreemiumKit is built on top of StoreKit 2 which automatically verifies any transaction is "signed by the App Store for my app for this device" (quote from [WWDC22 session "Meet StoreKit 2"](https://developer.apple.com/videos/play/wwdc2021/10114/)) before passing them on. It leaves developers the choice to accept even unverified purchases or to ignore them, depending on their business needs. But FreemiumKit doesn't do that, it simply **always** ignores them. When FreemiumKit passes a transaction to the UI component, it has already successfully passed validation. 💯</p>
</details>

<details>
<summary>I can't decide: Should I use a service like RevenueCat or StoreKit directly with this library?</summary>
<p>The purpose of this library is to make integrating with StoreKit 2 as easy as possible. It does this job much better than the SDKs of RevenueCat and the like.</p>
<p>The purpose of those services was also to make integrating with StoreKit easier, but that was because StoreKit 1 was much harder to work with and quite limited, too. Apple improved that situation vastly with StoreKit 2 in iOS 15+ so that advantage no longer holds true. But these service not only make things easier for StoreKit 1, they also add a lot of other value, like providing live purchase stats on their site (Connect data is delayed), providing an overview of your total income if you also support other platforms like Android, and much more. If you need any of these things, you might want to use those services. But if all you want is to provide In-App Purchases on Apple platforms as easy as possible and you are on iOS 15+, I recommend FreemiumKit.</p>
</details>

<details>
<summary>Can I use FreemiumKit and services like RevenueCat side-by-side?</summary>
<p>Maybe. It was never the goal of FreemiumKit to be used in combination with those services, but some may want to use the permissions & UI capabilities of FreemiumKit while also profiting from the extra features of such a service. I'm not one of thoe people though, so I can't provide any support here. It's best you contact those services directly. The license of FreemiumKit allows for them to fork it or copy any code they like into their own SDKs.</p>
</details>


## License

This library is released under the [MIT License](http://opensource.org/licenses/MIT). See LICENSE for details.
