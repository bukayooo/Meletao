import SwiftUI

extension Color {
    // Primary Colors from App Icon
    static let meletaoTeal = Color("MeletaoTeal")
    static let meletaoYellow = Color("MeletaoYellow")
    static let meletaoLavender = Color("MeletaoLavender")
    static let meletaoSage = Color("MeletaoSage")
    
    // Semantic Colors
    static let meletaoPrimary = Color("MeletaoPrimary")
    static let meletaoSecondary = Color("MeletaoSecondary")
    static let meletaoAccent = Color("MeletaoAccent")
    static let meletaoBackground = Color("MeletaoBackground")
    static let meletaoSurface = Color("MeletaoSurface")
    static let meletaoCardBackground = Color("MeletaoCardBackground")
    
    // Adaptive color definitions for light/dark mode
    static let staticMeletaoTeal = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
        switch appearance.name {
        case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
            return NSColor(red: 0.45, green: 0.75, blue: 0.7, alpha: 1.0) // Brighter in dark mode
        default:
            return NSColor(red: 0.4, green: 0.7, blue: 0.65, alpha: 1.0)
        }
    }))
    
    static let staticMeletaoYellow = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
        switch appearance.name {
        case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
            return NSColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1.0)
        default:
            return NSColor(red: 0.95, green: 0.85, blue: 0.55, alpha: 1.0)
        }
    }))
    
    static let staticMeletaoLavender = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
        switch appearance.name {
        case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
            return NSColor(red: 0.7, green: 0.65, blue: 0.8, alpha: 1.0)
        default:
            return NSColor(red: 0.75, green: 0.7, blue: 0.85, alpha: 1.0)
        }
    }))
    
    static let staticMeletaoSage = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
        switch appearance.name {
        case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
            return NSColor(red: 0.6, green: 0.7, blue: 0.55, alpha: 1.0)
        default:
            return NSColor(red: 0.7, green: 0.8, blue: 0.65, alpha: 1.0)
        }
    }))
    
    // Primary brand color - teal from the book
    static let staticMeletaoPrimary = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
        switch appearance.name {
        case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
            return NSColor(red: 0.45, green: 0.75, blue: 0.7, alpha: 1.0)
        default:
            return NSColor(red: 0.4, green: 0.7, blue: 0.65, alpha: 1.0)
        }
    }))
    
    // Secondary color - warm yellow from the circle
    static let staticMeletaoSecondary = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
        switch appearance.name {
        case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
            return NSColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1.0)
        default:
            return NSColor(red: 0.95, green: 0.85, blue: 0.55, alpha: 1.0)
        }
    }))
    
    // Accent color - lavender for highlights
    static let staticMeletaoAccent = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
        switch appearance.name {
        case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
            return NSColor(red: 0.7, green: 0.65, blue: 0.8, alpha: 1.0)
        default:
            return NSColor(red: 0.75, green: 0.7, blue: 0.85, alpha: 1.0)
        }
    }))
    
    // Background colors - dark mode uses book color
    static let staticMeletaoBackground = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
        switch appearance.name {
        case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
            return NSColor(red: 0.35, green: 0.65, blue: 0.6, alpha: 1.0) // Book color from icon
        default:
            return NSColor(red: 0.98, green: 0.98, blue: 0.96, alpha: 1.0)
        }
    }))
    
    // Surface colors for cards and panels
    static let staticMeletaoSurface = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
        switch appearance.name {
        case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
            return NSColor(red: 0.4, green: 0.7, blue: 0.65, alpha: 1.0) // Slightly lighter than background
        default:
            return NSColor.white
        }
    }))
    
    // Card background with subtle tint
    static let staticMeletaoCardBackground = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
        switch appearance.name {
        case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
            return NSColor(red: 0.42, green: 0.72, blue: 0.67, alpha: 1.0) // Lighter than surface
        default:
            return NSColor(red: 0.99, green: 0.98, blue: 0.96, alpha: 1.0)
        }
    }))
}


// Gradient definitions matching the app icon
extension LinearGradient {
    static let meletaoBackground = LinearGradient(
        colors: [
            Color.staticMeletaoLavender.opacity(0.3),
            Color.staticMeletaoSage.opacity(0.3)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let meletaoCard = LinearGradient(
        colors: [
            Color.staticMeletaoSurface,
            Color.staticMeletaoCardBackground
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let meletaoAccentGradient = LinearGradient(
        colors: [
            Color.staticMeletaoPrimary,
            Color.staticMeletaoSecondary.opacity(0.8)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}