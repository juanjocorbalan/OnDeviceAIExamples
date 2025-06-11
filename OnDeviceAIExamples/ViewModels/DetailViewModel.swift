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
        default:
            return // Interactive chat is handled by ChatViewModel
        }
    }

    private func executeBasicResponse(example: ExampleType) async {
        await executeExample {
            try await self.foundationModelsService.generateResponse(prompt: example.prompt)
        }
    }

    private func executeStructuredGeneration(example: ExampleType) async {
        await executeExample {
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

    private func executeExample(_ operation: @escaping () async throws -> String) async {
        isLoading = true
        response = ""
        resetError()

        do {
            let result = try await operation()
            response = result
        } catch {
            handleError(error)
        }

        isLoading = false
    }
}

