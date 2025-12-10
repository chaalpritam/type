import SwiftUI

// MARK: - Welcome View
struct WelcomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isVisible: Bool
    let onNewDocument: () -> Void
    let onOpenDocument: () -> Void
    let onSelectTemplate: (TemplateType) -> Void
    
    @State private var selectedTab: WelcomeTab = .start
    @State private var recentFiles: [RecentFile] = []
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            WelcomeSidebar(selectedTab: $selectedTab)
            
            // Content
            ZStack {
                switch selectedTab {
                case .start:
                    WelcomeStartView(
                        onNewDocument: onNewDocument,
                        onOpenDocument: onOpenDocument,
                        recentFiles: recentFiles
                    )
                case .templates:
                    WelcomeTemplatesView(onSelectTemplate: { template in
                        onSelectTemplate(template)
                        isVisible = false
                    })
                case .tutorials:
                    WelcomeTutorialsView()
                case .whatsNew:
                    WelcomeWhatsNewView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 900, minHeight: 600)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
    }
}

// MARK: - Welcome Tab
enum WelcomeTab: String, CaseIterable {
    case start = "Start"
    case templates = "Templates"
    case tutorials = "Tutorials"
    case whatsNew = "What's New"
    
    var icon: String {
        switch self {
        case .start: return "house"
        case .templates: return "doc.text"
        case .tutorials: return "book"
        case .whatsNew: return "sparkles"
        }
    }
}

// MARK: - Welcome Sidebar
struct WelcomeSidebar: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedTab: WelcomeTab
    
    var body: some View {
        VStack(spacing: 0) {
            // Logo
            VStack(spacing: TypeSpacing.sm) {
                Image(systemName: "pencil.and.outline")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(TypeColors.accent)
                
                Text("Type")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                Text("Screenwriting")
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            }
            .padding(.top, TypeSpacing.xxl)
            .padding(.bottom, TypeSpacing.xl)
            
            // Navigation
            VStack(spacing: TypeSpacing.xxs) {
                ForEach(WelcomeTab.allCases, id: \.self) { tab in
                    WelcomeSidebarItem(
                        icon: tab.icon,
                        title: tab.rawValue,
                        isSelected: selectedTab == tab
                    ) {
                        withAnimation(TypeAnimation.standard) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, TypeSpacing.md)
            
            Spacer()
            
            // Version
            Text("Version 1.0")
                .font(TypeTypography.caption2)
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                .padding(.bottom, TypeSpacing.lg)
        }
        .frame(width: 200)
        .background(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
        .overlay(
            Rectangle()
                .frame(width: 0.5)
                .foregroundColor(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight),
            alignment: .trailing
        )
    }
}

// MARK: - Welcome Sidebar Item
struct WelcomeSidebarItem: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: TypeSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? TypeColors.accent : (colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight))
                    .frame(width: 20)
                
                Text(title)
                    .font(TypeTypography.body)
                    .foregroundColor(isSelected ? TypeColors.accent : (colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight))
                
                Spacer()
            }
            .padding(.horizontal, TypeSpacing.sm)
            .padding(.vertical, TypeSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: TypeRadius.sm)
                    .fill(isSelected ? TypeColors.accent.opacity(0.12) : (isHovered ? (colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.03)) : .clear))
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovered = hovering }
    }
}

// MARK: - Recent File
struct RecentFile: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let lastOpened: Date
}

// MARK: - Welcome Start View
struct WelcomeStartView: View {
    @Environment(\.colorScheme) var colorScheme
    let onNewDocument: () -> Void
    let onOpenDocument: () -> Void
    let recentFiles: [RecentFile]
    
    var body: some View {
        ScrollView {
            VStack(spacing: TypeSpacing.xxl) {
                // Header
                VStack(spacing: TypeSpacing.sm) {
                    Text("Welcome to Type")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    
                    Text("Professional screenwriting for macOS")
                        .font(TypeTypography.body)
                        .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                }
                .padding(.top, TypeSpacing.xxl)
                
                // Quick Actions
                HStack(spacing: TypeSpacing.lg) {
                    WelcomeActionCard(
                        icon: "doc.badge.plus",
                        title: "New Screenplay",
                        description: "Start with a blank document",
                        color: TypeColors.accent,
                        action: onNewDocument
                    )
                    
                    WelcomeActionCard(
                        icon: "folder",
                        title: "Open Document",
                        description: "Open an existing file",
                        color: TypeColors.sceneGreen,
                        action: onOpenDocument
                    )
                    
                    WelcomeActionCard(
                        icon: "doc.text",
                        title: "From Template",
                        description: "Start from a template",
                        color: TypeColors.scenePurple,
                        action: {}
                    )
                }
                .padding(.horizontal, TypeSpacing.xxl)
                
                // Features
                VStack(alignment: .leading, spacing: TypeSpacing.lg) {
                    Text("FEATURES")
                        .font(TypeTypography.caption)
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                        .tracking(0.8)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: TypeSpacing.md) {
                        WelcomeFeatureItem(icon: "text.cursor", title: "Fountain Syntax", description: "Industry-standard format")
                        WelcomeFeatureItem(icon: "eye", title: "Live Preview", description: "See your screenplay in real-time")
                        WelcomeFeatureItem(icon: "person.2", title: "Character Database", description: "Track all your characters")
                        WelcomeFeatureItem(icon: "list.bullet.indent", title: "Outline Mode", description: "Structure your story")
                        WelcomeFeatureItem(icon: "moon", title: "Dark Mode", description: "Easy on the eyes")
                        WelcomeFeatureItem(icon: "keyboard", title: "Focus Mode", description: "Distraction-free writing")
                    }
                }
                .padding(.horizontal, TypeSpacing.xxl)
                
                Spacer()
            }
        }
    }
}

