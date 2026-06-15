import SwiftUI

struct MoodPickerView: View {
    @Binding var selection: PlantMood?

    var body: some View {
        HStack(spacing: 12) {
            ForEach(PlantMood.allCases) { mood in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                        selection = mood
                    }
                } label: {
                    moodCircle(for: mood)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func moodCircle(for mood: PlantMood) -> some View {
        let isSelected = selection == mood
        Text(mood.emoji)
            .font(.system(size: isSelected ? 40 : 32))
            .frame(width: 56, height: 56)
            .background(
                Circle()
                    .fill(isSelected ? mood.color.opacity(0.25) : Color.clear)
            )
            .overlay(
                Circle()
                    .stroke(isSelected ? mood.color : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.4 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isSelected)
    }
}
