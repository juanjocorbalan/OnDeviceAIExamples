import SwiftUI

struct ContentView: View {
    @State private var selectedExample: ExampleType?
    @State private var availabilityService = AvailabilityService()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    
                    if availabilityService.isChecking {
                        loadingSection
                    } else if availabilityService.isAvailable {
                        exampleButtonsView
                    } else if let reason = availabilityService.unavailabilityReason {
                        unavailableSection(reason: reason)
                    }
                }
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("AI Examples")
        }
        .sheet(item: $selectedExample) { exampleType in
            DetailView(exampleType: exampleType)
        }
        .task {
            availabilityService.checkAvailability()
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        Text("Explore on-device AI capabilities with Apple's Foundation Models Framework")
            .font(.headline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .padding(16)
            .frame(maxWidth: .infinity)
            .cardBackground()
            .padding(.horizontal, 20)
    }
    
    private var exampleButtonsView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 20) {
            ForEach(ExampleType.allCases, id: \.self) { exampleType in
                ExampleCard(
                    title: exampleType.rawValue,
                    subtitle: exampleType.subtitle,
                    icon: exampleType.icon
                ) {
                    selectedExample = exampleType
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var loadingSection: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.blue)
            
            VStack(spacing: 8) {
                Text("Checking Availability")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text("Verifying Foundation Models support...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity)
        .cardBackground()
        .padding(.horizontal, 20)
    }
    
    private func unavailableSection(reason: AvailabilityService.UnavailabilityReason) -> some View {
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
    
}

#Preview {
    ContentView()
}
