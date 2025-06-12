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
        Text("Explore on-device AI capabilities with Apple's Foundation Models Framework")
            .font(.headline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .glassEffect(in: .rect(cornerRadius: 28))
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
                    GlassEffectContainer(spacing: 0) {
                        VStack(spacing: 16) {
                            Image(systemName: exampleType.icon)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(exampleType.tintColor ?? .blue)

                            VStack(spacing: 4) {
                                Text(exampleType.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)

                                Text(exampleType.subtitle)
                                    .font(.system(size: 11, weight: .regular))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(3)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                        .padding(20)
                    }
                }
            }
            .buttonStyle(.plain)
            .glassEffect(.regular, in: .rect(cornerRadius: 28))
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
