# On-Device AI Examples

An iOS app demonstrating selected APIs from Apple’s Foundation Models framework for on-device AI capabilities.

## Features

### 🤖 AI Examples
- **Basic Response**: Simple conversational AI interactions
- **Streaming Response**: Real-time AI response streaming
- **Structured Generation**: Type-safe object generation using `@Generable`
- **Custom Tools**: AI model integration with custom tools

## Requirements

### Device Compatibility
- **iPhone**: iPhone 15 Pro or newer
- **Mac**: Mac with Apple Silicon (M1, M2, M3, etc.)

### Software Requirements
- iOS 26.0+ / macOS 26.0+
- Xcode 26.0+
- Apple Intelligence enabled on device

## Installation

### Clone and Build
```bash
git clone <repository-url>
cd OnDeviceAIExamples
open OnDeviceAIExamples.xcodeproj
```

### Build from Xcode
1. Open `OnDeviceAIExamples.xcodeproj` in Xcode
2. Select your target device (physical device recommended)
3. Build and run (⌘+R)

## Foundation Models API Examples

### Basic AI Chat
```swift
let service = FoundationModelsService()
let response = try await service.generateResponse(
    prompt: "Tell me a joke about programming",
    instructions: "You are a witty programming assistant"
)
```

### Structured Data Generation
```swift
@Generable
struct Recipe {
    @Guide(description: "Recipe name")
    let name: String
    
    @Guide(description: "List of ingredients")
    let ingredients: [String]
}

let recipe = try await service.generateStructuredData(
    prompt: "Create a pasta recipe",
    type: Recipe.self
)
```

### Real-time Streaming
```swift
try await service.streamResponse(
    prompt: "Write a short story",
    onPartialUpdate: { partialText in
        // Update UI with streaming content
        self.displayText = partialText
    }
)
```

### Custom Tool Integration
```swift
struct SearchTool: Tool {
    let name = "searchDatabase"
    let description = "Searches for information"
    
    @Generable
    struct Arguments {
        @Guide(description: "Search query")
        var query: String
    }
    
    func call(arguments: Arguments) async throws -> ToolOutput {
        // Tool implementation
    }
}
```

## Error Handling

The app includes comprehensive error handling for common scenarios:

- **Device Incompatibility**: Clear messaging for unsupported devices
- **Apple Intelligence Disabled**: Direct links to enable AI features
- **Model Unavailable**: User-friendly explanations and retry options
- **Generation Errors**: Helpful recovery suggestions
- **Tool Failures**: Specific error context and resolution steps

## License

This project is provided as an educational example for Foundation Models development.

