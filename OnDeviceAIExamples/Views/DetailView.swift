import SwiftUI

struct DetailView: View {
    let exampleType: ExampleType
    @State private var viewModel = DetailViewModel()
    @State private var availabilityService = AvailabilityService()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
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
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.glass)
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
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    private var requestView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "text.bubble")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)

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
                .padding(20)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
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
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    private var responseView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: viewModel.isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(viewModel.isError ? .red : .green)
                    .frame(width: 32, height: 32)

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
                .padding(20)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: exampleType.icon)
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(exampleType.tintColor ?? .blue)
                .frame(width: 100, height: 100)

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
                Label("Generate", systemImage: "sparkles")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.glass)
            .controlSize(.large)
            .tint(.blue)
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    // MARK: - Actions

    private func executeExample() async {
        await viewModel.execute(example: exampleType)
    }
}

#Preview {
    DetailView(exampleType: .basicResponse)
}
