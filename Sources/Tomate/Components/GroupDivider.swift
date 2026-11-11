import SwiftUI

struct GroupDivider: View {
    @Environment(\.colorScheme) private var scheme
    var body: some View {
        Rectangle().fill(Theme.separator(scheme)).frame(height: 1).padding(.horizontal, 12)
    }
}
