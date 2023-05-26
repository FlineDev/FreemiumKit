TODO: add Swift Package Index badges

# FreemiumKit

Lightweight layer on top of [StoreKit 2](https://developer.apple.com/videos/play/wwdc2021/10114/) + built-in permission engine & built-in UI components for SwiftUI paywalls.

Read [this introductory article]() for a full step-by-step guide on how to setup in-app purchases for your app + some basic thoughts on pricing.


## Getting Started

Here are the minimum steps you need to take to make use of FreemiumKit (obviously, you first need to add it as a package dependency):

Step 0: Obviously, you need to add FreemiumKit to your app as a package dependency first. See [Apples official guide](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app).

### Step 1: Define a type that conforms to `RawRepresentableProductID`

This is required so FreemiumKit knows what products you want to present to the users.
Make sure to use the correct identifiers of the products you created on App Store Connect as the raw String values:

```Swift
enum ProductID: String, CaseIterable, RawRepresentableProductID {
   case proMonthly = "dev.fline.TwootIt.Pro.Monthly"
   case proYearly = "dev.fline.TwootIt.Pro.Monthly"
   case proLifetime = "dev.fline.TwootIt.Pro.Lifetime"
   
   case liteMonthly = "dev.fline.TwootIt.Lite.Monthly"
   case liteYearly = "dev.fline.TwootIt.Lite.Yearly"
   case liteLifetime = "dev.fline.TwootIt.Lite.Lifetime"
}
```

Note that it is totally possible to provide more cases here than you present to users.
For example, if you have a product that you only want to offer to customers that unsubscribed to win them back (re-engagement offers), add it here.

### Step 2: Define a type that conforms to `Unlockable`

This is part of the built-in permissions system that will help you decide which features your user has access to.
Specify the different kinds of features you lock or limit for lower/free tiers here.
Note that you decide if you prefer a more fine-grained control or if you want to group features into broader topics and just list those:

```Swift
enum LockedFeature: Unlockable {
   case twitterPostsPerDay
   case extendedAttachments
   case scheduledPosts

   func permission(purchasedProductIDs: Set<ProductID>) -> Permission {
      switch self {
      case .twitterPostsPerDay:
         return purchasedProductIDs.containsAny(prefixedBy: "dev.fline.TwootIt.Pro") ? .limited(3) : .locked 
      case .extendedAttachments:
         return purchasedProductIDs.isEmpty ? .locked : .unlimited
      case .scheduledPosts:
         return purchasedProductIDs.isEmpty ? .limited(1) : .unlimited
      }
   }
}
```

Note that you have to implement the `permission(purchasedProductIDs:)` function yourself.
In it, you get passed a set of `ProductID`s (the type you defined in step 1) and you have to return a `Permission`, one of `.locked`, `.limited(Int)`, or `.unlimited`.
You can make use of the [convenience functions](https://github.com/FlineDev/FreemiumKit/blob/main/Sources/FreemiumKit/Protocols/Unlockable.swift#L37-L67) starting with `containsAny` FreemiumKit ships with to extend the `Set<ProductID>` type.

### Step 3: Initialize an instance of `InAppPurchase` on app start

In a SwiftUI app, using a simple global instance, this could look something like this:

```Swift
import SwiftUI
import FreemiumKit

final class AppDelegate: NSObject, UIApplicationDelegate {
   static let inAppPurchase: InAppPurchase<ProductID> = .init()
}

@main
struct FreemiumKitDemoApp: App {
   @UIApplicationDelegateAdaptor(AppDelegate.self)
   var appDelegate

   var body: some Scene {
      WindowGroup {
         ContentView()
      }
   }
}
```

Note that you need to pass your custom `ProductID` type as the generic type to `InAppPurchase` to let it know about your apps product IDs.
The sheer initialization of `InAppPurchase` will activate your apps integration with StoreKit and load the users purchased products on app start.
It will also take care of observing any changes while the app is running, so your users purchases are always correct.

### Step 4: Lock your features if user doesn't have permission

Now, anywhere in your app where you have features that are potentially locked, you can ask `InAppPurchase` what the current permissions for your custom `LockedFeature` type are at the moment:

```Swift
let permission = AppDelegate.inAppPurchase.permission(for: LockedFeature.scheduledPosts)
```

The `Permission` type which you receive as a response to `permission(for:)` is an enum that you can switch over, but it also comes with a bunch of convenience APIs so no switch-case is ever needed:

* `permission.isAlwaysGranted` returns `true` if the permission is set to `unlimited`
* `permission.isAlwaysDenied` returns `true` if the permission is set to `locked`
* `permission.limit` returns an `Int` that represents the allowed count (`0` if `locked`, `Int.max` if `unlimited`)
* `permission.isGranted(current: Int)` returns `true` if the `current` "usage count" **doesn't exceed** the allowed limit
* `permission.isDenied(current: Int)` returns `true` if the `current` "usage count" **equals or exceeds** the allowed limit

So, you might do something like this:

```Swift
Button("Schedule Post") { ... }
   .disabled(AppDelegate.inAppPurchase.permission(for: LockedFeature.schedulesPosts.isDenied(current: scheduledPosts.count))
```

Note that FreemiumKit does not help persisting your current usage count, you need to handle that yourself, e.g. using UserDefaults or requesting your server API.

### Step 5: Show your products & handle purchase completion in your paywall

Lastly, whenever you present your paywall, you can use one of the provided UI components so you don't have to fetch your products from App Store Connect and present them in a nice way yourself. The UI part is what really saves a lot of time when integrating in-app purchases, and thanks to the open `AsyncProductsStyle` protocol, the community can add new UI styles over time so you can quickly switch between different styles, following current trends or doing A/B testing easily.

For a full list of all available UI components, see the next section. But after [some research](TODO) I created the `VerticalPickerProductsStyle` which is a good one to start with as it's clean, flexible, and proven to be succesful in many high-grossing apps:

```Swift
// in your paywall SwiftUI screen, place this view where you need it (for iOS, bottom half of the screen is recommended)
AsyncProducts(
   style: VerticalPickerProductsStyle(preselectedProductID: ProductID.proYearly), 
   productIDs: ProductID.allCases, 
   inAppPurchase: AppDelegate.inAppPurchase
)
``` 

Note that instead of `VerticalPickerProductsStyle` you can pass any other community-provided or even your custom style, or pass some of the optional parameters to `VerticalPickerProductsStyle`. Also, instead of `ProductID.allCases`, you can pass an array with only select cases if you don't want to show all available options at once (like excluding re-engagement offers).

The resulting screen should look something like this (the `AsyncProducts` view is highlighted):

<img src="https://github.com/FlineDev/FreemiumKit/blob/main/Images/PaywallSample_AsyncProducts.png?raw=true">

Note that the `AsyncProducts` initializer takes several optional arguments, one of them is `onPurchase` which you can use to close your paywall or do whatever the next step is after a successful purchase. For example:

```Swift
@Environment(\.dismiss)
var dismiss
// ...
AsyncProducts(style: ..., productIDs: ..., inAppPurchase: ..., onPurchase: { _ in self.dismiss() })
```

<details>
<summary>Read this if any of your products is a Consumable</summary>
<p>Typically, you need to execute some code to provide the purchased consumable thing to your user, and often this code involves sending requests to a server. To ensure a user actually gets the purchased consumable, StoreKit requires you to call the `finish()` method on the purchased `Transaction`. FreemiumKit defaults to automatically calling `finish()` right after a transaction was successfully made, but for consumables, it's better you handle this manually. To do that, make sure to set the optional parameter `autoFinishPurchases` to `false` on the `AsyncProducts` initializer. Then, use the `transaction` parameter passed to the optional `onPurchase` closure of the same initializer to call `finish()` once you provided your user with the purchased consumable item(s). Any consumable items you neve called `finish()` on will be delivered to the app on each app start and can be handled by using the `onPurchase` closure of the `InAppPurchase` initializer.</p>
</details>

## Provided UI Components

To get you up and running fast, FreemiumKit ships with a set of community-provided UI components that you can use in your SwiftUI paywall: 

TODO: table with a preview image fore each and which features are supported (like showing subscriptions, consumables, etc.) + original author


## Implementing a Custom UI

While FreemiumKit ships with the above UI components that you can use out of the box, you can provide your entirely custom UI:

TODO: explain how to conform to `AsyncProductsStyle` and it's recommended to copy & adjust `PlainAsyncProdcutsStyle` which is its whhole purpose

Note: If you implemented a somewhat different UI and have the chance to share it with the community, I'm happy to review your PR!    


## Project Scope

The purpose of this project is to make common In-App Purchase scenarios as easy as possible. But it's not the goal to cover every single feature of StoreKit 2.
For example, FreemiumKit automatically handles expired & revoked purchases without passing on details like revocation/expiration date to the app. Instead, it defaults to what most developers probably want: Ignoring them.

So, if you're missing a feature in FreemiumKit, you are free to request the feature in the Issues tab. But please provide a reason why you think that the feature is needed by many developers.
Except for the UI components, this library is really lightweight and the core logic is unlikely to get many changes. So forking the library is a viable option.


## TODOs

While basic In-App Purchases are already covered, there are several extra features I'd like to add over time. These include:

- [ ] Fix localized texts not working properly
- [ ] Implement `HorizontalPickerProductsStyle`
- [ ] Other types of introductory offers than `.freeTrial` support (in UI components)
- [ ] Promotional Offers support (in UI components)


## Contributing

If you find any issues with this project, make sure to report them in the Issues tab. Any questions should be asked in the Discussions tab.

If you want to share your custom UI component with the community, that's also highly encouraged!
It can even be a cool SwiftUI programming challenge to find a paywall design you like (e.g. from [here](https://www.paywallscreens.com/)) and trying to implement it & sharing with the community.


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
