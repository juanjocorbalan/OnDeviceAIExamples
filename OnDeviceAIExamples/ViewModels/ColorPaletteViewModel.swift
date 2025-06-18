import Foundation
import FoundationModels
import Observation
import SwiftUI

@Observable
final class ColorPaletteViewModel: BaseViewModel {
    
    // MARK: - Properties
    
    var selectedColor: Color = .blue
    var selectedHarmonyType: ColorPalette.HarmonyType = .complementary
    var generatedPalette: ColorPalette? = nil
    var isGenerating = false
    
    // MARK: - Methods
    
    func generatePalette() async {
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
        } catch {
            handleError(error)
        }
        
        isGenerating = false
    }
}
