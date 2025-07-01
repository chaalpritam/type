import SwiftUI
import Core.AppCoordinator
import Features.Editor.EditorCoordinator
import Features.Characters.CharacterCoordinator
import Features.Outline.OutlineCoordinator
import Features.Collaboration.CollaborationCoordinator
// EnhancedAppleComponents is in the same module, no need for explicit import

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
                        showPreview: $appCoordinator.editorCoordinator.showPreview,
                        showLineNumbers: .constant(true),
                        showFindReplace: $appCoordinator.editorCoordinator.showFindReplace,
                        showHelp: $appCoordinator.editorCoordinator.showHelp,
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
                        showCommentsPanel: $appCoordinator.collaborationCoordinator.showCommentsPanel,
                        showVersionHistory: $appCoordinator.collaborationCoordinator.showVersionHistory,
                        showCollaboratorsPanel: $appCoordinator.collaborationCoordinator.showCollaboratorsPanel,
                        showSharingDialog: $appCoordinator.collaborationCoordinator.showSharingDialog,
                        collaboratorCount: appCoordinator.collaborationCoordinator.collaborators.count,
                        commentCount: appCoordinator.collaborationCoordinator.comments.count,
                        showTemplateSelector: $appCoordinator.editorCoordinator.showTemplateSelector,
                        showCharacterDatabase: $appCoordinator.characterCoordinator.showCharacterDatabase,
                        characterCount: appCoordinator.characterCoordinator.characterDatabase.statistics.totalCharacters,
                        showOutlineMode: $appCoordinator.outlineCoordinator.showOutlineMode,
                        outlineDatabase: appCoordinator.outlineCoordinator.outlineDatabase
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
                        showStatistics: $appCoordinator.statisticsService.showWritingGoals,
                        smartFormattingManager: appCoordinator.editorCoordinator.smartFormattingManager,
                        animationSpeed: .constant(.normal),
                        autoSaveEnabled: appCoordinator.fileManagementService.autoSaveEnabled,
                        isDocumentModified: appCoordinator.fileManagementService.isDocumentModified,
                        currentDocumentName: appCoordinator.fileManagementService.currentDocumentName
                    )
                }
            }
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

// MARK: - Modular Toolbar
struct ModularToolbar: View {
    @ObservedObject var appCoordinator: AppCoordinator
    
    var body: some View {
        HStack {
            // File operations
            FileToolbarSection(appCoordinator: appCoordinator)
            
            Divider()
            
            // View controls
            ViewToolbarSection(appCoordinator: appCoordinator)
            
            Divider()
            
            // Collaboration controls
            CollaborationToolbarSection(appCoordinator: appCoordinator)
            
            Spacer()
            
            // Settings
            SettingsToolbarSection(appCoordinator: appCoordinator)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .border(Color(.systemGray4), width: 0.5)
    }
}

// MARK: - File Toolbar Section
struct FileToolbarSection: View {
    @ObservedObject var appCoordinator: AppCoordinator
    
    var body: some View {
        HStack(spacing: 8) {
            Button("New") {
                appCoordinator.fileCoordinator.newDocument()
            }
            .buttonStyle(.bordered)
            
            Button("Open") {
                Task {
                    await appCoordinator.fileCoordinator.openDocument()
                }
            }
            .buttonStyle(.bordered)
            
            Button("Save") {
                Task {
                    await appCoordinator.fileCoordinator.saveDocument()
                }
            }
            .buttonStyle(.bordered)
            .disabled(!appCoordinator.fileCoordinator.canSave)
            
            Button("Export") {
                Task {
                    await appCoordinator.fileCoordinator.exportDocument()
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - View Toolbar Section
struct ViewToolbarSection: View {
    @ObservedObject var appCoordinator: AppCoordinator
    
    var body: some View {
        HStack(spacing: 8) {
            // View selector
            Picker("View", selection: $appCoordinator.currentView) {
                ForEach(AppView.allCases, id: \.self) { view in
                    Label(view.rawValue, systemImage: view.icon)
                        .tag(view)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
            
            // Full screen toggle
            Button(appCoordinator.isFullScreen ? "Exit Full Screen" : "Full Screen") {
                appCoordinator.isFullScreen.toggle()
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Collaboration Toolbar Section
struct CollaborationToolbarSection: View {
    @ObservedObject var appCoordinator: AppCoordinator
    
    var body: some View {
        HStack(spacing: 8) {
            Button("Comments") {
                appCoordinator.collaborationCoordinator.toggleCommentsPanel()
            }
            .buttonStyle(.bordered)
            .background(appCoordinator.collaborationCoordinator.showCommentsPanel ? Color.blue.opacity(0.2) : Color.clear)
            
            Button("Versions") {
                appCoordinator.collaborationCoordinator.toggleVersionHistory()
            }
            .buttonStyle(.bordered)
            .background(appCoordinator.collaborationCoordinator.showVersionHistory ? Color.blue.opacity(0.2) : Color.clear)
            
            Button("Share") {
                appCoordinator.collaborationCoordinator.shareDocument()
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Settings Toolbar Section
struct SettingsToolbarSection: View {
    @ObservedObject var appCoordinator: AppCoordinator
    
    var body: some View {
        Button("Settings") {
            appCoordinator.showSettings = true
        }
        .buttonStyle(.bordered)
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
        .background(Color(.systemGray6))
        .border(Color(.systemGray4), width: 0.5)
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
        .background(Color(.systemGray6))
        .border(Color(.systemGray4), width: 0.5)
    }
} 