import SwiftUI

// MARK: - Design System

struct DesignSystem {
    
    // MARK: - Colors & Gradients
    
    static let primaryGradient = LinearGradient(
        colors: [.blue, .purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let errorGradient = LinearGradient(
        colors: [.orange.opacity(0.1), .red.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let errorPrimaryGradient = LinearGradient(
        colors: [.orange, .red],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Spacing
    
    static let cornerRadius: CGFloat = 16
    static let largeCornerRadius: CGFloat = 20
    static let buttonCornerRadius: CGFloat = 12
    
    // MARK: - Shadows
    
    static let cardShadow = Shadow(
        color: .black.opacity(0.05),
        radius: 8,
        x: 0,
        y: 4
    )
    
    static let largeShadow = Shadow(
        color: .black.opacity(0.05),
        radius: 10,
        x: 0,
        y: 4
    )
    
    static let buttonShadow = Shadow(
        color: .blue.opacity(0.3),
        radius: 8,
        x: 0,
        y: 4
    )
}

// MARK: - Shadow Helper

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions

extension View {
    func applyShadow(_ shadow: Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func cardBackground() -> some View {
        self.background(
            RoundedRectangle(cornerRadius: DesignSystem.cornerRadius)
                .fill(DesignSystem.cardGradient)
                .applyShadow(DesignSystem.cardShadow)
        )
    }
    
    func largeCardBackground() -> some View {
        self.background(
            RoundedRectangle(cornerRadius: DesignSystem.largeCornerRadius)
                .fill(Color(.systemBackground))
                .applyShadow(DesignSystem.largeShadow)
        )
    }
}

// MARK: - Reusable Components

struct GradientIcon: View {
    let systemName: String
    let size: CGFloat
    let backgroundSize: CGFloat
    
    init(systemName: String, size: CGFloat = 22, backgroundSize: CGFloat = 50) {
        self.systemName = systemName
        self.size = size
        self.backgroundSize = backgroundSize
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.backgroundGradient)
                .frame(width: backgroundSize, height: backgroundSize)
            
            Image(systemName: systemName)
                .font(.system(size: size, weight: .medium))
                .foregroundStyle(DesignSystem.primaryGradient)
        }
    }
}

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(DesignSystem.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.buttonCornerRadius))
            .applyShadow(DesignSystem.buttonShadow)
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.blue)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.blue, lineWidth: 2)
            )
        }
    }
}