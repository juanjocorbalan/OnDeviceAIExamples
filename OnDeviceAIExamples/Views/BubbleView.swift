import SwiftUI

struct BubbleView: View {
    let message: ChatMessage
    let isResponding: Bool
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding(12)
                    .foregroundColor(.white)
                    .background(DesignSystem.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .applyShadow(DesignSystem.cardShadow)
                
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    if message.text.isEmpty && isResponding {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: 30, height: 30)
                    } else {
                        Text(message.text)
                            .padding(12)
                            .foregroundColor(.white)
                            .background(DesignSystem.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .applyShadow(DesignSystem.cardShadow)
                            .textSelection(.enabled)
                    }
                }
                .padding(.vertical, 8)
                Spacer()
            }
        }
        .padding(.vertical, 6)
    }
}
