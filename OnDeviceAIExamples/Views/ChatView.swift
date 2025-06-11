import SwiftUI
import FoundationModels

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack {
                            if viewModel.messages.isEmpty {
                                emptyStateView
                            } else {
                                ForEach(viewModel.messages) { message in
                                    BubbleView(message: message, isResponding: viewModel.isGenerating)
                                        .id(message.id)
                                }
                            }
                        }
                        .padding()
                    }
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 90)
                    }
                    .onChange(of: viewModel.messages.last?.text) {
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
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
                        viewModel.cleanup()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        viewModel.clearConversation()
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
            GradientIcon(systemName: "message.and.waveform.fill", size: 40, backgroundSize: 80)
            
            Text("Start a Conversation")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Send a message to begin chatting with the model")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity)
        .cardBackground()
    }
    
    private var inputField: some View {
        ZStack {
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
                .padding(16)
            
            HStack {
                Spacer()
                Button(action: viewModel.sendOrStopMessage) {
                    Image(systemName: viewModel.sendButtonIcon)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(
                            viewModel.canSendMessage ? 
                            DesignSystem.primaryGradient :
                            LinearGradient(colors: [Color.gray.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
                        )
                }
                .disabled(!viewModel.canSendMessage)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isGenerating)
                .animation(.easeInOut(duration: 0.2), value: viewModel.canSendMessage)
                .padding(.trailing, 8)
            }
        }
        .cardBackground()
    }
}

#Preview {
    ChatView()
}

