import Foundation
import FoundationModels
import Observation

@MainActor
@Observable
class BaseViewModel {
    
    // MARK: - Common Properties
    
    var isLoading = false
    var errorMessage = ""
    var showErrorAlert = false
    
    // MARK: - Services
    
    let foundationModelsService = FoundationModelsService()
    
    // MARK: - Common Methods
    
    func handleError(_ error: Error) {
        errorMessage = foundationModelsService.handleError(error)
        showErrorAlert = true
        isLoading = false
    }
    
    
    func resetError() {
        errorMessage = ""
        showErrorAlert = false
    }
}