// MARK: - Welcome Action Card
struct WelcomeActionCard: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: TypeSpacing.md) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                VStack(spacing: TypeSpacing.xxs) {
                    Text(title)
                        .font(TypeTypography.headline)
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    
                    Text(description)
                        .font(TypeTypography.caption)
                        .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TypeSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: TypeRadius.lg)
                    .fill(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
            )
            .overlay(
                RoundedRectangle(cornerRadius: TypeRadius.lg)
                    .stroke(isHovered ? color.opacity(0.5) : (colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight), lineWidth: isHovered ? 2 : 0.5)
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(TypeAnimation.quick, value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovered = hovering }
    }
}

// MARK: - Welcome Feature Item
struct WelcomeFeatureItem: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: TypeSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(TypeColors.accent)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(TypeTypography.subheadline)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                Text(description)
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            }
            
            Spacer()
        }
        .padding(TypeSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: TypeRadius.md)
                .fill(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
        )
    }
}

// MARK: - Welcome Templates View
struct WelcomeTemplatesView: View {
    @Environment(\.colorScheme) var colorScheme
    let onSelectTemplate: (TemplateType) -> Void
    
    @State private var selectedCategory: TemplateCategory = .basic
    @State private var hoveredTemplate: TemplateType?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: TypeSpacing.sm) {
                Text("Templates")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                Text("Start your screenplay with a professionally structured template")
                    .font(TypeTypography.body)
                    .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
            }
            .padding(.top, TypeSpacing.xl)
            .padding(.bottom, TypeSpacing.lg)
            
            // Category tabs
            HStack(spacing: TypeSpacing.sm) {
                ForEach(TemplateCategory.allCases, id: \.self) { category in
                    WelcomeCategoryTab(
                        title: category.rawValue,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(TypeAnimation.standard) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, TypeSpacing.xl)
            .padding(.bottom, TypeSpacing.lg)
            
            // Templates grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: TypeSpacing.md) {
                    ForEach(selectedCategory.templates, id: \.self) { template in
                        WelcomeTemplateCard(
                            template: template,
                            isHovered: hoveredTemplate == template,
                            onSelect: { onSelectTemplate(template) }
                        )
                        .onHover { hovering in
                            hoveredTemplate = hovering ? template : nil
                        }
                    }
                }
                .padding(.horizontal, TypeSpacing.xl)
                .padding(.bottom, TypeSpacing.xl)
            }
        }
    }
}

// MARK: - Welcome Category Tab
struct WelcomeCategoryTab: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(TypeTypography.subheadline)
                .foregroundColor(isSelected ? TypeColors.accent : (colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight))
                .padding(.horizontal, TypeSpacing.md)
                .padding(.vertical, TypeSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: TypeRadius.full)
                        .fill(isSelected ? TypeColors.accent.opacity(0.12) : .clear)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Welcome Template Card
