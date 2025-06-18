import SwiftUI

struct ErrorCardView: View {
    let message: String
    let onRetry: (() -> Void)?
    
    init(message: String, onRetry: (() -> Void)? = nil) {
        self.message = message
        self.onRetry = onRetry
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.red)
                    .frame(width: 32, height: 32)
                    .background(.red.opacity(0.2), in: .circle)
                    .overlay(Circle().stroke(.red.opacity(0.3), lineWidth: 1))

                Text("Error")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Spacer()
                
                if let onRetry = onRetry {
                    Button("Retry", systemImage: "arrow.clockwise") {
                        onRetry()
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.blue)
                }
            }

            Text(message)
                .font(.body)
                .foregroundStyle(.red)
                .textSelection(.enabled)
                .padding(16)
                .background(.quaternary, in: .rect(cornerRadius: 16))
        }
        .padding(16)
        .background(.regularMaterial, in: .rect(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.separator.opacity(0.5), lineWidth: 0.5))
    }
}