import SwiftUI

/// A button showing a localized "Restore Purchases" text, that handles the logic of triggering a restore and showing a progress view while loading automatically.
public struct RestorePurchasesButton<ProductID: RawRepresentableProductID>: View {
   let inAppPurchase: InAppPurchase<ProductID>
   let onRestoreStarted: () -> Void
   let onRestoreCompleted: () -> Void

   @State
   var restoreInProgress: Bool = false
   

   public init(
      inAppPurchase: InAppPurchase<ProductID>,
      onRestoreStarted: @escaping () -> Void = {},
      onRestoreCompleted: @escaping () -> Void = {}
   ) {
      self.inAppPurchase = inAppPurchase
      self.onRestoreStarted = onRestoreStarted
      self.onRestoreCompleted = onRestoreCompleted
   }

   public var body: some View {
      Button {
         self.restoreInProgress = true
         self.onRestoreStarted()
         Task {
            await self.inAppPurchase.loadCurrentEntitlements()
            self.restoreInProgress = false
            self.onRestoreCompleted()
         }
      } label: {
         if self.restoreInProgress {
            ProgressView()
         } else {
            Text(Loc.FreemiumKit.RestorePurchasesButton.Title.string)
         }
      }
      .disabled(self.restoreInProgress)
   }
}

#if DEBUG
struct RestorePurchases_Previews: PreviewProvider {
   private enum ProductID: String, CaseIterable, RawRepresentableProductID {
      case pro
      case lite
   }

   static var previews: some View {
      RestorePurchasesButton(inAppPurchase: InAppPurchase<ProductID>())
   }
}
#endif
