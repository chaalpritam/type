//
//  TypeStyleAppView.swift
//  type
//
//  Minimalistic main app view for Type screenwriting app
//  Clean, elegant, distraction-free design
//

import SwiftUI
import AppKit

// MARK: - Type Style App View
struct TypeStyleAppView: View {
    @StateObject private var appCoordinator = AppCoordinator()
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var isSidebarCollapsed = false
    @State private var showFindReplace = false
    @State private var searchText = ""
    @State private var replaceText = ""
    @State private var isFocusMode = false
    @State private var showPreviewPanel = false
    @State private var showOutlinePanel = false
    @State private var showCharactersPanel = false
    @State private var showWelcomeScreen = false
    @State private var showTemplateSelector = false
    @State private var selectedTemplate: TemplateType = .default
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("showWelcomeOnLaunch") private var showWelcomeOnLaunch = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Toolbar
                    if !isFocusMode {
                        TypeToolbar(
                            onNewDocument: { appCoordinator.fileManagementService.newDocument() },
                            onOpenDocument: { appCoordinator.fileManagementService.openDocumentSync() },
                            onSaveDocument: { appCoordinator.fileManagementService.saveDocumentSync() },
                            canSave: appCoordinator.fileManagementService.canSave,
                            isDocumentModified: appCoordinator.fileManagementService.isDocumentModified,
                            canUndo: appCoordinator.editorCoordinator.canUndo,
                            canRedo: appCoordinator.editorCoordinator.canRedo,
                            onUndo: { appCoordinator.editorCoordinator.performUndo() },
                            onRedo: { appCoordinator.editorCoordinator.performRedo() },
                            showPreview: $showPreviewPanel,
                            showOutline: $showOutlinePanel,
                            showCharacters: $showCharactersPanel,
                            isFocusMode: $isFocusMode,
                            isDarkMode: $isDarkMode,
                            onToggleFindReplace: { 
                                withAnimation(TypeAnimation.standard) {
                                    showFindReplace.toggle()
                                }
                            },
                            showFindReplace: showFindReplace
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Find/Replace bar
                    if showFindReplace && !isFocusMode {
                        TypeFindReplaceBar(
                            isVisible: $showFindReplace,
                            searchText: $searchText,
                            replaceText: $replaceText,
                            resultCount: 0,
                            currentResult: 0,
                            onFindNext: {},
                            onFindPrevious: {},
                            onReplace: {},
                            onReplaceAll: {}
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Main content area
                    HStack(spacing: 0) {
                        // Sidebar
                        if !isFocusMode {
                            TypeSidebar(
                                selectedView: $appCoordinator.currentView,
                                isCollapsed: $isSidebarCollapsed,
                                wordCount: appCoordinator.editorCoordinator.wordCount,
                                pageCount: appCoordinator.editorCoordinator.pageCount,
                                sceneCount: appCoordinator.outlineCoordinator.outlines.count
                            )
                            .transition(.move(edge: .leading))
                        }
                        
                        // Main editor area
                        ZStack {
                            if showPreviewPanel {
                                TypePreviewPanel(
                                    elements: appCoordinator.editorCoordinator.fountainParser.elements,
                                    titlePage: appCoordinator.editorCoordinator.fountainParser.titlePage
                                )
                                .transition(.opacity)
                                .zIndex(1)
                            } else {
                                // Editor content
                                TypeContentView(
                                    appCoordinator: appCoordinator,
                                    isFocusMode: isFocusMode
                                )
                            }
                            
                            // Focus mode exit hint
                            if isFocusMode {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            withAnimation(TypeAnimation.smooth) {
                                                isFocusMode = false
                                            }
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "arrow.down.left.and.arrow.up.right")
                                                    .font(.system(size: 10))
                                                Text("Exit Focus")
                                                    .font(TypeTypography.caption2)
                                            }
                                            .foregroundColor(isDarkMode ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                Capsule()
                                                    .fill(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                                            )
                                        }
                                        .buttonStyle(.plain)
                                        .padding()
                                        .opacity(0.6)
                                        .onHover { hovering in
                                            // Increase opacity on hover
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        }
                        
                        // Side panels
                        if !isFocusMode {
                            // Preview panel removed from here to main area
                            
                            // Outline panel
                            
                            // Outline panel
                            if showOutlinePanel {
                                TypeOutlinePanel(
                                    outlineDatabase: appCoordinator.outlineCoordinator.outlineDatabase,
                                    isVisible: $showOutlinePanel
                                )
                                .frame(width: 280)
                                .transition(.move(edge: .trailing))
                            }
                            
                            // Characters panel
                            if showCharactersPanel {
                                TypeCharactersPanel(
                                    characterDatabase: appCoordinator.characterCoordinator.characterDatabase,
                                    isVisible: $showCharactersPanel
                                )
                                .frame(width: 280)
                                .transition(.move(edge: .trailing))
                            }
                        }
                    }
                    
                    // Status bar
                    if !isFocusMode {
                        TypeStatusBar(
                            documentName: appCoordinator.fileManagementService.currentDocumentName,
                            isModified: appCoordinator.fileManagementService.isDocumentModified,
                            wordCount: appCoordinator.editorCoordinator.wordCount,
                            pageCount: appCoordinator.editorCoordinator.pageCount,
                            cursorPosition: "Line 1, Col 1",
                            isAutoSaveEnabled: appCoordinator.fileManagementService.autoSaveEnabled
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                
                // Welcome screen overlay
                if showWelcomeScreen {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(TypeAnimation.standard) {
                                showWelcomeScreen = false
                            }
                        }
                    
                    WelcomeView(
                        isVisible: $showWelcomeScreen,
                        onNewDocument: {
                            showWelcomeScreen = false
                            appCoordinator.fileManagementService.newDocument()
                        },
                        onOpenDocument: {
                            showWelcomeScreen = false
                            appCoordinator.fileManagementService.openDocumentSync()
                        },
                        onSelectTemplate: { template in
                            showWelcomeScreen = false
                            applyTemplate(template)
                        }
                    )
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
                }
                
                // Template selector overlay
                if showTemplateSelector {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(TypeAnimation.standard) {
                                showTemplateSelector = false
                            }
                        }
                    
                    TemplateSelectorView(
                        selectedTemplate: $selectedTemplate,
                        isVisible: $showTemplateSelector,
                        onTemplateSelected: { template in
                            applyTemplate(template)
                            showTemplateSelector = false
                        }
                    )
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
                }
            }
            .animation(TypeAnimation.standard, value: isFocusMode)
            .animation(TypeAnimation.standard, value: showFindReplace)
            .animation(TypeAnimation.standard, value: showPreviewPanel)
            .animation(TypeAnimation.standard, value: showOutlinePanel)
            .animation(TypeAnimation.standard, value: showCharactersPanel)
            .animation(TypeAnimation.standard, value: showWelcomeScreen)
            .animation(TypeAnimation.standard, value: showTemplateSelector)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            if appCoordinator.documentService.currentDocument == nil {
                appCoordinator.documentService.newDocument()
            }
            // Show welcome screen on first launch
            if showWelcomeOnLaunch {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(TypeAnimation.standard) {
                        showWelcomeScreen = true
                    }
                }
            }
        }
        // Keyboard shortcuts
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            setupKeyboardShortcuts()
        }
        // Handle notification center messages
        .onReceive(NotificationCenter.default.publisher(for: .showWelcome)) { _ in
            withAnimation(TypeAnimation.standard) {
                showWelcomeScreen = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showTemplates)) { _ in
            withAnimation(TypeAnimation.standard) {
                showTemplateSelector = true
            }
        }
    }
    
    private var backgroundColor: Color {
        isDarkMode ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight
    }
    
    private func setupKeyboardShortcuts() {
        // Escape to exit focus mode or close modals
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 { // Escape key
                if showWelcomeScreen {
                    withAnimation(TypeAnimation.smooth) {
                        showWelcomeScreen = false
                    }
                    return nil
                }
                if showTemplateSelector {
                    withAnimation(TypeAnimation.smooth) {
                        showTemplateSelector = false
                    }
                    return nil
                }
                if isFocusMode {
                    withAnimation(TypeAnimation.smooth) {
                        isFocusMode = false
                    }
                    return nil
                }
            }
            return event
        }
    }
    
    private func applyTemplate(_ template: TemplateType) {
        let content = FountainTemplate.getTemplate(for: template)
        appCoordinator.editorCoordinator.text = content
        appCoordinator.editorCoordinator.updateText(content)
    }
}

