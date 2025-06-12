import SwiftUI

struct BubbleView: View {
    let message: ChatMessage
    let isTyping: Bool
    
    @State private var isAnimating = false
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                userBubble
            } else {
                assistantBubble
                Spacer()
            }
        }
        .padding(.vertical, 6)
    }
    
    private var userBubble: some View {
        Text(message.text)
            .font(.body)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.blue.gradient)
            .clipShape(
                .rect(
                    topLeadingRadius: 16,
                    bottomLeadingRadius: 16,
                    bottomTrailingRadius: 4,
                    topTrailingRadius: 16
                )
            )
    }
    
    private var assistantBubble: some View {
        Group {
            if message.text.isEmpty && isTyping {
                typingIndicator
            } else {
                Text(message.text)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .background(.orange.gradient.opacity(0.3))
                    .clipShape(
                        .rect(
                            topLeadingRadius: 16,
                            bottomLeadingRadius: 4,
                            bottomTrailingRadius: 16,
                            topTrailingRadius: 16
                        )
                    )
            }
        }
    }
    
    private var typingIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(.secondary)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .padding(.horizontal, 16)
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        BubbleView(
            message: ChatMessage(isUser: true, text: "Hello! Can you help me with something?"),
            isTyping: false
        )
        
        BubbleView(
            message: ChatMessage(isUser: false, text: "Of course! I'd be happy to help you. What would you like to know about?"),
            isTyping: false
        )
        
        BubbleView(
            message: ChatMessage(isUser: false, text: ""),
            isTyping: true
        )
    }
    .padding()
}
