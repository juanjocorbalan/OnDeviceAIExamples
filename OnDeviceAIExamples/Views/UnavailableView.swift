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
        .padding(24)
        .background(.orange.gradient, in: .rect(cornerRadius: 28))
        .overlay(.regularMaterial.opacity(0.3), in: .rect(cornerRadius: 28))
    }

    private var iconSection: some View {
        Image(systemName: reason.icon)
            .font(.system(size: 40, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 100, height: 100)
            .background(.white.opacity(0.4), in: .circle)
            .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))
    }

    private var textSection: some View {
        VStack(spacing: 12) {
            Text(reason.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(reason.description)
                .font(.body)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
    }

    private var buttonSection: some View {
        Group {
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
