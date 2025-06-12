import SwiftUI

struct UnavailableView: View {
    let reason: AvailabilityService.UnavailabilityReason
    let onAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 32) {
            iconSection
            textSection
            buttonSection
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .glassEffect(in: .rect(cornerRadius: 24))
    }

    private var iconSection: some View {
        Image(systemName: reason.icon)
            .font(.system(size: 40, weight: .medium))
            .foregroundStyle(.orange)
            .frame(width: 100, height: 100)
            .glassEffect(in: .circle)
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
                Button(actionTitle) {
                    onAction()
                }
                .buttonStyle(.glass)
                .controlSize(.large)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        UnavailableView(
            reason: .appleIntelligenceNotEnabled,
            onAction: {}
        )

        UnavailableView(
            reason: .deviceNotEligible,
            onAction: nil
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
