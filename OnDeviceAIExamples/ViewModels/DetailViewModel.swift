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

    var isError: Bool {
        !errorMessage.isEmpty
    }

    // MARK: - Operations

    func execute(example: ExampleType) async {
        switch example {
        case .basicResponse:
            await executeBasicResponse(example: example)
        case .streamingResponse:
            await executeStreamingResponse(example: example)
        case .structuredGeneration:
            await executeStructuredGeneration(example: example)
        case .customTool:
            await executeCustomTool(example: example)
        case .interactiveChat:
            return // Interactive chat is handled by ChatViewModel
        }
    }

    private func executeBasicResponse(example: ExampleType) async {
        await executeStandardOperation {
            try await self.foundationModelsService.generateResponse(prompt: example.prompt)
        }
    }

    private func executeStructuredGeneration(example: ExampleType) async {
        await executeStandardOperation {
            let workout = try await self.foundationModelsService.generateStructuredData(
                prompt: example.prompt,
                type: FitnessWorkout.self
            )
            return self.formatWorkout(workout)
        }
    }

    private func executeStreamingResponse(example: ExampleType) async {
        isLoading = true
        response = ""
        resetError()

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

    private func executeCustomTool(example: ExampleType) async {
        await executeStandardOperation {
            try await self.foundationModelsService.executeWithTools(prompt: example.prompt)
        }
    }

    // MARK: - Helper Methods

    private func formatWorkout(_ workout: FitnessWorkout) -> String {
        return """
        🏋️ FITNESS WORKOUT:
        Name: \(workout.name)
        Difficulty: \(workout.difficulty)
        Duration: \(workout.duration) minutes
        Calories Burned: \(workout.caloriesBurned)
        
        Exercises:
        \(workout.exercises.map { "• \($0)" }.joined(separator: "\n"))
        
        Equipment: \(workout.equipment.joined(separator: ", "))
        """
    }

    private func executeStandardOperation(_ operation: @escaping () async throws -> String) async {
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
