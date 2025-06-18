import Foundation
import FoundationModels
import Observation

@Observable
final class DetailViewModel: BaseViewModel {

    // MARK: - Properties

    var response: String = ""

    // MARK: - Computed Properties

    var hasContent: Bool {
        !response.isEmpty || !errorMessage.isEmpty
    }

    var displayText: String {
        errorMessage.isEmpty ? response : errorMessage
    }


    // MARK: - Operations

    func execute(example: ExampleType) async {
        switch example {
        case .basicResponse:
            await executeStandardOperation {
                try await self.foundationModelsService.generateResponse(prompt: example.prompt)
            }
        case .streamingResponse:
            await executeStreamingResponse(for: example)
        case .customTool:
            await executeStandardOperation {
                try await self.foundationModelsService.executeWithTools(prompt: example.prompt)
            }
        case .structuredGeneration, .interactiveChat:
            return
        }
    }

    private func executeStreamingResponse(for example: ExampleType) async {
        prepareForExecution()

        do {
            let stream = foundationModelsService.streamResponse(prompt: example.prompt)
            for try await partialResponse in stream {
                response = partialResponse
            }
            isLoading = false
        } catch {
            handleError(error)
        }
    }

    private func executeStandardOperation(_ operation: @escaping () async throws -> String) async {
        prepareForExecution()

        do {
            response = try await operation()
            isLoading = false
        } catch {
            handleError(error)
        }
    }

    private func prepareForExecution() {
        isLoading = true
        response = ""
        resetError()
    }
}
