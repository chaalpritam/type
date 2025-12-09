//
//  TypeStyleTheme.swift
//  type
//
//  Minimalistic design system for Type screenwriting app
//  Elegant, distraction-free UI with proper dark mode support
//

import SwiftUI
import AppKit

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var colorScheme: ColorScheme = .light
    @Published var useSystemAppearance: Bool = true
    
    func toggleColorScheme() {
        colorScheme = colorScheme == .light ? .dark : .light
    }
}

// MARK: - Type Color Palette
enum TypeColors {
    // MARK: - Background Colors
    static var editorBackground: Color {
        Color("EditorBackground", bundle: nil)
    }
    
    static var editorBackgroundLight: Color {
        Color(red: 0.98, green: 0.98, blue: 0.97) // Warm paper-like white
    }
    
    static var editorBackgroundDark: Color {
        Color(red: 0.11, green: 0.11, blue: 0.12) // Deep charcoal
    }
    
    static var sidebarBackground: Color {
        Color("SidebarBackground", bundle: nil)
    }
    
    static var sidebarBackgroundLight: Color {
        Color(red: 0.96, green: 0.96, blue: 0.95)
    }
    
    static var sidebarBackgroundDark: Color {
        Color(red: 0.14, green: 0.14, blue: 0.15)
    }
    
    static var toolbarBackground: Color {
        Color("ToolbarBackground", bundle: nil)
    }
    
    static var toolbarBackgroundLight: Color {
        Color(red: 0.97, green: 0.97, blue: 0.96)
    }
    
    static var toolbarBackgroundDark: Color {
        Color(red: 0.12, green: 0.12, blue: 0.13)
    }
    
    // MARK: - Text Colors
    static var primaryText: Color {
        Color("PrimaryText", bundle: nil)
    }
    
    static var primaryTextLight: Color {
        Color(red: 0.15, green: 0.15, blue: 0.15)
    }
    
    static var primaryTextDark: Color {
        Color(red: 0.92, green: 0.92, blue: 0.90)
    }
    
    static var secondaryText: Color {
        Color("SecondaryText", bundle: nil)
    }
    
    static var secondaryTextLight: Color {
        Color(red: 0.45, green: 0.45, blue: 0.45)
    }
    
    static var secondaryTextDark: Color {
        Color(red: 0.60, green: 0.60, blue: 0.58)
    }
    
    static var tertiaryText: Color {
        Color("TertiaryText", bundle: nil)
    }
    
    static var tertiaryTextLight: Color {
        Color(red: 0.65, green: 0.65, blue: 0.65)
    }
    
    static var tertiaryTextDark: Color {
        Color(red: 0.45, green: 0.45, blue: 0.43)
    }
    
    // MARK: - Accent Colors
    static var accent: Color {
        Color(red: 0.25, green: 0.47, blue: 0.85) // Type blue
    }
    
    static var accentSecondary: Color {
        Color(red: 0.35, green: 0.55, blue: 0.90)
    }
    
    // MARK: - Scene Colors
    static let sceneRed = Color(red: 0.89, green: 0.35, blue: 0.35)
    static let sceneOrange = Color(red: 0.95, green: 0.55, blue: 0.25)
    static let sceneYellow = Color(red: 0.95, green: 0.80, blue: 0.25)
    static let sceneGreen = Color(red: 0.35, green: 0.78, blue: 0.45)
    static let sceneCyan = Color(red: 0.25, green: 0.75, blue: 0.85)
    static let sceneBlue = Color(red: 0.35, green: 0.50, blue: 0.85)
    static let scenePurple = Color(red: 0.65, green: 0.45, blue: 0.85)
    static let scenePink = Color(red: 0.90, green: 0.45, blue: 0.65)
    
    // MARK: - Status Colors
    static let success = Color(red: 0.35, green: 0.75, blue: 0.45)
    static let warning = Color(red: 0.95, green: 0.70, blue: 0.25)
    static let error = Color(red: 0.90, green: 0.35, blue: 0.35)
    static let info = Color(red: 0.35, green: 0.55, blue: 0.90)
    
    // MARK: - Border & Divider Colors
    static var divider: Color {
        Color("Divider", bundle: nil)
    }
    
    static var dividerLight: Color {
        Color(red: 0.88, green: 0.88, blue: 0.87)
    }
    
    static var dividerDark: Color {
        Color(red: 0.22, green: 0.22, blue: 0.23)
    }
    
    // MARK: - Selection Colors
    static var selection: Color {
        accent.opacity(0.15)
    }
    
    static var hover: Color {
        Color.primary.opacity(0.05)
    }
    
    // MARK: - Helper Functions
    static func adaptiveColor(light: Color, dark: Color, for colorScheme: ColorScheme) -> Color {
        colorScheme == .light ? light : dark
    }
}

