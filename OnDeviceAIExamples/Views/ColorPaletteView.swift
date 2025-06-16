import SwiftUI

struct ColorPaletteView: View {
    @State private var viewModel = ColorPaletteViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    colorPickerSection
                    generateButton

                    if viewModel.isGenerating {
                        loadingSection
                    } else if let palette = viewModel.generatedPalette {
                        PaletteCard(palette: palette)
                    } else if !viewModel.errorMessage.isEmpty {
                        errorSection
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                        .buttonStyle(.glass)
                }
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(.white.opacity(0.4), in: .circle)
                .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))

            VStack(spacing: 8) {
                Text("Color Palette Generator")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("Select a base color and generate harmonious color palettes")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.purple.gradient, in: .rect(cornerRadius: 28))
        .overlay(.regularMaterial.opacity(0.3), in: .rect(cornerRadius: 28))
    }

    // MARK: - Color Picker Section

    private var colorPickerSection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                Text("Base Color")
                    .font(.headline)

                Spacer()

                ColorPicker("", selection: $viewModel.selectedColor, supportsOpacity: false)
                    .labelsHidden()

                Text(viewModel.selectedColor.hexString)
                    .font(.caption)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: Capsule())
            }

            HStack(spacing: 12) {
                Text("Harmony Type")
                    .font(.headline)

                Spacer()

                Picker("Harmony Type", selection: $viewModel.selectedHarmonyType) {
                    ForEach(ColorPalette.HarmonyType.allCases, id: \.self) { harmony in
                        Text(harmony.displayName).tag(harmony)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .padding(24)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        Button {
            Task {
                await viewModel.generatePalette()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 24, weight: .medium))

                Text("Generate Palette")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
        }
        .glassEffect(.regular.tint(.purple.opacity(0.6)).interactive())
        .disabled(viewModel.isGenerating)
    }

    // MARK: - Loading Section

    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Generating color palette...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    // MARK: - Error Section

    private var errorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.red)
                    .frame(width: 32, height: 32)
                    .background(.red.opacity(0.2), in: .circle)
                    .overlay(Circle().stroke(.red.opacity(0.3), lineWidth: 1))

                Text("Error")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Spacer()
            }

            Text(viewModel.errorMessage)
                .font(.body)
                .foregroundStyle(.red)
                .textSelection(.enabled)
                .padding(16)
                .background(.quaternary, in: .rect(cornerRadius: 16))
        }
        .padding(16)
        .background(.regularMaterial, in: .rect(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.separator.opacity(0.5), lineWidth: 0.5))
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }
}

// MARK: - Palette Card View

struct PaletteCard: View {
    let palette: ColorPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(palette.name)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text(palette.harmony.displayName)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.quaternary, in: Capsule())
                }

                Spacer()

                Button {
                    copyPaletteToClipboard()
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 24, weight: .medium))
                }
                .buttonStyle(.glass)
            }

            // Description
            Text(palette.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Color Swatches
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(palette.colors.indices, id: \.self) { index in
                    ColorSwatch(colorInfo: palette.colors[index])
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    private func copyPaletteToClipboard() {
        let paletteText = palette.colors.map { "\($0.name): \($0.hex)" }.joined(separator: "\n")
        UIPasteboard.general.string = paletteText
    }
}

// MARK: - Color Swatch View

struct ColorSwatch: View {
    let colorInfo: ColorPalette.ColorInfo

    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 16)
                .fill(colorInfo.swiftUIColor)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.quaternary, lineWidth: 1)
                )

            VStack(spacing: 2) {
                Text(colorInfo.name)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(colorInfo.hex)
                    .font(.caption2)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.secondary)
            }
        }
        .onTapGesture {
            UIPasteboard.general.string = colorInfo.hex
        }
    }
}

#Preview {
    ColorPaletteView()
}
