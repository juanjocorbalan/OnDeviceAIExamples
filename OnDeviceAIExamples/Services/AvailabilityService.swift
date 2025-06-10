import FoundationModels
import Observation
import UIKit

/// Service for checking Foundation Models availability
@Observable
final class AvailabilityService {
    
    // MARK: - Properties
    
    var isAvailable: Bool = false
    var unavailabilityReason: UnavailabilityReason?
    var isChecking: Bool = false
    
    // MARK: - Types
    
    enum UnavailabilityReason {
        case deviceNotEligible
        case appleIntelligenceNotEnabled
        case modelNotReady
        case systemVersionTooOld
        case unknown
        
        var title: String {
            switch self {
            case .deviceNotEligible:
                return "Device Not Compatible"
            case .appleIntelligenceNotEnabled:
                return "Apple Intelligence Disabled"
            case .modelNotReady:
                return "Model Not Ready"
            case .systemVersionTooOld:
                return "iOS Version Too Old"
            case .unknown:
                return "Foundation Models Unavailable"
            }
        }
        
        var description: String {
            switch self {
            case .deviceNotEligible:
                return "Your device doesn't support Apple Intelligence. Foundation Models require an Apple Silicon device (iPhone 15 Pro or newer, iPad with M1 or newer, Mac with Apple Silicon)."
            case .appleIntelligenceNotEnabled:
                return "Apple Intelligence is not enabled on this device. Please enable it in Settings > Apple Intelligence & Siri."
            case .modelNotReady:
                return "Foundation Models are downloading or not ready. This may take some time depending on your network connection."
            case .systemVersionTooOld:
                return "Foundation Models require iOS 26 or later with Apple Intelligence support. Please update your device."
            case .unknown:
                return "Foundation Models are not available on this device. Please check your device compatibility and Apple Intelligence settings."
            }
        }
        
        var actionTitle: String? {
            switch self {
            case .appleIntelligenceNotEnabled:
                return "Open Settings"
            case .systemVersionTooOld:
                return "Check for Update"
            default:
                return nil
            }
        }
    }
    
    // MARK: - Methods
    
    func checkAvailability() {
        isChecking = true
        
        // Check iOS version first
        if #available(iOS 26, *) {
            // iOS 26+ is available, now check Foundation Models
            checkFoundationModelsAvailability()
        } else {
            // iOS version is too old
            isAvailable = false
            unavailabilityReason = .systemVersionTooOld
            isChecking = false
        }
    }
    
    private func checkFoundationModelsAvailability() {
        let model = SystemLanguageModel.default
        
        switch model.availability {
        case .available:
            isAvailable = true
            unavailabilityReason = nil
            
        case .unavailable(let reason):
            isAvailable = false
            
            switch reason {
            case .deviceNotEligible:
                unavailabilityReason = .deviceNotEligible
            case .appleIntelligenceNotEnabled:
                unavailabilityReason = .appleIntelligenceNotEnabled
            case .modelNotReady:
                unavailabilityReason = .modelNotReady
            @unknown default:
                unavailabilityReason = .unknown
            }
        }
        
        isChecking = false
    }
    
    @MainActor
    func performAction() {
        guard let reason = unavailabilityReason else { return }
        
        switch reason {
        case .appleIntelligenceNotEnabled:
            openAppleIntelligenceSettings()
        case .systemVersionTooOld:
            openSoftwareUpdateSettings()
        default:
            break
        }
    }
    
    @MainActor
    private func openAppleIntelligenceSettings() {
        if let url = URL(string: "App-prefs:APPLE_INTELLIGENCE") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                // Fallback to general settings
                openGeneralSettings()
            }
        }
    }
    
    @MainActor
    private func openSoftwareUpdateSettings() {
        if let url = URL(string: "App-prefs:General&path=SOFTWARE_UPDATE_LINK") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                openGeneralSettings()
            }
        }
    }
    
    @MainActor
    private func openGeneralSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