// MARK: - Type Typography
enum TypeTypography {
    // MARK: - Editor Fonts
    static let editorFont = Font.custom("Courier Prime", size: 13)
    static let editorFontMedium = Font.custom("Courier Prime", size: 13).weight(.medium)
    static let editorFontBold = Font.custom("Courier Prime", size: 13).weight(.bold)
    
    // Fallback to system courier
    static let editorFontFallback = Font.system(size: 13, weight: .regular, design: .monospaced)
    
    // MARK: - UI Fonts
    static let title = Font.system(size: 20, weight: .semibold, design: .default)
    static let headline = Font.system(size: 14, weight: .semibold, design: .default)
    static let subheadline = Font.system(size: 12, weight: .medium, design: .default)
    static let body = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 11, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 10, weight: .regular, design: .default)
    
    // MARK: - Toolbar Fonts
    static let toolbarLabel = Font.system(size: 11, weight: .medium, design: .default)
    static let toolbarIcon = Font.system(size: 12, weight: .regular, design: .default)
    
    // MARK: - Screenplay Element Fonts
    static func sceneHeading(size: CGFloat = 13) -> Font {
        Font.system(size: size, weight: .bold, design: .monospaced)
    }
    
    static func action(size: CGFloat = 13) -> Font {
        Font.system(size: size, weight: .regular, design: .monospaced)
    }
    
    static func character(size: CGFloat = 13) -> Font {
        Font.system(size: size, weight: .medium, design: .monospaced)
    }
    
    static func dialogue(size: CGFloat = 13) -> Font {
        Font.system(size: size, weight: .regular, design: .monospaced)
    }
    
    static func parenthetical(size: CGFloat = 13) -> Font {
        Font.system(size: size, weight: .regular, design: .monospaced)
    }
    
    static func transition(size: CGFloat = 13) -> Font {
        Font.system(size: size, weight: .medium, design: .monospaced)
    }
}

// MARK: - Type Spacing
enum TypeSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    
    // Editor-specific spacing
    static let editorHorizontalPadding: CGFloat = 80
    static let editorVerticalPadding: CGFloat = 40
    static let lineHeight: CGFloat = 1.5
    
    // Toolbar spacing
    static let toolbarHeight: CGFloat = 38
    static let toolbarItemSpacing: CGFloat = 6
    static let toolbarGroupSpacing: CGFloat = 16
    
    // Sidebar spacing
    static let sidebarWidth: CGFloat = 220
    static let sidebarItemHeight: CGFloat = 28
    static let sidebarIconSize: CGFloat = 14
    
    // Status bar
    static let statusBarHeight: CGFloat = 24
}

// MARK: - Type Corner Radius
enum TypeRadius {
    static let xs: CGFloat = 2
    static let sm: CGFloat = 4
    static let md: CGFloat = 6
    static let lg: CGFloat = 8
    static let xl: CGFloat = 12
    static let full: CGFloat = 9999
}

// MARK: - Type Shadows
enum TypeShadows {
    static let subtle = Shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    static let light = Shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    static let medium = Shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
    static let heavy = Shadow(color: .black.opacity(0.16), radius: 16, x: 0, y: 8)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Type Animation
enum TypeAnimation {
    static let quick = Animation.easeOut(duration: 0.15)
    static let standard = Animation.easeInOut(duration: 0.25)
    static let smooth = Animation.easeInOut(duration: 0.35)
    static let slow = Animation.easeInOut(duration: 0.5)
    
    static let spring = Animation.spring(response: 0.35, dampingFraction: 0.8)
    static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.65)
}

// MARK: - Environment Keys
struct ColorSchemeKey: EnvironmentKey {
    static let defaultValue: ColorScheme = .light
}

extension EnvironmentValues {
    var typeColorScheme: ColorScheme {
        get { self[ColorSchemeKey.self] }
        set { self[ColorSchemeKey.self] = newValue }
    }
}

// MARK: - View Modifiers

/// Type-style card modifier
struct TypeCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var elevation: CardElevation = .low
    
    enum CardElevation {
        case flat, low, medium, high
        
        var shadow: Shadow {
            switch self {
            case .flat: return Shadow(color: .clear, radius: 0, x: 0, y: 0)
            case .low: return TypeShadows.subtle
            case .medium: return TypeShadows.light
            case .high: return TypeShadows.medium
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: TypeRadius.md)
                    .fill(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
            )
            .overlay(
                RoundedRectangle(cornerRadius: TypeRadius.md)
                    .stroke(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight, lineWidth: 0.5)
            )
            .shadow(
                color: elevation.shadow.color,
                radius: elevation.shadow.radius,
                x: elevation.shadow.x,
                y: elevation.shadow.y
            )
    }
}

