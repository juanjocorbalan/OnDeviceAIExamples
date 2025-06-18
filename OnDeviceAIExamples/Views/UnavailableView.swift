import SwiftUI

struct UnavailableView: View {
    let reason: AvailabilityService.UnavailabilityReason
    let onAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 32) {
            GradientHeaderView(
                icon: reason.icon,
                title: reason.title,
                subtitle: reason.description,
                color: .orange
            )
            
            if let actionTitle = reason.actionTitle, let onAction = onAction {
                Button(actionTitle) { onAction() }
                    .buttonStyle(.glass)
                    .controlSize(.large)
            }
        }
    }
}

#Preview {
    UnavailableView(
        reason: .appleIntelligenceNotEnabled,
        onAction: {}
    )
    .padding(.horizontal)
}

#Preview {
    UnavailableView(
        reason: .deviceNotEligible,
        onAction: nil
    )
    .padding(.horizontal)
}
