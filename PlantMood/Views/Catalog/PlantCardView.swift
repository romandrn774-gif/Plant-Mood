import SwiftUI

struct PlantCardView: View {
    let template: PlantTemplate
    var onAdd: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(AppPalette.accent.opacity(0.18))
                        .frame(width: 64, height: 64)
                    Text(template.emoji)
                        .font(.system(size: 36))
                }
                Spacer()
                if template.isPremium {
                    Label("PRO", systemImage: "crown.fill")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.yellow.opacity(0.25))
                        .foregroundStyle(Color(hex: "#8A6A00"))
                        .clipShape(Capsule())
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.headline)
                    .foregroundStyle(AppPalette.primaryText)
                Text(template.species)
                    .font(.caption)
                    .foregroundStyle(AppPalette.secondaryText)
                    .italic()
            }

            Text(template.description)
                .font(.caption)
                .foregroundStyle(AppPalette.primaryText.opacity(0.85))
                .lineLimit(3)

            HStack(spacing: 8) {
                Tag(icon: "sun.max.fill", text: template.lightRequirement)
                Tag(icon: "leaf.fill", text: template.careLevel)
            }

            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                    Text("Every \(template.defaultWateringIntervalDays) days")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppPalette.waterBlue)
                Spacer()
                if let onAdd {
                    Button(action: onAdd) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Add")
                        }
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppPalette.accent)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppPalette.card)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

private struct Tag: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption2.weight(.semibold))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(AppPalette.accent.opacity(0.12))
        .foregroundStyle(AppPalette.accent)
        .clipShape(Capsule())
    }
}
