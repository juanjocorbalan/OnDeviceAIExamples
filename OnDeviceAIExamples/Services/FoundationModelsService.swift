import Foundation
import FoundationModels
import Observation

/// Service class for managing Foundation Models operations
@Observable
final class FoundationModelsService {

    // MARK: - Properties

    private let paintingTool = PaintingDatabaseTool()
    private var chatSession: LanguageModelSession?

    // MARK: - Session Management

    private func createBasicSession(instructions: String? = nil) -> LanguageModelSession {
        let session: LanguageModelSession
        if let instructions {
            session = LanguageModelSession(instructions: Instructions(instructions))
        } else {
            session = LanguageModelSession()
        }
        return session
    }

    private func createSessionWithTools(instructions: String? = nil) -> LanguageModelSession {
        let defaultInstructions = "You are a helpful assistant with access to art and painting databases."
        let finalInstructions = instructions ?? defaultInstructions

        let session = LanguageModelSession(
            tools: [paintingTool],
            instructions: Instructions(finalInstructions)
        )
        return session
    }

    // MARK: - Operations

    @MainActor
    func generateResponse(prompt: String, instructions: String? = nil) async throws -> String {
        let session = createBasicSession(instructions: instructions)
        let response = try await session.respond(to: Prompt(prompt))
        return response.content
    }

    @MainActor
    func generateStructuredData<T: Generable>(prompt: String, type: T.Type, instructions: String? = nil) async throws -> T {
        let session = createBasicSession(instructions: instructions)
        let response = try await session.respond(to: Prompt(prompt), generating: type)
        return response.content
    }

    @MainActor
    func streamResponse(prompt: String, instructions: String? = nil) -> AsyncThrowingStream<String, Error> {
        let session = createBasicSession(instructions: instructions)
        let stream = session.streamResponse(to: Prompt(prompt))

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await partialResponse in stream {
                        continuation.yield(partialResponse)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    @MainActor
    func executeWithTools(prompt: String) async throws -> String {
        let session = createSessionWithTools()
        let response = try await session.respond(to: Prompt(prompt))
        return response.content
    }

    // MARK: - Chat Session Management

    private func initializeChatSessionIfNeeded(instructions: String? = nil) -> LanguageModelSession {
        guard chatSession == nil else { return chatSession! }
        return createBasicSession(instructions: instructions ?? "Be concise and engaging in your responses.")
    }

    @MainActor
    func streamChatResponse(prompt: String, options: GenerationOptions? = nil) -> AsyncThrowingStream<String, Error> {
        let session = initializeChatSessionIfNeeded()
        let generationOptions = options ?? GenerationOptions(temperature: 0.8)
        let stream = session.streamResponse(to: Prompt(prompt), options: generationOptions)

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await partialResponse in stream {
                        continuation.yield(partialResponse)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    @MainActor
    func invalidateChatSession() {
        chatSession = nil
    }

    // MARK: - Error Handling

    func handleError(_ error: Error) -> String {
        if let generationError = error as? LanguageModelSession.GenerationError {
            return handleGenerationError(generationError)
        } else if let toolCallError = error as? LanguageModelSession.ToolCallError {
            return "Tool '\(toolCallError.tool.name)' error: \(toolCallError.underlyingError.localizedDescription)"
        } else {
            return "Unexpected error: \(error.localizedDescription)"
        }
    }

    private func handleGenerationError(_ error: LanguageModelSession.GenerationError) -> String {
        switch error {
        case .exceededContextWindowSize:
            return "Error: The request is too long. Please try with a shorter prompt."
        case .assetsUnavailable:
            return "Error: AI model is temporarily unavailable. Please try again later."
        case .guardrailViolation:
            return "Error: Your request violates content policies. Please modify your prompt."
        case .decodingFailure:
            return "Error: Failed to process the AI response. Please try again."
        case .unsupportedGuide:
            return "Error: The requested format is not supported. Please try a different approach."
        case .unsupportedLanguageOrLocale:
            return "Error: The requested language is not supported."
        @unknown default:
            return "Error: An unexpected error occurred. Please try again."
        }
    }
}
