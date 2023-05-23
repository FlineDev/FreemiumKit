// swiftlint:disable all
// swiftformat:disable all
// swift-format-ignore-file
// AnyLint.skipInFile: All

// This file is maintained by RemafoX (https://remafox.app) – manual edits will be overridden.

import Foundation
import SwiftUI

/// Top-level shortcut for ``Res.Str``. Provides safe access to localized strings. Managed by RemafoX (https://remafox.app).
internal typealias Loc = Res.Str

/// Top-level namespace for safe resource access. Managed by RemafoX (https://remafox.app).
internal enum Res {
   /// Root namespace for safe access to localized strings. Managed by RemafoX (https://remafox.app).
   internal enum Str {
      internal enum FreemiumKit {
         internal enum LoadingProductsFailed {
            /// 🇺🇸 English: "Failed to load products from App Store."
            internal enum Message {
               /// The translated `String` instance.
               internal static var string: String { Bundle.module.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

               /// The SwiftUI `LocalizedStringKey` instance.
               internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

               /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
               internal static var tableLookupKey: String { "FreemiumKit.LoadingProductsFailed.Message" }
            }

            /// 🇺🇸 English: "Reload"
            internal enum ReloadButtonTitle {
               /// The translated `String` instance.
               internal static var string: String { Bundle.module.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable") }

               /// The SwiftUI `LocalizedStringKey` instance.
               internal static var locStringKey: LocalizedStringKey { LocalizedStringKey(self.tableLookupKey) }

               /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
               internal static var tableLookupKey: String { "FreemiumKit.LoadingProductsFailed.ReloadButtonTitle" }
            }
         }

         internal enum SubscriptionPeriod {
            /// 🇺🇸 English (plural case 'other'): "%d days for free"
            internal struct FreeTrialDays {
               internal let count: Int

               internal init(count: Int) {
                  self.count = count
               }

               /// The translated `String` instance.
               internal var string: String {
                  let localizedFormatString = Bundle.module.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                  return String.localizedStringWithFormat(localizedFormatString, self.count)
               }

               /// The SwiftUI `LocalizedStringKey` instance.
               internal var locStringKey: LocalizedStringKey { LocalizedStringKey("FreemiumKit.SubscriptionPeriod.FreeTrialDays(count: \(self.count))") }

               /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
               internal var tableLookupKey: String { "FreemiumKit.SubscriptionPeriod.FreeTrialDays(count: %d)" }
            }

            /// 🇺🇸 English (plural case 'other'): "%d months for free"
            internal struct FreeTrialMonths {
               internal let count: Int

               internal init(count: Int) {
                  self.count = count
               }

               /// The translated `String` instance.
               internal var string: String {
                  let localizedFormatString = Bundle.module.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                  return String.localizedStringWithFormat(localizedFormatString, self.count)
               }

               /// The SwiftUI `LocalizedStringKey` instance.
               internal var locStringKey: LocalizedStringKey { LocalizedStringKey("FreemiumKit.SubscriptionPeriod.FreeTrialMonths(count: \(self.count))") }

               /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
               internal var tableLookupKey: String { "FreemiumKit.SubscriptionPeriod.FreeTrialMonths(count: %d)" }
            }

            /// 🇺🇸 English (plural case 'other'): "%d weeks for free"
            internal struct FreeTrialWeeks {
               internal let count: Int

               internal init(count: Int) {
                  self.count = count
               }

               /// The translated `String` instance.
               internal var string: String {
                  let localizedFormatString = Bundle.module.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                  return String.localizedStringWithFormat(localizedFormatString, self.count)
               }

               /// The SwiftUI `LocalizedStringKey` instance.
               internal var locStringKey: LocalizedStringKey { LocalizedStringKey("FreemiumKit.SubscriptionPeriod.FreeTrialWeeks(count: \(self.count))") }

               /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
               internal var tableLookupKey: String { "FreemiumKit.SubscriptionPeriod.FreeTrialWeeks(count: %d)" }
            }

            /// 🇺🇸 English (plural case 'other'): "%d years for free"
            internal struct FreeTrialYears {
               internal let count: Int

               internal init(count: Int) {
                  self.count = count
               }

               /// The translated `String` instance.
               internal var string: String {
                  let localizedFormatString = Bundle.module.localizedString(forKey: self.tableLookupKey, value: nil, table: "Localizable")
                  return String.localizedStringWithFormat(localizedFormatString, self.count)
               }

               /// The SwiftUI `LocalizedStringKey` instance.
               internal var locStringKey: LocalizedStringKey { LocalizedStringKey("FreemiumKit.SubscriptionPeriod.FreeTrialYears(count: \(self.count))") }

               /// The lookup key in the translation table (= the key in the `.strings` or `.stringsdict` file).
               internal var tableLookupKey: String { "FreemiumKit.SubscriptionPeriod.FreeTrialYears(count: %d)" }
            }
         }
      }
   }
}
