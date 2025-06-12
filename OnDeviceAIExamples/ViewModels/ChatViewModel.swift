import Foundation
import FoundationModels
import Observation

@Observable
final class ChatViewModel: BaseViewModel {
    
    // MARK: - Published Properties
    
    private(set) var messages: [ChatMessage] = []
    var inputText = ""
    private(set) var isGenerating = false
    
    // MARK: - Private Properties
    
    private var currentTask: Task<Void, Never>?
    
    // MARK: - Computed Properties
    
    var canSendMessage: Bool {
        !trimmedInput.isEmpty && !isGenerating
    }
    
    private var trimmedInput: String {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Public Methods
    
    func sendOrStopMessage() {
        if isGenerating {
            cancelGeneration()
        } else {
            sendMessage()
        }
    }
    
    private func sendMessage() {
        guard canSendMessage else { return }
        
        let userPrompt = trimmedInput
        inputText = ""
        
        addUserMessage(userPrompt)
        let assistantIndex = addEmptyAssistantMessage()
        
        startGeneration(for: userPrompt, at: assistantIndex)
    }
    
    func cancelGeneration() {
        currentTask?.cancel()
    }
    
    func clearConversation() {
        currentTask?.cancel()
        messages.removeAll()
        foundationModelsService.invalidateChatSession()
    }
    
    // MARK: - Private Methods
    
    private func addUserMessage(_ text: String) {
        messages.append(ChatMessage(isUser: true, text: text))
    }
    
    private func addEmptyAssistantMessage() -> Int {
        messages.append(ChatMessage(isUser: false, text: ""))
        return messages.count - 1
    }
    
    private func startGeneration(for prompt: String, at index: Int) {
        isGenerating = true
        
        currentTask = Task { @MainActor in
            defer { finishGeneration() }
            
            do {
                let stream = foundationModelsService.streamChatResponse(prompt: prompt)
                
                for try await response in stream {
                    guard !Task.isCancelled else { break }
                    updateMessage(at: index, with: response)
                }
            } catch is CancellationError {
                // Generation was cancelled
            } catch {
                handleGenerationError(error)
            }
        }
    }
    
    private func updateMessage(at index: Int, with text: String) {
        guard index < messages.count else { return }
        messages[index].text = text
    }
    
    private func finishGeneration() {
        isGenerating = false
        currentTask = nil
    }
    
    private func handleGenerationError(_ error: Error) {
        errorMessage = foundationModelsService.handleError(error)
        showErrorAlert = true
    }
}
