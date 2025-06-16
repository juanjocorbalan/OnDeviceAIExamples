import Foundation
import SwiftUI
import FoundationModels

@Generable
struct ColorPalette {
    @Guide(description: "Name of the color palette")
    let name: String

    @Guide(description: "Description of the palette's mood and characteristics")
    let description: String

    @Guide(description: "Information about the base color used to generate the palette")
    let baseColor: ColorInfo

    @Guide(description: "Array of colors in the palette (6 colors)")
    let colors: [ColorInfo]

    @Guide(description: "Type of color harmony used (complementary, analogous, etc.)")
    let harmony: HarmonyType

    @Generable
    struct ColorInfo {
        @Guide(description: "Name of the color (e.g., 'Deep Ocean Blue')")
        let name: String

        @Guide(description: "Hex color code with # prefix (e.g., '#1E40AF')")
        let hex: String

        // Convert to SwiftUI Color
        var swiftUIColor: Color {
            Color(hex: hex)
        }
    }

    @Generable
    enum HarmonyType: CaseIterable {
        case monochromatic
        case analogous
        case complementary
        case triadic
        case tetradic
        case splitComplementary

        // computed property for display text
        var displayName: String {
            switch self {
            case .monochromatic:
                return "Monochromatic"
            case .analogous:
                return "Analogous"
            case .complementary:
                return "Complementary"
            case .triadic:
                return "Triadic"
            case .tetradic:
                return "Tetradic"
            case .splitComplementary:
                return "Split-Complementary"
            }
        }
    }
}

// Helper extension to convert SwiftUI Color to hex string
extension Color {
    var hexString: String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
