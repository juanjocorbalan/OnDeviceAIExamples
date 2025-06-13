import SwiftUI

struct ContentView: View {
    @State private var selectedExample: ExampleType?
    @State private var availabilityService = AvailabilityService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection

                    if availabilityService.isAvailable {
                        exampleButtonsView
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
            .navigationTitle("AI Examples")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedExample) { exampleType in
            if exampleType == .interactiveChat {
                ChatView()
            } else {
                DetailView(exampleType: exampleType)
            }
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(.white.opacity(0.4), in: .circle)
                .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))

            Text("Explore on-device AI capabilities with Apple's Foundation Models Framework")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.blue.gradient, in: .rect(cornerRadius: 28))
        .overlay(.regularMaterial.opacity(0.3), in: .rect(cornerRadius: 28))
    }

    private var exampleButtonsView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 20),
            GridItem(.flexible(), spacing: 20)
        ], spacing: 20) {
            ForEach(ExampleType.allCases, id: \.self) { exampleType in
                Button {
                    selectedExample = exampleType
                } label: {
                    VStack(spacing: 16) {
                        Image(systemName: exampleType.icon)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(exampleType.tintColor ?? .blue)
                            .frame(width: 44, height: 44)

                        VStack(spacing: 4) {
                            Text(exampleType.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)

                            Text(exampleType.subtitle)
                                .font(.system(size: 11, weight: .regular))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 140)
                    .padding(20)
                    .background(.thickMaterial, in: .rect(cornerRadius: 28))
                    .overlay(RoundedRectangle(cornerRadius: 28).stroke(.quaternary, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

extension ExampleType {
    var tintColor: Color? {
        switch self {
        case .interactiveChat:
            return .blue
        case .basicResponse:
            return .green
        case .streamingResponse:
            return .orange
        case .structuredGeneration:
            return .purple
        case .customTool:
            return .pink
        }
    }
}

#Preview {
    ContentView()
}
