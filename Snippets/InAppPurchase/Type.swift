// Giving an overview of the ``InAppPurchase`` type.

// snippet.hide
import FreemiumKit
import SwiftUI

// snippet.show
enum ProductID: String, Purchasable {
   case proYearly = "dev.fline.TwootIt.Pro.Yearly"
   case proMonthly = "dev.fline.TwootIt.Pro.Monthly"
   case liteYearly = "dev.fline.TwootIt.Lite.Yearly"
   case liteMonthly = "dev.fline.TwootIt.Lite.Monthly"
}

enum LockedFeature: Unlockable {
   case twitterPostsPerDay
   case extendedAttachments
   case scheduledPosts
   func permission(purchasedProductIDs: Set<ProductID>) -> Permission {
      // ...
   }
}

let iap = InAppPurchase<ProductID, LockedFeature>  // <= on app start

// snippet.hide
struct SampleView: View {
   var body: some View {
      // snippet.show
      Button(...).disabled(iap.permission(for: .twitterPostsPerDay).isGranted(current: 1))  // <= in SwiftUI
      Button(...).disabled(iap.permission(for: .twitterPosts).isUnlimited)  // <= in SwiftUI
      Button(...).disabled(iap.permission(for: .twitterPosts).isUnlimited)  // <= in SwiftUI
      // snippet.hide
   }
}
