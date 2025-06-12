import SwiftUI

struct DetailView: View {
    let exampleType: ExampleType
    @State private var viewModel = DetailViewModel()
    @State private var availabilityService = AvailabilityService()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                GlassEffectContainer(spacing: 20) {
                    VStack(spacing: 20) {
                        headerView

                        if availabilityService.isAvailable {
                            if viewModel.isLoading && !viewModel.hasContent {
                                loadingView
                            } else if viewModel.hasContent {
                                VStack(spacing: 20) {
                                    requestView
                                    responseView
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity)
                                .glassEffect(in: .rect(cornerRadius: 20))
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
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.secondary)
                            .glassEffect()
                    }
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
                .foregroundStyle(exampleType.tintColor ?? .blue)
                .frame(width: 80, height: 80)
                .glassEffect(in: .circle)

            VStack(spacing: 8) {
                Text(exampleType.rawValue)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text(exampleType.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .glassEffect(in: .rect(cornerRadius: 20))
    }

    private var requestView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "text.bubble")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)
                    .glassEffect(in: .circle)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Request")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text("Prompt sent to the model")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Text(exampleType.prompt)
                .font(.body)
                .foregroundStyle(.primary)
                .textSelection(.enabled)
                .padding(20)
                .glassEffect(in: .rect(cornerRadius: 16))
        }
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

            VStack(spacing: 8) {
                Text("Generating response...")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Text("AI is processing your request")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .glassEffect(in: .rect(cornerRadius: 16))
    }

    private var responseView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: viewModel.isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(viewModel.isError ? .red : .green)
                    .frame(width: 32, height: 32)
                    .glassEffect(in: .circle)

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.isError ? "Error" : "Response")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(viewModel.isError ? "Something went wrong" : "AI generated successfully")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Text(viewModel.displayText)
                .font(.body)
                .foregroundStyle(viewModel.isError ? .red : .primary)
                .textSelection(.enabled)
                .padding(20)
                .glassEffect(in: .rect(cornerRadius: 16))
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: exampleType.icon)
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(exampleType.tintColor ?? .blue)
                .frame(width: 100, height: 100)
                .glassEffect(in: .circle)

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

            Button {
                Task {
                    await executeExample()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .medium))
                    Text("Generate")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(.blue.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .glassEffect(in: .rect(cornerRadius: 20))
    }

    // MARK: - Actions

    private func executeExample() async {
        await viewModel.execute(example: exampleType)
    }
}

#Preview {
    DetailView(exampleType: .basicResponse)
}
