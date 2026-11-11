import SwiftUI

/// "− 45 +" field with a caption.
struct NumberStepper: View {
    let label: String
    let accessibilityName: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.secondaryText(scheme))
            HStack(spacing: 0) {
                stepButton("−", "Diminuer \(accessibilityName)") { value = max(range.lowerBound, value - 1) }
                Text("\(value)")
                    .font(.system(size: 13, weight: .semibold).monospacedDigit())
                    .frame(maxWidth: .infinity)
                stepButton("+", "Augmenter \(accessibilityName)") { value = min(range.upperBound, value + 1) }
            }
            .frame(height: 32)
            .background(RoundedRectangle(cornerRadius: Theme.Radius.field).fill(Theme.field(scheme)))
            .overlay(RoundedRectangle(cornerRadius: Theme.Radius.field).strokeBorder(Theme.fieldStroke(scheme), lineWidth: 1))
        }
    }

    private func stepButton(_ symbol: String, _ a11y: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(symbol)
                .font(.system(size: 15))
                .frame(width: 24, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .buttonRepeatBehavior(.enabled)
        .accessibilityLabel(a11y)
    }
}
