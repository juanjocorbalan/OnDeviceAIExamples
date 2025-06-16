import Foundation
import FoundationModels
import Observation
import SwiftUI
import OSLog

@Observable
final class ColorPaletteViewModel: BaseViewModel {
    
    // MARK: - Properties
    
    var selectedColor: Color = .blue
    var selectedHarmonyType: ColorPalette.HarmonyType = .complementary
    var generatedPalette: ColorPalette? = nil
    var isGenerating = false
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "OnDeviceAIExamples", category: "ColorPaletteViewModel")
    
    // MARK: - Methods
    
    func generatePalette() async {
        logger.info("Starting palette generation for color: \(self.selectedColor.hexString), harmony: \(self.selectedHarmonyType.displayName)")
        
        isGenerating = true
        resetError()
        generatedPalette = nil
        
        let hexColor = self.selectedColor.hexString
        let harmonyType = self.selectedHarmonyType.displayName
        let prompt = """
        Generate a color palette based on the base color \(hexColor).
        The palette should use the \(harmonyType) color harmony.
        The palette should have exactly 6 colors.
        Make the palette visually appealing and suitable for design purposes.
        """
        
        do {
            generatedPalette = try await foundationModelsService.generateStructuredData(
                prompt: prompt,
                type: ColorPalette.self,
                instructions: "You are a graphic designer with expert knowledge in color theory, visual identity, and user interface design."
            )
            logger.info("Successfully generated palette")
        } catch {
            logger.error("Failed to generate palette: \(error.localizedDescription)")
            handleError(error)
        }
        
        isGenerating = false
    }
}
