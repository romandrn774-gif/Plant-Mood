import SwiftUI

struct PlantAvatarView: View {
    let emoji: String
    let mood: PlantMood?
    var size: CGFloat = 80

    var body: some View {
        ZStack {
            Circle()
                .fill((mood?.color ?? AppPalette.accent).opacity(0.18))
                .frame(width: size * 1.3, height: size * 1.3)
            Text(emoji)
                .font(.system(size: size))
        }
    }
}
