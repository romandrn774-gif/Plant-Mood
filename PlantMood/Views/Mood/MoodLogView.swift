import SwiftUI
import PhotosUI

struct MoodLogView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: MoodLogViewModel
    private let onSaved: () -> Void

    init(plant: Plant, onSaved: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: MoodLogViewModel(plant: plant))
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text(viewModel.plant.emoji)
                            .font(.system(size: 56))
                        Text("How is \(viewModel.plant.name) feeling?")
                            .font(.title3.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AppPalette.primaryText)
                    }
                    .padding(.top, 8)

                    MoodPickerView(selection: $viewModel.selectedMood)
                        .padding(.vertical, 12)

                    if let mood = viewModel.selectedMood {
                        Text(mood.label)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(mood.color)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .background(mood.color.opacity(0.15))
                            .clipShape(Capsule())
                            .transition(.scale.combined(with: .opacity))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppPalette.secondaryText)
                        TextField("Note... (optional)", text: $viewModel.note, axis: .vertical)
                            .lineLimit(3...6)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(AppPalette.card)
                            )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Photo")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppPalette.secondaryText)
                        if let data = viewModel.photoData, let uiImage = UIImage(data: data) {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                Button {
                                    viewModel.removePhoto()
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.white, .black.opacity(0.6))
                                }
                                .padding(6)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            PhotosPicker(selection: $viewModel.photoItem, matching: .images) {
                                HStack {
                                    Image(systemName: "photo.badge.plus")
                                    Text("Add photo")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(AppPalette.accent.opacity(0.15))
                                .foregroundStyle(AppPalette.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                        }
                    }

                    Button {
                        viewModel.save {
                            onSaved()
                            dismiss()
                        }
                    } label: {
                        Text("Save")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(viewModel.canSave ? AppPalette.accent : AppPalette.accent.opacity(0.3))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.canSave)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(AppPalette.background.ignoresSafeArea())
            .navigationTitle("Mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.large])
    }
}
