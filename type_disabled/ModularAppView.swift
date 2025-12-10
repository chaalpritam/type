import SwiftUI
import AppKit

// MARK: - Modular App View
/// Main app view using the modular coordinator architecture
struct ModularAppView: View {
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced Apple-style toolbar
                    EnhancedAppleToolbar(
                        showPreview: Binding(
                            get: { appCoordinator.editorCoordinator.showPreview },
                            set: { appCoordinator.editorCoordinator.showPreview = $0 }
                        ),
                        showLineNumbers: Binding(
                            get: { appCoordinator.editorCoordinator.showLineNumbers },
                            set: { appCoordinator.editorCoordinator.showLineNumbers = $0 }
                        ),
                        showFindReplace: appCoordinator.editorCoordinator.showFindReplace,
                        showHelp: appCoordinator.editorCoordinator.showHelp,
                        canUndo: appCoordinator.editorCoordinator.canUndo,
                        canRedo: appCoordinator.editorCoordinator.canRedo,
                        onUndo: { appCoordinator.editorCoordinator.performUndo() },
                        onRedo: { appCoordinator.editorCoordinator.performRedo() },
                        selectedFont: .constant("SF Mono"),
                        fontSize: .constant(13),
                        isFullScreen: $appCoordinator.isFullScreen,
                        showCustomizationPanel: .constant(false),
                        animationSpeed: .constant(.normal),
                        onNewDocument: { appCoordinator.fileManagementService.newDocument() },
                        onOpenDocument: { appCoordinator.fileManagementService.openDocumentSync() },
                        onSaveDocument: { appCoordinator.fileManagementService.saveDocumentSync() },
                        onSaveDocumentAs: { appCoordinator.fileManagementService.saveDocumentAsSync() },
                        onExportDocument: { appCoordinator.fileManagementService.exportDocumentSync() },
                        canSave: appCoordinator.fileManagementService.canSave,
                        isDocumentModified: appCoordinator.fileManagementService.isDocumentModified,
                        currentDocumentName: appCoordinator.fileManagementService.currentDocumentName,
                        showCommentsPanel: Binding(
                            get: { appCoordinator.collaborationCoordinator.showCommentsPanel },
                            set: { appCoordinator.collaborationCoordinator.showCommentsPanel = $0 }
                        ),
                        showVersionHistory: Binding(
                            get: { appCoordinator.collaborationCoordinator.showVersionHistory },
                            set: { appCoordinator.collaborationCoordinator.showVersionHistory = $0 }
                        ),
                        showCollaboratorsPanel: Binding(
                            get: { appCoordinator.collaborationCoordinator.showCollaboratorsPanel },
                            set: { appCoordinator.collaborationCoordinator.showCollaboratorsPanel = $0 }
                        ),
                        showSharingDialog: Binding(
                            get: { appCoordinator.collaborationCoordinator.showSharingDialog },
                            set: { appCoordinator.collaborationCoordinator.showSharingDialog = $0 }
                        ),
                        collaboratorCount: appCoordinator.collaborationCoordinator.collaborators.count,
                        commentCount: appCoordinator.collaborationCoordinator.comments.count,
                        showTemplateSelector: Binding(
                            get: { appCoordinator.editorCoordinator.showTemplateSelector },
                            set: { appCoordinator.editorCoordinator.showTemplateSelector = $0 }
                        ),
                        showCharacterDatabase: Binding(
                            get: { appCoordinator.characterCoordinator.showCharacterDatabase },
                            set: { appCoordinator.characterCoordinator.showCharacterDatabase = $0 }
                        ),
                        characterCount: appCoordinator.characterCoordinator.characterDatabase.statistics.totalCharacters,
                        showOutlineMode: Binding(
                            get: { appCoordinator.outlineCoordinator.showOutlineMode },
                            set: { appCoordinator.outlineCoordinator.showOutlineMode = $0 }
                        ),
                        outlineDatabase: appCoordinator.outlineCoordinator.outlineDatabase,
                        editorContext: appCoordinator.currentView == .editor ? EditorToolbarContext(
                            isFocusMode: appCoordinator.editorCoordinator.isFocusModeActive,
                            isTypewriterMode: appCoordinator.editorCoordinator.isTypewriterModeActive,
                            hasMultipleCursors: appCoordinator.editorCoordinator.hasMultipleCursorsActive,
                            isMinimapVisible: appCoordinator.editorCoordinator.showMinimap,
                            wordCount: appCoordinator.editorCoordinator.wordCount,
                            pageCount: appCoordinator.editorCoordinator.pageCount,
                            characterCount: appCoordinator.editorCoordinator.characterCount,
                            toggleFocusMode: { appCoordinator.editorCoordinator.toggleFocusMode() },
                            toggleTypewriterMode: { appCoordinator.editorCoordinator.toggleTypewriterMode() },
                            toggleMultipleCursors: { appCoordinator.editorCoordinator.toggleMultipleCursors() },
                            toggleMinimap: { appCoordinator.editorCoordinator.toggleMinimap() }
                        ) : nil,
                        storyProtocolService: appCoordinator.storyProtocolService,
                        onProtect: { appCoordinator.storyProtocolCoordinator.showProtect() },
                        onNetworkSelect: { appCoordinator.storyProtocolCoordinator.showNetworkSelector = true },
                        onToggleFindReplace: { appCoordinator.editorCoordinator.toggleFindReplace() },
                        onToggleHelp: { appCoordinator.editorCoordinator.toggleHelp() }
                    )
                    
