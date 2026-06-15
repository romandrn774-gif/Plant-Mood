import SwiftUI

struct EmptyStateView: View {
    let emoji: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 18) {
            Text(emoji)
                .font(.system(size: 72))
            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppPalette.primaryText)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppPalette.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.body.weight(.semibold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(AppPalette.accent)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
