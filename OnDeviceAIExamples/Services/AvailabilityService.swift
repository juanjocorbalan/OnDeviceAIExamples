import FoundationModels
import Observation
import UIKit

/// Service for checking Foundation Models availability
@MainActor
@Observable
final class AvailabilityService {

    // MARK: - Properties

    private let model = SystemLanguageModel.default

    var isAvailable: Bool {
        model.isAvailable
    }

    var unavailabilityReason: UnavailabilityReason? {
        switch model.availability {
        case .available:
            return nil
        case .unavailable(.deviceNotEligible):
            return .deviceNotEligible
        case .unavailable(.appleIntelligenceNotEnabled):
            return .appleIntelligenceNotEnabled
        case .unavailable(.modelNotReady):
            return .modelNotReady
        case .unavailable:
            return .unknown
        }
    }

    // MARK: - Actions

    func performAction() {
        switch unavailabilityReason {
        case .appleIntelligenceNotEnabled:
            let settingsURL = URL(string: "App-prefs:APPLE_INTELLIGENCE_AND_SIRI") ??
                             URL(string: UIApplication.openSettingsURLString)

            guard let url = settingsURL, UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url)
        default:
            break
        }
    }
}

extension AvailabilityService {
    enum UnavailabilityReason {
        case deviceNotEligible
        case appleIntelligenceNotEnabled
        case modelNotReady
        case unknown

        var title: String {
            switch self {
            case .deviceNotEligible:
                return "Device Not Compatible"
            case .appleIntelligenceNotEnabled:
                return "Apple Intelligence Disabled"
            case .modelNotReady:
                return "Model Not Ready"
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
            case .unknown:
                return "Foundation Models are not available on your device"
            }
        }

        var actionTitle: String? {
            switch self {
            case .appleIntelligenceNotEnabled:
                return "Open Settings"
            default:
                return nil
            }
        }

        var icon: String {
            switch self {
            case .deviceNotEligible:
                return "iphone.slash"
            case .appleIntelligenceNotEnabled:
                return "brain"
            case .modelNotReady:
                return "icloud.and.arrow.down"
            case .unknown:
                return "exclamationmark.triangle.fill"
            }
        }
    }
}
