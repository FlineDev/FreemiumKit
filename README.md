> ⚠️ While I use this framework in production for my app [Twoot it!](https://twoot-it.app), the paywall part got [sherlocked by Apple](https://developer.apple.com/documentation/storekit/in-app_purchase/storekit_views) and soon [also RevenueCat](https://twitter.com/RevenueCat/status/1697253094520967183) will ship a paywall framework. Therefore, currently, I'm not planning to continue working on this project. And if I do (e.g. because Apple's new UI is only iOS 17+), expect some redesign of the paywall view API part to follow Apple's new API design for an easy switch to their native components.

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
         return purchasedProductIDs.contains(where: \.rawValue, prefixedBy: "dev.fline.TwootIt.Pro") ? .limited(3) : .locked 
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
You can make use of the [`contains(where:...:)` convenience functions](https://github.com/FlineDev/FreemiumKit/blob/main/Sources/FreemiumKit/Extensions/SequenceExt.swift) FreemiumKit ships with.

### Step 3: Initialize an instance of `InAppPurchase` on app start

In a SwiftUI app, using a simple global instance, this could look something like this:

```Swift
import SwiftUI
import FreemiumKit

final class AppDelegate: NSObject, UIApplicationDelegate {
   static let inAppPurchase = InAppPurchase<ProductID>()
   
   func application(
      _ application: UIApplication,
      willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
   ) -> Bool {
      Self.inAppPurchase.appLaunched()
      return true
   }
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

The `Permission` type which you receive as a response to `permission(for:)` is an enum with the cases `locked`, `limited(Int)`, and `unlimited` that you can switch over.
But it also comes with a bunch of convenience APIs so no switch-case is ever needed:

* `permission.isAlwaysGranted` returns `true` if the permission is set to `unlimited`
* `permission.isAlwaysDenied` returns `true` if the permission is set to `locked`
* `permission.limit` returns an `Int` that represents the allowed count (`0` if `locked`, `Int.max` if `unlimited`)
* `permission.isGranted(current: Int)` returns `true` if the `current` "usage count" **doesn't exceed** the allowed limit
* `permission.isDenied(current: Int)` returns `true` if the `current` "usage count" **equals or exceeds** the allowed limit

So, you might do something like this:

```Swift
Button("Schedule Post") { ... }
   .disabled(
      AppDelegate.inAppPurchase
         .permission(for: LockedFeature.schedulesPosts)
         .isDenied(current: scheduledPosts.count)
   )
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
.padding()
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

### Step 6: Provide a 'Restore Purchases' button to pass App Store Review

While FreemiumKit implements the latest proactive in-app purchase restore best practice, [Apple still recommends](https://developer.apple.com/videos/play/wwdc2022/110404/?time=1145) adding a 'Restore Purchases' button to your app. It's also explicitly mentioned in the App Store Review guidelines (see [section 3.1.1 In-App Purchase](https://developer.apple.com/app-store/review/guidelines/#in-app-purchase)). To give you full flexibility of deciding where to put your 'Restore Purchases' button and to allow you placing it among other buttons like 'Terms of Service' or 'Privacy Policy', FreemiumKit does not place a 'Restore Purchases' button into the `AsyncProducts` view.

Instead, a separate `RestorePurchasesButton` view is provided that encapsulates a button with loading logic & even a loading state which you can place anywhere you see fit and it will just work. Note that the view isn't styled in any way though, so you need to style it the way you want, allowing you to provide a custom `.buttonStyle()`, for example. Most apps probably want to keep the style to the default (`.plain`) though, but "down-pop" the button to make it less prominent like so:

```Swift
RestorePurchasesButton(inAppPurchase: AppDelegate.inAppPurchase)
   .font(.footnote)
   .foregroundColor(.secondary)
```

And that's it! You've added support for in-app purchases to your app. :tada:

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

- [ ] Automatically calculate long-term subcription savings over short-term ones & show "Save 20%" badge
- [ ] Support for specifying a "Popular" or "Best Value" badge to selected plans
- [ ] Implement `HorizontalPickerProductsStyle`
- [ ] Implement an Apple-style `HorizontalButtonsProductsStyle` (like in the [Final Cut Pro for iPad](https://twitter.com/emcro/status/1661032919459307520?s=61&t=UWlky3QOTUEnuolT9bg7RA) paywall)
- [ ] Support for other kinds of Introductory Offers than `freeTrial`
- [ ] Support for Promotional Offers


## Contributing

If you find any issues with this project, make sure to report them in the Issues tab. Any questions should be asked in the Discussions tab.

If you want to share your custom UI component with the community, that's also highly encouraged!
It can even be a cool SwiftUI programming challenge to find a paywall design you like (e.g. from [here](https://www.paywallscreens.com/)) and trying to implement it & sharing with the community.
Corrections to the machine-translated localized texts are welcome, too. Send in a pull request with your corrections.

Note that in order to provide localized texts to over 150 languages in fast & simple way, this library is makes use of [RemafoX](https://remafox.app).
If you want to use it for your custom UI component, download it there – it's fully featured without limits for for open-source projects like this.
To set it up quickly for this project, watch [this short onboarding video](https://to.remafox.app/onboarding).


## FAQ

<details>
<summary>Does FreemiumKit do receipt validation?</summary>
<p>Yes: FreemiumKit is built on top of StoreKit 2 which automatically verifies any transaction is "signed by the App Store for my app for this device" (quote from WWDC22 session "Meet StoreKit 2") before passing them on. It leaves developers the choice to accept even unverified purchases or to ignore them, depending on their business needs. But FreemiumKit doesn't do that, it simply ALWAYS ignores them. When FreemiumKit passes a transaction to the UI component, it has already successfully passed validation. 💯</p>
</details>

<details>
<summary>I can't decide: Should I use a service like RevenueCat or StoreKit directly with this library?</summary>
<p>The purpose of this library is to make integrating with StoreKit 2 as easy as possible. It does this job much better than the SDKs of RevenueCat and the like which don't help with permission checking and don't provide UI components.</p>
<p>The purpose of those services was also to make integrating with StoreKit easier, but that was because StoreKit 1 was much harder to work with and quite limited, too. Apple improved that situation vastly with StoreKit 2 in iOS 15+ so that advantage no longer holds true. But these services not only make things easier for StoreKit 1, they also add a lot of other value, like providing live purchase stats on their site (Connect data is delayed), providing an overview of your total income if you also support other platforms like Android, and much more. If you need any of these things, you might want to use those services. But if the data on App Store Connect is enough for you and all you want is to provide In-App Purchases on Apple platforms in the simplest way possible and you are on iOS 15+ (that's when StoreKit 2 arrived), I recommend FreemiumKit.</p>
</details>

<details>
<summary>Can I use FreemiumKit and services like RevenueCat side-by-side?</summary>
<p>Maybe. It was never the goal of FreemiumKit to be used in combination with those services, but some may want to use the permissions & UI capabilities of FreemiumKit while also profiting from the extra features of such a service. I'm not one of those people though, so I can't provide any support here. It's best you contact those services directly. The license of FreemiumKit allows for them to fork it or copy any code they like into their own SDKs.</p>
</details>


## License

This library is released under the [MIT License](http://opensource.org/licenses/MIT). See LICENSE for details.
