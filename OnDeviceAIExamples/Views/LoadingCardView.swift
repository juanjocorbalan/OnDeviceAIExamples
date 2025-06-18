import SwiftUI

struct LoadingCardView: View {
    let message: String
    let accentColor: Color
    
    init(message: String, accentColor: Color = .blue) {
        self.message = message
        self.accentColor = accentColor
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(accentColor.opacity(0.3), lineWidth: 3)
                    .frame(width: 60, height: 60)

                ProgressView()
                    .scaleEffect(1.5)
                    .tint(accentColor)
            }

            Text(message)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(24)
        .background(.regularMaterial, in: .rect(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.separator.opacity(0.5), lineWidth: 0.5))
    }
}