/// Type-style button modifier
struct TypeButtonModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var style: ButtonStyleType = .secondary
    var size: ButtonSize = .medium
    @State private var isHovered = false
    
    enum ButtonStyleType {
        case primary, secondary, ghost, danger
    }
    
    enum ButtonSize {
        case small, medium, large
        
        var height: CGFloat {
            switch self {
            case .small: return 24
            case .medium: return 28
            case .large: return 34
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 11
            case .large: return 13
            }
        }
    }
    
    var backgroundColor: Color {
        switch style {
        case .primary:
            return isHovered ? TypeColors.accentSecondary : TypeColors.accent
        case .secondary:
            return isHovered ? TypeColors.hover : .clear
        case .ghost:
            return isHovered ? TypeColors.hover : .clear
        case .danger:
            return isHovered ? TypeColors.error.opacity(0.9) : TypeColors.error
        }
    }
    
    var foregroundColor: Color {
        switch style {
        case .primary, .danger:
            return .white
        case .secondary, .ghost:
            return colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight
        }
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size.fontSize, weight: .medium))
            .foregroundColor(foregroundColor)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: TypeRadius.sm)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: TypeRadius.sm)
                    .stroke(style == .secondary ? (colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight) : .clear, lineWidth: 0.5)
            )
            .onHover { hovering in
                withAnimation(TypeAnimation.quick) {
                    isHovered = hovering
                }
            }
    }
}

/// Type-style icon button
struct TypeIconButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    var isActive: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13))
            .foregroundColor(isActive ? TypeColors.accent : (colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight))
            .frame(width: 28, height: 28)
            .background(
                RoundedRectangle(cornerRadius: TypeRadius.sm)
                    .fill(configuration.isPressed ? TypeColors.hover : (isActive ? TypeColors.selection : .clear))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(TypeAnimation.quick, value: configuration.isPressed)
    }
}

// MARK: - View Extensions
extension View {
    func typeCard(elevation: TypeCardModifier.CardElevation = .low) -> some View {
        modifier(TypeCardModifier(elevation: elevation))
    }
    
    func typeButton(style: TypeButtonModifier.ButtonStyleType = .secondary, size: TypeButtonModifier.ButtonSize = .medium) -> some View {
        modifier(TypeButtonModifier(style: style, size: size))
    }
    
    func typeShadow(_ shadow: Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

// MARK: - Preview
#Preview("Type Theme Colors") {
    VStack(spacing: 20) {
        // Light Mode
        VStack(spacing: 8) {
            Text("Light Mode")
                .font(TypeTypography.headline)
            
            HStack(spacing: 4) {
                colorSwatch(TypeColors.editorBackgroundLight, "Editor")
                colorSwatch(TypeColors.sidebarBackgroundLight, "Sidebar")
                colorSwatch(TypeColors.toolbarBackgroundLight, "Toolbar")
            }
            
            HStack(spacing: 4) {
                colorSwatch(TypeColors.primaryTextLight, "Primary")
                colorSwatch(TypeColors.secondaryTextLight, "Secondary")
                colorSwatch(TypeColors.accent, "Accent")
            }
        }
        .padding()
        .background(Color.white)
        
        // Dark Mode
        VStack(spacing: 8) {
            Text("Dark Mode")
                .font(TypeTypography.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 4) {
                colorSwatch(TypeColors.editorBackgroundDark, "Editor")
                colorSwatch(TypeColors.sidebarBackgroundDark, "Sidebar")
                colorSwatch(TypeColors.toolbarBackgroundDark, "Toolbar")
            }
            
            HStack(spacing: 4) {
                colorSwatch(TypeColors.primaryTextDark, "Primary")
                colorSwatch(TypeColors.secondaryTextDark, "Secondary")
                colorSwatch(TypeColors.accent, "Accent")
            }
        }
        .padding()
        .background(Color.black)
        
        // Scene Colors
        HStack(spacing: 4) {
            colorSwatch(TypeColors.sceneRed, "")
            colorSwatch(TypeColors.sceneOrange, "")
            colorSwatch(TypeColors.sceneYellow, "")
            colorSwatch(TypeColors.sceneGreen, "")
            colorSwatch(TypeColors.sceneCyan, "")
            colorSwatch(TypeColors.sceneBlue, "")
            colorSwatch(TypeColors.scenePurple, "")
            colorSwatch(TypeColors.scenePink, "")
        }
    }
    .padding()
}

@ViewBuilder
private func colorSwatch(_ color: Color, _ label: String) -> some View {
    VStack(spacing: 2) {
        RoundedRectangle(cornerRadius: 4)
            .fill(color)
            .frame(width: 40, height: 30)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            )
        if !label.isEmpty {
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(.secondary)
        }
    }
}
