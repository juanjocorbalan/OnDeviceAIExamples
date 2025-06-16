import SwiftUI

struct DetailView: View {
    let exampleType: ExampleType
    @State private var viewModel = DetailViewModel()
    @State private var availabilityService = AvailabilityService()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerView

                    if availabilityService.isAvailable {
                        if viewModel.isLoading && !viewModel.hasContent {
                            loadingView
                        } else if viewModel.hasContent {
                            VStack(spacing: 16) {
                                requestView
                                responseView
                            }
                        } else {
                            emptyStateView
                        }
                    } else if let reason = availabilityService.unavailabilityReason {
                        UnavailableView(
                            reason: reason,
                            onAction: reason.actionTitle != nil ? {
                                availabilityService.performAction()
                            } : nil
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                }
            }
            .task {
                if availabilityService.isAvailable {
                    await executeExample()
                }
            }
        }
    }

    // MARK: - View Components

    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: exampleType.icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(.white.opacity(0.4), in: .circle)
                .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))

            VStack(spacing: 8) {
                Text(exampleType.rawValue)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text(exampleType.subtitle)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background((exampleType.tintColor ?? .blue).gradient, in: .rect(cornerRadius: 28))
        .overlay(.regularMaterial.opacity(0.3), in: .rect(cornerRadius: 28))
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(.blue.opacity(0.3), lineWidth: 3)
                    .frame(width: 60, height: 60)

                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.blue)
            }

            Text("Generating response...")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(24)
        .background(.regularMaterial, in: .rect(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.separator.opacity(0.5), lineWidth: 0.5))
    }

    private var requestView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "text.bubble")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)
                    .background(.blue.opacity(0.2), in: .circle)
                    .overlay(Circle().stroke(.blue.opacity(0.3), lineWidth: 1))

                Text("Request")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Spacer()
            }

            Text(exampleType.prompt)
                .font(.body)
                .foregroundStyle(.primary)
                .textSelection(.enabled)
                .padding(16)
                .background(.quaternary, in: .rect(cornerRadius: 16))
        }
        .padding(16)
        .background(.regularMaterial, in: .rect(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.separator.opacity(0.5), lineWidth: 0.5))
    }

    private var responseView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: viewModel.isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(viewModel.isError ? .red : .green)
                    .frame(width: 32, height: 32)
                    .background((viewModel.isError ? Color.red : Color.green).opacity(0.2), in: .circle)
                    .overlay(Circle().stroke((viewModel.isError ? Color.red : Color.green).opacity(0.3), lineWidth: 1))

                Text(viewModel.isError ? "Error" : "Response")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Spacer()
            }

            Text(viewModel.displayText)
                .font(.body)
                .foregroundStyle(viewModel.isError ? .red : .primary)
                .textSelection(.enabled)
                .padding(16)
                .background(.quaternary, in: .rect(cornerRadius: 16))
        }
        .padding(16)
        .background(.regularMaterial, in: .rect(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.separator.opacity(0.5), lineWidth: 0.5))
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: exampleType.icon)
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(exampleType.tintColor ?? .blue)
                .frame(width: 100, height: 100)
                .background((exampleType.tintColor ?? .blue).opacity(0.2), in: .circle)
                .overlay(Circle().stroke((exampleType.tintColor ?? .blue).opacity(0.3), lineWidth: 1))

            VStack(spacing: 8) {
                Text("Ready to generate")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Text("Tap the button below to start AI generation")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Generate", systemImage: "sparkles") {
                Task { await executeExample() }
            }
            .buttonStyle(.glass)
            .controlSize(.large)
            .tint(.blue)
        }
        .padding(24)
        .background(.regularMaterial, in: .rect(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.separator.opacity(0.5), lineWidth: 0.5))
    }

    // MARK: - Actions

    private func executeExample() async {
        await viewModel.execute(example: exampleType)
    }
}

#Preview {
    DetailView(exampleType: .basicResponse)
}
