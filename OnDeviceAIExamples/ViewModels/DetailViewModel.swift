import Foundation
import FoundationModels
import Observation
import OSLog

@Observable
final class DetailViewModel: BaseViewModel {

    // MARK: - Properties

    var response: String = ""
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "OnDeviceAIExamples", category: "DetailViewModel")

    // MARK: - Computed Properties

    var hasContent: Bool {
        !response.isEmpty || !errorMessage.isEmpty
    }

    var displayText: String {
        errorMessage.isEmpty ? response : errorMessage
    }

    var isError: Bool {
        !errorMessage.isEmpty
    }

    // MARK: - Operations

    func execute(example: ExampleType) async {
        logger.info("Executing example: \(example.rawValue)")
        switch example {
        case .basicResponse:
            await executeBasicResponse(example: example)
        case .streamingResponse:
            await executeStreamingResponse(example: example)
        case .structuredGeneration:
            // This case should not be reached since ColorPaletteView is handled separately
            return
        case .customTool:
            await executeCustomTool(example: example)
        case .interactiveChat:
            return  // Interactive chat is handled by ChatViewModel
        }
    }

    private func executeBasicResponse(example: ExampleType) async {
        await executeStandardOperation {
            try await self.foundationModelsService.generateResponse(
                prompt: example.prompt
            )
        }
    }

    private func executeStreamingResponse(example: ExampleType) async {
        isLoading = true
        response = ""
        resetError()

        do {
            let stream = foundationModelsService.streamResponse(
                prompt: example.prompt
            )

            for try await partialResponse in stream {
                response = partialResponse
            }

            isLoading = false
        } catch {
            handleError(error)
        }
    }

    private func executeCustomTool(example: ExampleType) async {
        await executeStandardOperation {
            try await self.foundationModelsService.executeWithTools(
                prompt: example.prompt
            )
        }
    }

    // MARK: - Helper Methods

    private func executeStandardOperation(
        _ operation: @escaping () async throws -> String
    ) async {
        isLoading = true
        response = ""
        resetError()

        do {
            response = try await operation()
        } catch {
            handleError(error)
        }

        isLoading = false
    }
}
