import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        GlassEffectContainer(spacing: 16) {
                            VStack(spacing: 16) {
                                if viewModel.messages.isEmpty {
                                    emptyStateView
                                } else {
                                    ForEach(viewModel.messages) { message in
                                        BubbleView(message: message, isTyping: viewModel.isGenerating)
                                            .id(message.id)
                                    }
                                }
                            }
                            .padding(20)
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 110)
                    }
                    .onChange(of: viewModel.messages.last?.text) {
                        if let lastMessage = viewModel.messages.last {
                            withAnimation(.smooth) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                VStack {
                    Spacer()
                    inputField
                        .padding(20)
                }
            }
            .navigationTitle("Interactive Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.clearConversation()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.secondary)
                            .glassEffect()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.clearConversation()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.secondary)
                            .glassEffect()
                    }
                    .disabled(viewModel.messages.isEmpty)
                }
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "message.and.waveform.fill")
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(.blue)
                .frame(width: 80, height: 80)
                .glassEffect(in: .circle)

            Text("Start a Conversation")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Send a message to begin chatting with the model")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .glassEffect(in: .rect(cornerRadius: 20))
    }

    private var inputField: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $viewModel.inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .frame(minHeight: 22)
                .disabled(viewModel.isGenerating)
                .onSubmit {
                    if viewModel.canSendMessage {
                        viewModel.sendOrStopMessage()
                    }
                }
                .padding(.leading, 4)

            Button(action: viewModel.sendOrStopMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(
                        viewModel.canSendMessage ?
                        .blue :
                        Color.gray.opacity(0.6)
                    )
            }
            .disabled(!viewModel.canSendMessage && !viewModel.isGenerating)
        }
        .padding(24)
        .glassEffect(in: .rect(cornerRadius: 16))
    }
}

#Preview {
    ChatView()
}
