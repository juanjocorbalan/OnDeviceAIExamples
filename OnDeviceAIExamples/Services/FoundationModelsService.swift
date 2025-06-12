import Foundation
import FoundationModels
import Observation

/// Service class for managing Foundation Models operations
@MainActor
@Observable
final class FoundationModelsService {

    // MARK: - Properties

    private let paintingTool = PaintingDatabaseTool()
    private var chatSession: LanguageModelSession?
    private let model = SystemLanguageModel.default

    // MARK: - Session Management

    private func createBasicSession(instructions: String? = nil) throws -> LanguageModelSession {
        guard model.isAvailable else { throw FoundationModelsError.modelUnavailable }

        let session: LanguageModelSession
        if let instructions {
            session = LanguageModelSession(instructions: Instructions(instructions))
        } else {
            session = LanguageModelSession()
        }
        return session
    }

    private func createSessionWithTools(instructions: String? = nil) throws -> LanguageModelSession {
        guard model.isAvailable else { throw FoundationModelsError.modelUnavailable }

        let defaultInstructions = "You are a helpful assistant with access to art and painting databases."
        let finalInstructions = instructions ?? defaultInstructions
        return LanguageModelSession(tools: [paintingTool], instructions: Instructions(finalInstructions))
    }

    // MARK: - Operations

    func generateResponse(prompt: String, instructions: String? = nil) async throws -> String {
        do {
            let session = try createBasicSession(instructions: instructions)
            let response = try await session.respond(to: Prompt(prompt))
            return response.content
        } catch LanguageModelSession.GenerationError.guardrailViolation {
            throw FoundationModelsError.contentPolicyViolation
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            throw FoundationModelsError.promptTooLong
        } catch LanguageModelSession.GenerationError.assetsUnavailable {
            throw FoundationModelsError.modelUnavailable
        }
    }

    func generateStructuredData<T: Generable>(prompt: String, type: T.Type, instructions: String? = nil) async throws -> T {
        do {
            let session = try createBasicSession(instructions: instructions)
            let response = try await session.respond(to: Prompt(prompt), generating: type)
            return response.content
        } catch LanguageModelSession.GenerationError.guardrailViolation {
            throw FoundationModelsError.contentPolicyViolation
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            throw FoundationModelsError.promptTooLong
        } catch LanguageModelSession.GenerationError.decodingFailure {
            throw FoundationModelsError.structuredGenerationFailed
        }
    }

    func streamResponse(prompt: String, instructions: String? = nil) -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let session = try createBasicSession(instructions: instructions)
                    let stream = session.streamResponse(to: Prompt(prompt))

                    for try await partialResponse in stream {
                        continuation.yield(partialResponse)
                    }
                    continuation.finish()
                } catch LanguageModelSession.GenerationError.guardrailViolation {
                    continuation.finish(throwing: FoundationModelsError.contentPolicyViolation)
                } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
                    continuation.finish(throwing: FoundationModelsError.promptTooLong)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    func executeWithTools(prompt: String) async throws -> String {
        do {
            let session = try createSessionWithTools()
            let response = try await session.respond(to: Prompt(prompt))
            return response.content
        } catch LanguageModelSession.GenerationError.guardrailViolation {
            throw FoundationModelsError.contentPolicyViolation
        } catch let toolError as LanguageModelSession.ToolCallError {
            throw FoundationModelsError.toolExecutionFailed(toolError.tool.name, toolError.underlyingError.localizedDescription)
        }
    }

    // MARK: - Chat Session Management

    private func initializeChatSessionIfNeeded(instructions: String? = nil) throws -> LanguageModelSession {
        guard chatSession == nil else { return chatSession! }
        return try createBasicSession(instructions: instructions ?? "Be concise and engaging in your responses.")
    }

    func streamChatResponse(prompt: String, options: GenerationOptions? = nil) -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                let session = try initializeChatSessionIfNeeded()
                let generationOptions = options ?? GenerationOptions(temperature: 0.8)
                let stream = session.streamResponse(to: Prompt(prompt), options: generationOptions)
                do {
                    for try await partialResponse in stream {
                        continuation.yield(partialResponse)
                    }
                    continuation.finish()
                } catch LanguageModelSession.GenerationError.guardrailViolation {
                    continuation.finish(throwing: FoundationModelsError.contentPolicyViolation)
                } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
                    continuation.finish(throwing: FoundationModelsError.promptTooLong)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    func invalidateChatSession() {
        chatSession = nil
    }

    // MARK: - Error Handling

    func handleError(_ error: Error) -> String {
        if let foundationError = error as? FoundationModelsError {
            return foundationError.localizedDescription
        } else {
            return "Unexpected error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Simplified Error Types

enum FoundationModelsError: LocalizedError {
    case modelUnavailable
    case contentPolicyViolation
    case promptTooLong
    case structuredGenerationFailed
    case toolExecutionFailed(String, String)

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "AI model is not available. Please check your device compatibility and Apple Intelligence settings."
        case .contentPolicyViolation:
            return "Your request contains content that doesn't meet our guidelines. Please try rephrasing your request."
        case .promptTooLong:
            return "Your request is too long. Please try with a shorter prompt."
        case .structuredGenerationFailed:
            return "Failed to generate the requested data format. Please try again."
        case .toolExecutionFailed(let toolName, let details):
            return "Tool '\(toolName)' encountered an error: \(details)"
        }
    }
}