struct WelcomeTemplateCard: View {
    @Environment(\.colorScheme) var colorScheme
    let template: TemplateType
    let isHovered: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: TypeSpacing.md) {
                HStack {
                    Image(systemName: iconForTemplate(template))
                        .font(.system(size: 20))
                        .foregroundColor(colorForTemplate(template))
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle")
                        .font(.system(size: 16))
                        .foregroundColor(TypeColors.accent)
                        .opacity(isHovered ? 1 : 0)
                }
                
                VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
                    Text(template.rawValue)
                        .font(TypeTypography.headline)
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    
                    Text(template.description)
                        .font(TypeTypography.caption)
                        .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                        .lineLimit(2)
                }
            }
            .padding(TypeSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: TypeRadius.lg)
                    .fill(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
            )
            .overlay(
                RoundedRectangle(cornerRadius: TypeRadius.lg)
                    .stroke(isHovered ? TypeColors.accent.opacity(0.5) : (colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight), lineWidth: isHovered ? 2 : 0.5)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func iconForTemplate(_ template: TemplateType) -> String {
        switch template {
        case .default, .short: return "doc.text"
        case .tvDramaPilot, .tvComedyPilot: return "tv"
        case .actionFeature: return "bolt.fill"
        case .romanticComedy: return "heart.fill"
        case .sciFiFeature: return "star.fill"
        case .shortDrama: return "theatermasks"
        case .shortComedy: return "face.smiling"
        case .horrorFeature: return "moon.fill"
        case .mysteryFeature: return "magnifyingglass"
        case .stagePlay: return "curtains.closed"
        case .podcast: return "mic.fill"
        case .documentary: return "video.fill"
        }
    }
    
    private func colorForTemplate(_ template: TemplateType) -> Color {
        switch template {
        case .default, .short: return TypeColors.accent
        case .tvDramaPilot: return TypeColors.sceneBlue
        case .tvComedyPilot: return TypeColors.sceneYellow
        case .actionFeature: return TypeColors.sceneRed
        case .romanticComedy: return TypeColors.scenePink
        case .sciFiFeature: return TypeColors.scenePurple
        case .shortDrama: return TypeColors.sceneOrange
        case .shortComedy: return TypeColors.sceneGreen
        case .horrorFeature: return TypeColors.scenePurple
        case .mysteryFeature: return TypeColors.sceneCyan
        case .stagePlay: return TypeColors.sceneRed
        case .podcast: return TypeColors.sceneYellow
        case .documentary: return TypeColors.sceneBlue
        }
    }
}

// MARK: - Welcome Tutorials View
struct WelcomeTutorialsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: TypeSpacing.xl) {
                // Header
                VStack(spacing: TypeSpacing.sm) {
                    Text("Learn Type")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    
                    Text("Master professional screenwriting with our guides")
                        .font(TypeTypography.body)
                        .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                }
                .padding(.top, TypeSpacing.xl)
                
                // Getting Started
                TutorialSection(title: "Getting Started") {
                    TutorialCard(
                        icon: "1.circle.fill",
                        title: "Introduction to Type",
                        description: "Learn the basics of the Type interface and how to navigate the app",
                        duration: "5 min",
                        color: TypeColors.accent
                    )
                    
                    TutorialCard(
                        icon: "2.circle.fill",
                        title: "Your First Screenplay",
                        description: "Create your first screenplay from scratch with step-by-step guidance",
                        duration: "10 min",
                        color: TypeColors.sceneGreen
                    )
                    
                    TutorialCard(
                        icon: "3.circle.fill",
                        title: "Understanding Fountain",
                        description: "Master the Fountain markup language for professional screenwriting",
                        duration: "15 min",
                        color: TypeColors.scenePurple
                    )
                }
                
                // Fountain Syntax
                TutorialSection(title: "Fountain Syntax") {
                    TutorialCard(
                        icon: "text.cursor",
                        title: "Scene Headings",
                        description: "Learn how to write scene headings (sluglines) properly",
                        duration: "3 min",
                        color: TypeColors.sceneBlue
                    )
                    
                    TutorialCard(
                        icon: "person.fill",
                        title: "Characters & Dialogue",
                        description: "Format character names, dialogue, and parentheticals",
                        duration: "5 min",
                        color: TypeColors.scenePink
                    )
                    
                    TutorialCard(
                        icon: "text.alignleft",
                        title: "Action Lines",
                        description: "Write compelling action descriptions",
                        duration: "4 min",
                        color: TypeColors.sceneOrange
                    )
                    
                    TutorialCard(
                        icon: "arrow.right.circle",
                        title: "Transitions",
                        description: "Use transitions like CUT TO:, FADE OUT, etc.",
                        duration: "2 min",
                        color: TypeColors.sceneCyan
                    )
                }
                
                // Advanced Features
                TutorialSection(title: "Advanced Features") {
                    TutorialCard(
                        icon: "person.2",
                        title: "Character Database",
                        description: "Track and manage all characters in your screenplay",
                        duration: "8 min",
                        color: TypeColors.scenePink
                    )
                    
                    TutorialCard(
                        icon: "list.bullet.indent",
                        title: "Outline Mode",
                        description: "Structure your story with the powerful outline feature",
                        duration: "10 min",
                        color: TypeColors.sceneGreen
                    )
                    
                    TutorialCard(
                        icon: "eye",
                        title: "Live Preview",
                        description: "See your screenplay formatted in real-time",
                        duration: "5 min",
                        color: TypeColors.sceneBlue
                    )
                    
                    TutorialCard(
                        icon: "keyboard",
                        title: "Keyboard Shortcuts",
                        description: "Speed up your workflow with essential shortcuts",
                        duration: "5 min",
                        color: TypeColors.scenePurple
                    )
                }
                
