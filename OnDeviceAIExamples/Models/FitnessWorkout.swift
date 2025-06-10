import Foundation
import FoundationModels

/// Fitness Workout Models
@Generable
struct FitnessWorkout {
    @Guide(description: "Name of the workout routine")
    let name: String
    
    @Guide(description: "Difficulty level")
    let difficulty: WorkoutDifficulty
    
    @Guide(description: "Duration in minutes")
    let duration: Int
    
    @Guide(description: "List of exercises with reps")
    let exercises: [String]
    
    @Guide(description: "Equipment needed")
    let equipment: [String]
    
    @Guide(description: "Calories burned estimate")
    let caloriesBurned: Int
}

@Generable
enum WorkoutDifficulty {
    case beginner
    case intermediate
    case advanced
}
