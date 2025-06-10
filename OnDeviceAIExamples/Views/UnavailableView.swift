import SwiftUI

struct UnavailableView: View {
    let reason: AvailabilityService.UnavailabilityReason
    let onRetry: () -> Void
    let onAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 32) {
            iconSection
            textSection
            buttonSection
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .applyShadow(Shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6))
        )
        .padding(.horizontal, 20)
    }
    
    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.errorGradient)
                .frame(width: 100, height: 100)
            
            Image(systemName: iconName)
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(DesignSystem.errorPrimaryGradient)
        }
    }
    
    private var textSection: some View {
        VStack(spacing: 12) {
            Text(reason.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            
            Text(reason.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
    }
    
    private var buttonSection: some View {
        VStack(spacing: 16) {
            if let actionTitle = reason.actionTitle, let onAction = onAction {
                PrimaryButton(actionTitle, icon: "gear") {
                    onAction()
                }
            }
            
            SecondaryButton("Check Again", icon: "arrow.clockwise") {
                onRetry()
            }
        }
    }
    
    private var iconName: String {
        switch reason {
        case .deviceNotEligible:
            return "iphone.slash"
        case .appleIntelligenceNotEnabled:
            return "brain"
        case .modelNotReady:
            return "icloud.and.arrow.down"
        case .systemVersionTooOld:
            return "arrow.up.circle.fill"
        case .unknown:
            return "exclamationmark.triangle.fill"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        UnavailableView(
            reason: .appleIntelligenceNotEnabled,
            onRetry: {},
            onAction: {}
        )
        
        UnavailableView(
            reason: .deviceNotEligible,
            onRetry: {},
            onAction: nil
        )
    }
    .background(Color(.systemGroupedBackground))
}
