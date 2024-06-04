# FreemiumKit

Simple In-App Purchases and Subscriptions for Apple Platforms:
Automation, Paywalls, A/B Testing, Live Notifications, PPP, and more. 

@Metadata {
   @TechnologyRoot
   @PageImage(purpose: icon, source: "FreemiumKit")
   @TitleHeading("Welcome to")
   @PageKind(article)
   @CallToAction(url: "https://apps.apple.com/app/apple-store/id6502914189?pt=549314&ct=freemiumkit.app&mt=8", purpose: link, label: "Get on App Store")
}


## Overview

![FreemiumKit Logo](path/to/logo.png)

FreemiumKit is the ultimate solution for Apple platform developers to integrate and manage in-app purchases and subscriptions effortlessly. With support for all Apple platforms, FreemiumKit provides a seamless and efficient way to handle your app's monetization.

![Hero Image](path/to/hero-image.png)

## Key Features

### Quick Setup
- **Automated Creation:** FreemiumKit connects to App Store Connect on your behalf and automates all the steps in creating your products, saving you a lot of click & wait.
- **Customizable Paywalls:** Our SDK contains a paywall UI engine for all Apple platforms with beautiful, proven and ready-to-use designs.
- **Remote Configuration:** Manage and update paywalls remotely through our native app – on the Mac or even from your iPhone!

![Feature Image 1](path/to/feature-image1.png)

### Advanced Monetization Tools
- **A/B Testing:** Optimize your paywalls and pricing with built-in A/B testing capabilities. Compare up to 4 paywall designs!
- **Live Purchase Push Notifications:** Receive real-time notifications for user purchases to stay on top of your app's performance.
- **Pricing by Purchase Power Parity:** Adjust pricing based on the user's location to maximize revenue and accessibility.

![Feature Image 2](path/to/feature-image2.png)

### Native Experience
- **Full Apple Platform Support:** Seamlessly integrate with iOS, macOS, watchOS, visionOS, and tvOS.
- **Simplified Usage:** Our native-first approach ensures an easy and efficient setup process, allowing you to focus on building your app.
- **Privacy by Design:** Our SDK avoids sending personal user data to any servers. And we don't keep your purchase data on our servers.

![Feature Image 3](path/to/feature-image3.png)


## FreemiumKit vs. RevenueCat

When choosing a solution for managing in-app purchases and subscriptions, it's important to understand the differences between FreemiumKit and RevenueCat.

| Feature                        | FreemiumKit                                           | RevenueCat                     |
|--------------------------------|-------------------------------------------------------|--------------------------------|
| **Quick Setup**                | ✅ (automated creation of products on Connect)        | ❌                             |
| **Real-Time Notifications**    | ✅ (push notifications sent to native iPhone app)     | ❌ (only webhooks)             |
| **Skip Renewal Notifications** | ✅ (reports purchases & **new** subscriptions)        | ❌                             |
| **Paywalls**                   | ✅ (on all Apple Platforms, even visionOS!)           | 🚧 (only iOS)                  |
| **Receipt Validation**         | ✅ (using StoreKit 2)                                 | ✅                             |
| **A/B Testing**                | ✅ (fast setup to test up to 4 designs in parallel)   | ✅ (but a lot of work)         |
| **Native App**                 | ✅ (on all Apple Platforms)                           | ❌                             |
| **Purchases Dashboard**        | ✅ (in native app)                                    | ✅ (only Web)                  |
| **Purchase Power Parity**      | ✅ (adjustable slider to mix with Apple prices)       | ❌                             |
| **Scalable**                   | ✅ (CDN for remote config, purchases in iCloud)       | ✅ (higher price)              |
| **User Privacy**               | ✅ (no personal data sent, server temporary storage)  | ❌ (lots of data)              |
| **Supports Apple Platforms**   | ✅ (including visionOS)                               | ✅ (including visionOS)        |
| **Supports Android & Web**     | ❌                                                    | ✅                             |
| **Pricing**                    | Freemium, paid tier **below 1%** of Revenue           | Freemium, paid tier exactly 1% of Revenue |

> Tip: If you need RevenueCat for combined stats (with Android) or for their 3rd-party integrations, you can set RevenueCat to Observer mode and still use FreemiumKit for paywalls, live notifications etc.


## Pricing

FreemiumKit is **completely free to use** at the moment for everyone.

In the future, only developers with more than $500 monthly income on App Store Connect will need to pay, and always less than 1% of their proceeds. The full planned pricing table:

@Row {
   @Column {
      | Monthly Income        | Cost     |
      |-----------------------|----------|
      | $0 - $500             | Free     |
      | $500 - $1k            | $5/mo    |
      | $1k - $2k             | $10/mo   |
      | $2k - $4.5k           | $20/mo   |
      | $4.5k - $7.5k         | $45/mo   |
   }

   @Column {
      | Monthly Income        | Cost      |
      |-----------------------|---------- |
      | $7.5k - $15k          | $75/mo    |
      | $15k - $30k           | $150/mo   |
      | $30k - $50k           | $300/mo   |
      | $50k - $100k          | $500/mo   |
      | $100k+                | $1,000/mo |
   }
}


## Get Started

Ready to take your app's monetization to the next level? Download FreemiumKit today and start experiencing the benefits of simplified and powerful in-app purchases & subscriptions.

[Download Now](https://apps.apple.com/app/apple-store/id6502914189?pt=549314&mt=8&ct=freemiumkit.app)

![Get Started Image](path/to/get-started-image.png)


## SDK Setup Guide

For a detailed walkthrough on how to integrate the FreemiumKit SDK into your app, check out our [SDK Setup Guide](doc:SetupGuide).


## Testimonials

@Row {
   @Column {
      ![Testimonial Image](path/to/testimonial-image.png)
      
      > Jane Doe, Developer: FreemiumKit has transformed the way we handle in-app purchases. The setup was incredibly easy, and the features are exactly what we needed!
   }
   
   @Column {
      ![Testimonial Image](path/to/testimonial-image.png)
      
      > Jane Doe, Developer: FreemiumKit has transformed the way we handle in-app purchases. The setup was incredibly easy, and the features are exactly what we needed!
   }
}


## FAQ

The top 5 most frequently asked questions:

@Links(visualStyle: list) {
   - <doc:FAQ-One>
   - <doc:FAQ-Two>
   - <doc:FAQ-Three>
}

Visit the [Frequently Asked Questions](doc:FAQs) page for the full list of questions & answers.

## Contact

Have questions or need support? Reach out to me at [freemiumkit@fline.dev](mailto:freemiumkit@fline.dev).

---

@Small {
   Cihat Gündüz © 2024. All rights reserved.
}
