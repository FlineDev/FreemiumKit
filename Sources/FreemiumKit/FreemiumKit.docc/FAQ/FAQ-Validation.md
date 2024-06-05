# Does FreemiumKit validate purchases?

Learn how FreemiumKit deals with validation and how it helps you focus on what's important – your app's features!

@Metadata {
   @TitleHeading("FAQs")
   @PageKind(sampleCode)
}

## Short Answer

Yes, we handle validation automatically and only report purchases that have been verified by the App Store. No action needed on your end, it all happens within our SDK automatically.


## Full Answer

The FreemiumKit SDK is built on top of StoreKit 2, which automatically verifies any transaction is "signed by the App Store for _my_ app for _this_ device" (quote from WWDC22 session [Meet StoreKit 2](https://developer.apple.com/videos/play/wwdc2021/10114/?time=694)). StoreKit 2 leaves developers the choice to accept even unverified purchases. But FreemiumKit doesn't do that, it simply **always** ignores unverified purchases. When FreemiumKit reports a purchase, it has already successfully passed transaction verification. 💯

While StoreKit 2 makes sure a transaction is coming from Apple and has not been tampered with, it's still possible that a highly skilled attacker could tamper with the devices memory or the app logic on a jailbroken device to bypass these checks. It is possible to guard against these kinds of attacks with additional server-side validation and by moving some of the paid feature logic to your servers.

The complexity of such an attack is very high though and most apps are vulnerable to it even with server-side validation receipt validation because the attacker can simply bypass the boolean check inside the apps logic if they have this level of access to your apps code. Protecting against all potential security risks is impossible and we think that the built-in transaction verification is a good level of security for most apps.


## Contact

Have questions or need support? Reach out to me at [freemiumkit@fline.dev](mailto:freemiumkit@fline.dev).

---

## Legal

@Small {
   Cihat Gündüz © 2024. All rights reserved.
   Privacy: No personal data is tracked on this site.
   [Imprint](https://www.fline.dev/imprint/)
}