// MARK: - Type Content View
struct TypeContentView: View {
    @ObservedObject var appCoordinator: AppCoordinator
    let isFocusMode: Bool
    
    var body: some View {
        Group {
            switch appCoordinator.currentView {
            case .editor:
                TypeEditorView(
                    coordinator: appCoordinator.editorCoordinator,
                    isFocusMode: isFocusMode
                )
            case .characters:
                appCoordinator.characterCoordinator.createView()
            case .outline:
                appCoordinator.outlineCoordinator.createView()
            case .collaboration:
                appCoordinator.collaborationCoordinator.createView()
            }
        }
    }
}

// MARK: - Type Editor View
struct TypeEditorView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var coordinator: EditorCoordinator
    let isFocusMode: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    // Editor with proper screenplay margins
                    TypeTextEditor(
                        text: $coordinator.text,
                        placeholder: "Start writing your screenplay...\n\nUse Fountain syntax for formatting:\n• INT. LOCATION - DAY for scene headings\n• Character names in UPPERCASE\n• (parenthetical) in parentheses\n• > for transitions",
                        isFocusMode: isFocusMode,
                        onTextChange: { newText in
                            coordinator.updateText(newText)
                        }
                    )
                    .frame(minHeight: max(geometry.size.height - 80, 400))
                }
                .frame(maxWidth: isFocusMode ? 700 : .infinity)
                .frame(maxWidth: .infinity)
            }
            .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
        }
    }
}

