import SwiftUI

struct DetailView: View {
    let exampleType: ExampleType
    @State private var viewModel = DetailViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    GradientHeaderView(
                        icon: exampleType.icon,
                        title: exampleType.rawValue,
                        subtitle: exampleType.subtitle,
                        color: exampleType.tintColor ?? .blue
                    )

                    if viewModel.isLoading && !viewModel.hasContent {
                        LoadingCardView(message: "Generating response...")
                    } else if viewModel.showErrorAlert {
                        ErrorCardView(message: viewModel.errorMessage) {
                            viewModel.resetError()
                            Task { await executeExample() }
                        }
                    } else if viewModel.hasContent {
                        VStack(spacing: 16) {
                            requestView
                            responseView
                        }
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
                await executeExample()
            }
        }
    }

    // MARK: - View Components

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
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.green)
                    .frame(width: 32, height: 32)
                    .background(.green.opacity(0.2), in: .circle)
                    .overlay(Circle().stroke(.green.opacity(0.3), lineWidth: 1))

                Text("Response")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Spacer()
            }

            Text(viewModel.response)
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

    private var emptyStateView: some View {
        Button("Try again", systemImage: "sparkles") {
            Task { await executeExample() }
        }
        .buttonStyle(.glass)
        .padding(24)
    }

    // MARK: - Actions

    private func executeExample() async {
        await viewModel.execute(example: exampleType)
    }
}

#Preview {
    DetailView(exampleType: .basicResponse)
}
