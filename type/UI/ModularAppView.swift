import SwiftUI

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
                    // Main toolbar
                    ModularToolbar(appCoordinator: appCoordinator)
                    
                    // Main content area
                    HStack(spacing: 0) {
                        // Sidebar navigation
                        if !appCoordinator.isFullScreen {
                            ModularSidebar(appCoordinator: appCoordinator)
                                .frame(width: 200)
                                .transition(.move(edge: .leading))
                        }
                        
                        // Main content
                        ModularContentView(appCoordinator: appCoordinator)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    // Status bar
                    ModularStatusBar(appCoordinator: appCoordinator)
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
                EditorView(coordinator: appCoordinator.editorCoordinator)
            case .characters:
                CharacterView(coordinator: appCoordinator.characterCoordinator)
            case .outline:
                OutlineView(coordinator: appCoordinator.outlineCoordinator)
            case .collaboration:
                CollaborationView(coordinator: appCoordinator.collaborationCoordinator)
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

// MARK: - Placeholder Views (to be implemented)
struct EditorView: View {
    @ObservedObject var coordinator: EditorCoordinator
    
    var body: some View {
        VStack {
            Text("Editor View")
                .font(.title)
            Text("Text: \(coordinator.text.prefix(50))...")
                .font(.caption)
        }
    }
}

struct CharacterView: View {
    @ObservedObject var coordinator: CharacterCoordinator
    
    var body: some View {
        VStack {
            Text("Character View")
                .font(.title)
            Text("Characters: \(coordinator.characters.count)")
                .font(.caption)
        }
    }
}

struct OutlineView: View {
    @ObservedObject var coordinator: OutlineCoordinator
    
    var body: some View {
        VStack {
            Text("Outline View")
                .font(.title)
            Text("Outlines: \(coordinator.outlines.count)")
                .font(.caption)
        }
    }
}

struct CollaborationView: View {
    @ObservedObject var coordinator: CollaborationCoordinator
    
    var body: some View {
        VStack {
            Text("Collaboration View")
                .font(.title)
            Text("Collaborators: \(coordinator.collaborators.count)")
                .font(.caption)
        }
    }
} 