                    // Main content area
                    HStack(spacing: 0) {
                        // Main content
                        ModularContentView(appCoordinator: appCoordinator)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    // Enhanced Apple-style status bar
                    EnhancedAppleStatusBar(
                        wordCount: appCoordinator.statisticsService.wordCount,
                        pageCount: appCoordinator.statisticsService.pageCount,
                        characterCount: appCoordinator.statisticsService.characterCount,
                        showStatistics: Binding(
                            get: { appCoordinator.statisticsService.showWritingGoals },
                            set: { appCoordinator.statisticsService.showWritingGoals = $0 }
                        ),
                        smartFormattingManager: appCoordinator.editorCoordinator.smartFormattingManager,
                        animationSpeed: AnimationSpeed.normal,
                        autoSaveEnabled: appCoordinator.fileManagementService.autoSaveEnabled,
                        isDocumentModified: appCoordinator.fileManagementService.isDocumentModified,
                        currentDocumentName: appCoordinator.fileManagementService.currentDocumentName
                    )
                }
            }
            
            // Story Protocol Dialogs
            .overlay(
                Group {
                    if appCoordinator.storyProtocolCoordinator.showProtectionDialog {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                appCoordinator.storyProtocolCoordinator.showProtectionDialog = false
                            }
                        
                        ProtectionDialog(
                            coordinator: appCoordinator.storyProtocolCoordinator,
                            isPresented: Binding(
                                get: { appCoordinator.storyProtocolCoordinator.showProtectionDialog },
                                set: { appCoordinator.storyProtocolCoordinator.showProtectionDialog = $0 }
                            )
                        )
                    }
                }
            )
            .overlay(
                Group {
                    if appCoordinator.storyProtocolCoordinator.showConnectionDialog {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                appCoordinator.storyProtocolCoordinator.showConnectionDialog = false
                            }
                        
                        ConnectionDialog(
                            coordinator: appCoordinator.storyProtocolCoordinator,
                            isPresented: Binding(
                                get: { appCoordinator.storyProtocolCoordinator.showConnectionDialog },
                                set: { appCoordinator.storyProtocolCoordinator.showConnectionDialog = $0 }
                            )
                        )
                    }
                }
            )
        }
        .preferredColorScheme(.light)
        .onAppear {
            // Initialize with a new document if none exists
            if appCoordinator.documentService.currentDocument == nil {
                appCoordinator.documentService.newDocument()
            }
        }
    }
}


// MARK: - Modular Sidebar
struct ModularSidebar: View {
    @ObservedObject var appCoordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation
            VStack(spacing: 4) {
                ForEach(AppView.allCases, id: \.self) { view in
                    SidebarNavigationItem(
                        view: view,
                        isSelected: appCoordinator.currentView == view,
                        action: { appCoordinator.currentView = view }
                    )
                }
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // Quick stats
            QuickStatsView(appCoordinator: appCoordinator)
            
            Spacer()
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .border(Color(nsColor: .separatorColor), width: 0.5)
    }
}

// MARK: - Sidebar Navigation Item
struct SidebarNavigationItem: View {
    let view: AppView
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: view.icon)
                    .frame(width: 20)
                Text(view.rawValue)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick Stats View
struct QuickStatsView: View {
    @ObservedObject var appCoordinator: AppCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Stats")
                .font(.headline)
                .padding(.horizontal, 12)
            
            VStack(alignment: .leading, spacing: 4) {
                StatRow(label: "Words", value: "\(appCoordinator.editorCoordinator.wordCount)")
                StatRow(label: "Pages", value: "\(appCoordinator.editorCoordinator.pageCount)")
                StatRow(label: "Characters", value: "\(appCoordinator.characterCoordinator.statistics.totalCharacters)")
                StatRow(label: "Outlines", value: "\(appCoordinator.outlineCoordinator.outlines.count)")
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Modular Content View
struct ModularContentView: View {
    @ObservedObject var appCoordinator: AppCoordinator
    
    var body: some View {
        Group {
            switch appCoordinator.currentView {
            case .editor:
                appCoordinator.editorCoordinator.createView()
            case .characters:
                appCoordinator.characterCoordinator.createView()
            case .outline:
                appCoordinator.outlineCoordinator.createView()
            case .collaboration:
                appCoordinator.collaborationCoordinator.createView()
            }
        }
        .background(Color.white)
    }
}

// MARK: - Modular Status Bar
struct ModularStatusBar: View {
    @ObservedObject var appCoordinator: AppCoordinator
    
    var body: some View {
        HStack {
            // Document info
            Text(appCoordinator.fileCoordinator.currentDocumentName)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if appCoordinator.fileCoordinator.isDocumentModified {
                Text("• Modified")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            // Statistics
            HStack(spacing: 16) {
                Text("Words: \(appCoordinator.editorCoordinator.wordCount)")
                    .font(.caption)
                Text("Pages: \(appCoordinator.editorCoordinator.pageCount)")
                    .font(.caption)
                Text("Characters: \(appCoordinator.editorCoordinator.characterCount)")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(Color(nsColor: .windowBackgroundColor))
        .border(Color(nsColor: .separatorColor), width: 0.5)
    }
} 