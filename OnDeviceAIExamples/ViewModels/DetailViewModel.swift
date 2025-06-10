import Foundation
import FoundationModels
import Observation

@Observable
final class DetailViewModel {

    // MARK: - Dependencies

    private let foundationModelsService = FoundationModelsService()

    // MARK: - Published Properties

    var response: String = ""
    var isLoading: Bool = false
    var errorMessage: String = ""

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

    @MainActor
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
        }
    }

    @MainActor
    private func executeBasicResponse(example: ExampleType) async {
        await executeExample {
            try await self.foundationModelsService.generateResponse(prompt: example.prompt)
        }
    }

    @MainActor
    private func executeStructuredGeneration(example: ExampleType) async {
        await executeExample {
            let workout = try await self.foundationModelsService.generateStructuredData(
                prompt: example.prompt,
                type: FitnessWorkout.self
            )

            return self.formatWorkout(workout)
        }
    }

    @MainActor
    private func executeStreamingResponse(example: ExampleType) async {
        isLoading = true
        response = ""
        errorMessage = ""

        do {
            let finalResponse = try await foundationModelsService.streamResponse(
                prompt: example.prompt,
                onPartialUpdate: { [weak self] partialText in
                    Task {
                        self?.response = partialText
                    }
                }
            )

            response = finalResponse
            isLoading = false
        } catch {
            errorMessage = foundationModelsService.handleError(error)
            isLoading = false
        }
    }


    @MainActor
    private func executeCustomTool(example: ExampleType) async {
        await executeExample {
            let paintingResult = try await self.foundationModelsService.executeWithTools(prompt: example.prompt)
            return paintingResult
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

    @MainActor
    private func executeExample(_ operation: @escaping () async throws -> String) async {
        isLoading = true
        response = ""
        errorMessage = ""

        do {
            let result = try await operation()
            response = result
        } catch {
            errorMessage = foundationModelsService.handleError(error)
        }

        isLoading = false
    }
}

