import SwiftUI

struct DetailView: View {
    let exampleType: ExampleType
    @State private var viewModel = DetailViewModel()
    @State private var availabilityService = AvailabilityService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    
                    if !availabilityService.isAvailable && !availabilityService.isChecking {
                        if let reason = availabilityService.unavailabilityReason {
                            UnavailableView(
                                reason: reason,
                                onRetry: {
                                    availabilityService.checkAvailability()
                                },
                                onAction: reason.actionTitle != nil ? {
                                    availabilityService.performAction()
                                } : nil
                            )
                        }
                    } else if viewModel.isLoading && !viewModel.hasContent {
                        loadingView
                    } else if viewModel.hasContent {
                        VStack(spacing: 24) {
                            requestView
                            responseView
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                        )
                    } else {
                        emptyStateView
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
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .task {
                availabilityService.checkAvailability()
                if availabilityService.isAvailable {
                    await executeExample()
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerView: some View {
        VStack(spacing: 16) {
            GradientIcon(
                systemName: exampleType.icon,
                size: 32,
                backgroundSize: 80
            )
            
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
        .largeCardBackground()
    }
    
    private var requestView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                GradientIcon(
                    systemName: "text.bubble",
                    size: 16,
                    backgroundSize: 32
                )
                
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
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)], startPoint: .top, endPoint: .bottom)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    Color(.systemGray4).opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
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
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var responseView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(viewModel.isError ? .red.opacity(0.1) : .green.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: viewModel.isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(viewModel.isError ? .red : .green)
                }
                
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
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            viewModel.isError ?
                            LinearGradient(colors: [.red.opacity(0.05), .red.opacity(0.1)], startPoint: .top, endPoint: .bottom) :
                                LinearGradient(colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)], startPoint: .top, endPoint: .bottom)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    viewModel.isError ? .red.opacity(0.2) : Color(.systemGray4).opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            GradientIcon(
                systemName: exampleType.icon,
                size: 40,
                backgroundSize: 100
            )
            
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
            
            PrimaryButton("Generate", icon: "sparkles") {
                Task {
                    await executeExample()
                }
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .largeCardBackground()
    }
    
    // MARK: - Actions
    
    private func executeExample() async {
        guard availabilityService.isAvailable else { return }
        await viewModel.execute(example: exampleType)
    }
}

#Preview {
    DetailView(exampleType: .basicResponse)
}
