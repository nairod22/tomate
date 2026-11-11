import SwiftUI

/// 44 pt filled capsule button. Ink by default, like the landing-page download button.
struct PrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var color: Color? = nil
    var foreground: Color? = nil
    let action: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let fill = color ?? Theme.ink(scheme)
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage { Image(systemName: systemImage).font(.system(size: 12, weight: .bold)) }
                Text(title).font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(foreground ?? (color == nil ? Theme.onInk(scheme) : .white))
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Capsule().fill(fill))
            .overlay(Capsule().strokeBorder(.white.opacity(0.18), lineWidth: 0.5))
            .contentShape(Capsule())
        }
        .buttonStyle(PressScale())
    }
}
