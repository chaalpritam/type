import SwiftUI

// MARK: - Screenplay Typography System
/// Professional typography settings for screenplay formatting
/// Inspired by industry-standard screenplay layout and Beat's approach
enum ScreenplayTypography {

    // MARK: - Line Spacing
    /// Industry-standard line spacing for better readability
    static let standardLineSpacing: CGFloat = 6.0  // ~1.5x spacing for 18pt font
    static let dialogueLineSpacing: CGFloat = 4.0  // Slightly tighter for dialogue
    static let actionLineSpacing: CGFloat = 6.0    // Standard for action lines

    // MARK: - Font Sizes
    static let editorFontSize: CGFloat = 18
    static let typewriterFontSize: CGFloat = 20
    static let previewFontSize: CGFloat = 14
    static let lineNumberFontSize: CGFloat = 12

    // MARK: - Font Weights
    static let sceneHeadingWeight: Font.Weight = .bold
    static let characterWeight: Font.Weight = .semibold
    static let actionWeight: Font.Weight = .regular
    static let dialogueWeight: Font.Weight = .regular
    static let transitionWeight: Font.Weight = .bold

    // MARK: - Element Spacing
    static let sceneHeadingTopPadding: CGFloat = 20
    static let sceneHeadingBottomPadding: CGFloat = 12
    static let characterTopPadding: CGFloat = 12
    static let dialogueLeftPadding: CGFloat = 40
    static let transitionRightPadding: CGFloat = 40

    // MARK: - Animation Timings
    static let elementTransitionDuration: Double = 0.15
    static let scrollAnimationDuration: Double = 0.3
    static let fadeInDuration: Double = 0.2

    // MARK: - Spring Animation
    static func springAnimation(response: Double = 0.3, dampingFraction: Double = 0.8) -> Animation {
        .spring(response: response, dampingFraction: dampingFraction)
    }

    static func smoothAnimation(duration: Double = 0.2) -> Animation {
        .easeInOut(duration: duration)
    }

    // MARK: - Font Helpers
    static func editorFont(size: CGFloat? = nil) -> Font {
        .system(size: size ?? editorFontSize, weight: .regular, design: .serif)
    }

    static func sceneHeadingFont(size: CGFloat? = nil) -> Font {
        .system(size: size ?? editorFontSize, weight: sceneHeadingWeight, design: .serif)
    }

    static func characterFont(size: CGFloat? = nil) -> Font {
        .system(size: size ?? editorFontSize, weight: characterWeight, design: .serif)
    }

    static func dialogueFont(size: CGFloat? = nil) -> Font {
        .system(size: size ?? editorFontSize, weight: dialogueWeight, design: .serif)
    }

    static func actionFont(size: CGFloat? = nil) -> Font {
        .system(size: size ?? editorFontSize, weight: actionWeight, design: .serif)
    }
}

// MARK: - Paper Texture Overlay
/// Subtle paper-like texture for authentic screenplay feel
struct PaperTextureOverlay: View {
    let opacity: Double

    init(opacity: Double = 0.015) {
        self.opacity = opacity
    }

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.black.opacity(opacity * 0.5), location: 0.0),
                        .init(color: Color.clear, location: 0.1),
                        .init(color: Color.black.opacity(opacity * 0.3), location: 0.3),
                        .init(color: Color.clear, location: 0.5),
                        .init(color: Color.black.opacity(opacity * 0.4), location: 0.7),
                        .init(color: Color.clear, location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blendMode(.multiply)
            .allowsHitTesting(false)
    }
}

// MARK: - Screenplay Paper Background
/// Authentic paper-like background with subtle texture
struct ScreenplayPaperBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Base paper color
            (colorScheme == .light ? TypeColors.editorBackgroundLight : TypeColors.editorBackgroundDark)
                .ignoresSafeArea()

            // Subtle paper texture (only in light mode for authenticity)
            if colorScheme == .light {
                PaperTextureOverlay(opacity: 0.012)
                    .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Text with Line Spacing Extension
extension Text {
    func screenplayLineSpacing(_ spacing: CGFloat = ScreenplayTypography.standardLineSpacing) -> some View {
        self.lineSpacing(spacing)
    }

    func sceneHeadingStyle() -> some View {
        self
            .font(ScreenplayTypography.sceneHeadingFont())
            .screenplayLineSpacing(ScreenplayTypography.standardLineSpacing)
    }

    func characterStyle() -> some View {
        self
            .font(ScreenplayTypography.characterFont())
            .screenplayLineSpacing(ScreenplayTypography.standardLineSpacing)
    }

    func dialogueStyle() -> some View {
        self
            .font(ScreenplayTypography.dialogueFont())
            .screenplayLineSpacing(ScreenplayTypography.dialogueLineSpacing)
    }

    func actionStyle() -> some View {
        self
            .font(ScreenplayTypography.actionFont())
            .screenplayLineSpacing(ScreenplayTypography.actionLineSpacing)
    }
}

// MARK: - Animated Element Transition
/// Smooth transition modifier for screenplay elements
struct ScreenplayElementTransition: ViewModifier {
    let isVisible: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1.0 : 0.0)
            .scaleEffect(isVisible ? 1.0 : 0.98)
            .animation(
                ScreenplayTypography.smoothAnimation(duration: ScreenplayTypography.elementTransitionDuration),
                value: isVisible
            )
    }
}

extension View {
    func screenplayTransition(isVisible: Bool = true) -> some View {
        self.modifier(ScreenplayElementTransition(isVisible: isVisible))
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("INT. COFFEE SHOP - DAY")
            .sceneHeadingStyle()
            .foregroundColor(.blue)

        Text("SARAH")
            .characterStyle()
            .foregroundColor(.purple)

        Text("This is a line of dialogue with proper spacing for readability.")
            .dialogueStyle()

        Text("This is an action line describing what happens in the scene with proper spacing.")
            .actionStyle()
    }
    .padding(40)
    .background(ScreenplayPaperBackground())
}
