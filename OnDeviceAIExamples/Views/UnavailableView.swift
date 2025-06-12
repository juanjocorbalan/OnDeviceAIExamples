import SwiftUI

struct UnavailableView: View {
    let reason: AvailabilityService.UnavailabilityReason
    let onAction: (() -> Void)?

    var body: some View {
        GlassEffectContainer(spacing: 0) {
            VStack(spacing: 32) {
                iconSection
                textSection
                buttonSection
            }
            .frame(maxWidth: .infinity)
            .padding(40)
            .background(.orange.gradient.opacity(0.3))
            .clipShape(.rect(cornerRadius: 20))
        }
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
                .multilineTextAlignment(.center)

            Text(reason.description)
                .font(.body)
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
