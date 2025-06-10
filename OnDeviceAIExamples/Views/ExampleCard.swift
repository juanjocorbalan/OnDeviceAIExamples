import SwiftUI

struct ExampleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            cardContent
        }
        .buttonStyle(.plain)
    }
    
    private var cardContent: some View {
        VStack(spacing: 16) {
            iconView
            textContent
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .padding(20)
        .background(backgroundView)
        .overlay(borderOverlay)
    }
    
    private var iconView: some View {
        GradientIcon(systemName: icon)
    }
    
    private var textContent: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text(subtitle)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: DesignSystem.cornerRadius)
            .fill(DesignSystem.cardGradient)
            .applyShadow(DesignSystem.cardShadow)
    }
    
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: DesignSystem.cornerRadius)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        Color(.systemGray4).opacity(0.3),
                        Color(.systemGray5).opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
}

#Preview {
    ScrollView {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 20) {
            ExampleCard(
                title: "Basic Chat",
                subtitle: "Simple conversation with the model",
                icon: "message"
            ) {
                // Preview action
            }
            
            ExampleCard(
                title: "Tool Calling",
                subtitle: "Use custom tools with the model for enhanced functionality",
                icon: "wrench.and.screwdriver"
            ) {
                // Preview action
            }
            
            ExampleCard(
                title: "Creative Writing",
                subtitle: "Generate story outlines and narratives",
                icon: "pencil.and.outline"
            ) {
                // Preview action
            }
            
            ExampleCard(
                title: "Business Ideas",
                subtitle: "Generate startup concepts and business plans",
                icon: "lightbulb"
            ) {
                // Preview action
            }
        }
        .padding(.horizontal, 20)
    }
    .background(Color(.systemGroupedBackground))
}
