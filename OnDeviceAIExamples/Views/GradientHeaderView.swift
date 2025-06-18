import SwiftUI

struct GradientHeaderView: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: AnyGradient
    
    init(icon: String, title: String, subtitle: String, color: Color = .blue) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.gradient = color.gradient
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(.white.opacity(0.4), in: .circle)
                .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))

            VStack(spacing: 8) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(gradient, in: .rect(cornerRadius: 28))
        .overlay(.regularMaterial.opacity(0.3), in: .rect(cornerRadius: 28))
    }
}