                // Best Practices
                TutorialSection(title: "Best Practices") {
                    TutorialCard(
                        icon: "checkmark.seal",
                        title: "Industry Standards",
                        description: "Write screenplays that meet professional standards",
                        duration: "12 min",
                        color: TypeColors.sceneYellow
                    )
                    
                    TutorialCard(
                        icon: "doc.text.magnifyingglass",
                        title: "Common Mistakes",
                        description: "Avoid common formatting and writing mistakes",
                        duration: "8 min",
                        color: TypeColors.error
                    )
                }
            }
            .padding(.horizontal, TypeSpacing.xl)
            .padding(.bottom, TypeSpacing.xl)
        }
    }
}

// MARK: - Tutorial Section
struct TutorialSection<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.md) {
            Text(title.uppercased())
                .font(TypeTypography.caption)
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                .tracking(0.8)
            
            content
        }
    }
}

// MARK: - Tutorial Card
struct TutorialCard: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    let description: String
    let duration: String
    let color: Color
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: TypeSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
                    Text(title)
                        .font(TypeTypography.body)
                        .fontWeight(.medium)
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    
                    Text(description)
                        .font(TypeTypography.caption)
                        .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: TypeSpacing.xxs) {
                    Text(duration)
                        .font(TypeTypography.caption)
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(isHovered ? color : (colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight))
                }
            }
            .padding(TypeSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: TypeRadius.md)
                    .fill(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
            )
            .overlay(
                RoundedRectangle(cornerRadius: TypeRadius.md)
                    .stroke(isHovered ? color.opacity(0.5) : (colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight), lineWidth: isHovered ? 1.5 : 0.5)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovered = hovering }
    }
}

// MARK: - Welcome What's New View
struct WelcomeWhatsNewView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: TypeSpacing.xl) {
                // Header
                VStack(spacing: TypeSpacing.sm) {
                    Text("What's New")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    
                    Text("Latest updates and improvements in Type")
                        .font(TypeTypography.body)
                        .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                }
                .padding(.top, TypeSpacing.xl)
                
                // Version 1.0
                WhatsNewSection(version: "1.0", date: "December 2024") {
                    WhatsNewItem(
                        icon: "sparkles",
                        title: "Redesigned Interface",
                        description: "A beautiful, minimalistic UI inspired by professional screenwriting apps",
                        isNew: true
                    )
                    
                    WhatsNewItem(
                        icon: "person.2",
                        title: "Character Database",
                        description: "Track characters, relationships, arcs, and notes",
                        isNew: true
                    )
                    
                    WhatsNewItem(
                        icon: "list.bullet.indent",
                        title: "Outline Mode",
                        description: "Structure your screenplay with a powerful outline view",
                        isNew: true
                    )
                    
                    WhatsNewItem(
                        icon: "eye",
                        title: "Live Preview",
                        description: "See your screenplay formatted in real-time",
                        isNew: true
                    )
                    
                    WhatsNewItem(
                        icon: "keyboard",
                        title: "Focus Mode",
                        description: "Distraction-free writing environment",
                        isNew: true
                    )
                    
                    WhatsNewItem(
                        icon: "moon",
                        title: "Dark Mode",
                        description: "Beautiful dark theme for comfortable writing",
                        isNew: true
                    )
                    
                    WhatsNewItem(
                        icon: "doc.text",
                        title: "Templates",
                        description: "Start with professionally structured templates",
                        isNew: true
                    )
                    
                    WhatsNewItem(
                        icon: "text.cursor",
                        title: "Fountain Support",
                        description: "Full support for Fountain screenplay format",
                        isNew: true
                    )
                }
            }
            .padding(.horizontal, TypeSpacing.xl)
            .padding(.bottom, TypeSpacing.xl)
        }
    }
}

// MARK: - What's New Section
struct WhatsNewSection<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let version: String
    let date: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.md) {
            HStack {
                Text("Version \(version)")
                    .font(TypeTypography.headline)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                Spacer()
                
                Text(date)
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            }
            
            content
        }
    }
}

// MARK: - What's New Item
struct WhatsNewItem: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    let description: String
    var isNew: Bool = false
    
    var body: some View {
        HStack(spacing: TypeSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(TypeColors.accent)
                .frame(width: 32, height: 32)
                .background(TypeColors.accent.opacity(0.12))
                .cornerRadius(TypeRadius.sm)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: TypeSpacing.sm) {
                    Text(title)
                        .font(TypeTypography.body)
                        .fontWeight(.medium)
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    
                    if isNew {
                        Text("NEW")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(TypeColors.sceneGreen)
                            .cornerRadius(TypeRadius.xs)
                    }
                }
                
                Text(description)
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
            }
            
            Spacer()
        }
        .padding(TypeSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: TypeRadius.md)
                .fill(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
        )
    }
}