// MARK: - Type Text Editor
struct TypeTextEditor: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var text: String
    let placeholder: String
    let isFocusMode: Bool
    let onTextChange: (String) -> Void
    
    @FocusState private var isEditorFocused: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background TextEditor
            TextEditor(text: $text)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundColor(.clear)
                .background(Color.clear)
                .scrollContentBackground(.hidden)
                .focused($isEditorFocused)
                .onChange(of: text) { _, newValue in
                    onTextChange(newValue)
                }
            
            // Syntax highlighted overlay
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                    .allowsHitTesting(false)
            } else {
                FountainSyntaxHighlighter(
                    text: text,
                    font: .system(size: 14, weight: .regular, design: .monospaced),
                    baseColor: colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight
                )
                .allowsHitTesting(false)
            }
        }
        .padding(.horizontal, isFocusMode ? TypeSpacing.xxl * 2 : TypeSpacing.editorHorizontalPadding)
        .padding(.vertical, TypeSpacing.editorVerticalPadding)
        .onAppear {
            isEditorFocused = true
        }
    }
}

// MARK: - Type Preview Panel
struct TypePreviewPanel: View {
    @Environment(\.colorScheme) var colorScheme
    let elements: [FountainElement]
    let titlePage: [String: String]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Preview")
                    .font(TypeTypography.subheadline)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                Spacer()
                
                Text("\(elements.count) elements")
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            }
            .padding(.horizontal, TypeSpacing.md)
            .padding(.vertical, TypeSpacing.sm)
            .background(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
            
            Divider()
            
            // Preview content
            ScrollView {
                VStack(alignment: .leading, spacing: TypeSpacing.sm) {
                    ForEach(Array(elements.enumerated()), id: \.offset) { index, element in
                        TypePreviewElement(element: element)
                    }
                }
                .padding(TypeSpacing.md)
            }
        }
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
        .overlay(
            Rectangle()
                .frame(width: 0.5)
                .foregroundColor(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight),
            alignment: .leading
        )
    }
}

// MARK: - Type Preview Element
struct TypePreviewElement: View {
    @Environment(\.colorScheme) var colorScheme
    let element: FountainElement
    
    var body: some View {
        Text(element.text)
            .font(fontForElement)
            .foregroundColor(colorForElement)
            .frame(maxWidth: .infinity, alignment: alignmentForElement)
            .padding(.leading, leadingPaddingForElement)
    }
    
    private var fontForElement: Font {
        switch element.type {
        case .sceneHeading:
            return TypeTypography.sceneHeading(size: 12)
        case .character:
            return TypeTypography.character(size: 11)
        case .dialogue:
            return TypeTypography.dialogue(size: 11)
        case .parenthetical:
            return TypeTypography.parenthetical(size: 10)
        case .transition:
            return TypeTypography.transition(size: 11)
        default:
            return TypeTypography.action(size: 11)
        }
    }
    
    private var colorForElement: Color {
        switch element.type {
        case .sceneHeading:
            return TypeColors.accent
        case .character:
            return TypeColors.scenePurple
        case .dialogue:
            return colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight
        case .parenthetical:
            return colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight
        case .transition:
            return TypeColors.sceneOrange
        default:
            return colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight
        }
    }
    
    private var alignmentForElement: Alignment {
        switch element.type {
        case .character, .parenthetical:
            return .center
        case .transition:
            return .trailing
        default:
            return .leading
        }
    }
    
    private var leadingPaddingForElement: CGFloat {
        switch element.type {
        case .dialogue:
            return 40
        case .parenthetical:
            return 60
        default:
            return 0
        }
    }
}

// MARK: - Type Outline Panel
struct TypeOutlinePanel: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var outlineDatabase: OutlineDatabase
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Outline")
                    .font(TypeTypography.subheadline)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                Spacer()
                
                Button(action: { isVisible = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, TypeSpacing.md)
            .padding(.vertical, TypeSpacing.sm)
            .background(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
            
            Divider()
            
            // Outline content
            if outlineDatabase.outline.rootNodes.isEmpty {
                TypeEmptyState(
                    icon: "list.bullet.indent",
                    title: "No Outline",
                    message: "Start writing to see your screenplay structure here."
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(outlineDatabase.outline.rootNodes) { node in
                            TypeOutlineItem(node: node, outlineDatabase: outlineDatabase)
                        }
                    }
                    .padding(TypeSpacing.sm)
                }
            }
        }
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
        .overlay(
            Rectangle()
                .frame(width: 0.5)
                .foregroundColor(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight),
            alignment: .leading
        )
    }
}

