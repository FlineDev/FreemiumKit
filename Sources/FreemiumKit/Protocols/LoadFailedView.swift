import SwiftUI

public protocol LoadFailedView: View {
   init(reloadButtonTitle: LocalizedStringKey, loadFailedMessage: LocalizedStringKey, reloadPressed: () -> Void)
}
