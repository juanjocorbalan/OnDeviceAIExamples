import Foundation

/// Operations to be executed on-device
enum ExampleType: String, CaseIterable, Identifiable {
    case basicResponse = "Basic Response"
    case streamingResponse = "Streaming Response"
    case structuredGeneration = "Structured Generation"
    case customTool = "Using Custom Tools"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .basicResponse:
            return "Simple response from the model"
        case .streamingResponse:
            return "Real-time response streaming"
        case .structuredGeneration:
            return "Generate typed objects"
        case .customTool:
            return "Use custom tools with the model"
        }
    }

    var icon: String {
        switch self {
        case .basicResponse:
            return "bubble.left.and.bubble.right"
        case .structuredGeneration:
            return "doc.text.below.ecg"
        case .streamingResponse:
            return "dot.radiowaves.left.and.right"
        case .customTool:
            return "hammer.fill"
        }
    }

    var prompt: String {
        switch self {
        case .basicResponse:
            return "Tell a joke."
        case .streamingResponse:
            return "Write a short sciFi story."
        case .structuredGeneration:
            return "Create a 30-minute strength training workout for beginners at home."
        case .customTool:
            return "Find famous paintings by Picasso and Dalí, including their significance in art history"
        }
    }
}