// MARK: - Type Outline Item
struct TypeOutlineItem: View {
    @Environment(\.colorScheme) var colorScheme
    let node: OutlineNode
    @ObservedObject var outlineDatabase: OutlineDatabase
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: TypeSpacing.xs) {
            // Expand/collapse for nodes with children
            if !node.children.isEmpty {
                Button(action: {
                    if outlineDatabase.navigation.expandedNodes.contains(node.id) {
                        outlineDatabase.collapseNode(node.id)
                    } else {
                        outlineDatabase.expandNode(node.id)
                    }
                }) {
                    Image(systemName: outlineDatabase.navigation.expandedNodes.contains(node.id) ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9))
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                        .frame(width: 12)
                }
                .buttonStyle(.plain)
            } else {
                Color.clear.frame(width: 12)
            }
            
            // Node icon
            Circle()
                .fill(colorForNodeType(node.nodeType))
                .frame(width: 6, height: 6)
            
            // Node title
            Text(node.title)
                .font(TypeTypography.caption)
                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.horizontal, TypeSpacing.xs)
        .padding(.vertical, TypeSpacing.xxs)
        .padding(.leading, CGFloat(node.level) * 12)
        .background(
            RoundedRectangle(cornerRadius: TypeRadius.xs)
                .fill(isHovered ? (colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.03)) : .clear)
        )
        .onHover { hovering in
            isHovered = hovering
        }
        
        // Children
        if !node.children.isEmpty && outlineDatabase.navigation.expandedNodes.contains(node.id) {
            ForEach(node.children) { child in
                TypeOutlineItem(node: child, outlineDatabase: outlineDatabase)
            }
        }
    }
    
    private func colorForNodeType(_ type: NodeType) -> Color {
        switch type {
        case .scene: return TypeColors.sceneGreen
        case .act: return TypeColors.scenePurple
        case .sequence: return TypeColors.sceneOrange
        case .character: return TypeColors.scenePink
        default: return TypeColors.sceneBlue
        }
    }
}

// MARK: - Type Characters Panel
struct TypeCharactersPanel: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var characterDatabase: CharacterDatabase
    @Binding var isVisible: Bool
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Characters")
                    .font(TypeTypography.subheadline)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                Spacer()
                
                Text("\(characterDatabase.statistics.totalCharacters)")
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(TypeColors.accent.opacity(0.15))
                    )
                
                Button(action: { isVisible = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, TypeSpacing.md)
            .padding(.vertical, TypeSpacing.sm)
            .background(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
            
            Divider()
            
            // Search
            HStack(spacing: TypeSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11))
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                
                TextField("Search characters...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(TypeTypography.caption)
            }
            .padding(.horizontal, TypeSpacing.sm)
            .padding(.vertical, TypeSpacing.xs)
            .background(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.03))
            .padding(.horizontal, TypeSpacing.sm)
            .padding(.vertical, TypeSpacing.sm)
            
            // Character list
            if characterDatabase.characters.isEmpty {
                TypeEmptyState(
                    icon: "person.2",
                    title: "No Characters",
                    message: "Characters will appear here as you write."
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(filteredCharacters) { character in
                            TypeCharacterItem(character: character)
                        }
                    }
                    .padding(TypeSpacing.sm)
                }
            }
        }
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
        .overlay(
            Rectangle()
                .frame(width: 0.5)
                .foregroundColor(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight),
            alignment: .leading
        )
    }
    
    private var filteredCharacters: [Character] {
        if searchText.isEmpty {
            return characterDatabase.characters
        }
        return characterDatabase.characters.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}

// MARK: - Type Character Item
struct TypeCharacterItem: View {
    @Environment(\.colorScheme) var colorScheme
    let character: Character
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: TypeSpacing.sm) {
            // Avatar
            Circle()
                .fill(TypeColors.accent.opacity(0.15))
                .frame(width: 24, height: 24)
                .overlay(
                    Text(String(character.name.prefix(1)).uppercased())
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(TypeColors.accent)
                )
            
            // Name
            Text(character.name)
                .font(TypeTypography.caption)
                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                .lineLimit(1)
            
            Spacer()
            
            // Dialogue count
            if character.dialogueCount > 0 {
                Text("\(character.dialogueCount)")
                    .font(TypeTypography.caption2)
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            }
        }
        .padding(.horizontal, TypeSpacing.sm)
        .padding(.vertical, TypeSpacing.xs)
        .background(
            RoundedRectangle(cornerRadius: TypeRadius.sm)
                .fill(isHovered ? (colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.03)) : .clear)
        )
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Preview
#Preview("Type Style App") {
    TypeStyleAppView()
        .frame(width: 1200, height: 800)
}
