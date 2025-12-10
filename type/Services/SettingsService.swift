import Foundation
import SwiftUI
import Combine

// MARK: - Settings Service
/// Centralized service for managing app settings and preferences
@MainActor
class SettingsService: ObservableObject {
    // MARK: - Published Properties
    @Published var editorSettings: EditorSettings
    @Published var appearanceSettings: AppearanceSettings
    @Published var collaborationSettings: CollaborationSettings
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        self.editorSettings = EditorSettings()
        self.appearanceSettings = AppearanceSettings()
        self.collaborationSettings = CollaborationSettings()
        
        loadSettings()
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Save settings when they change
        $editorSettings
            .sink { [weak self] settings in
                self?.saveEditorSettings(settings)
            }
            .store(in: &cancellables)
        
        $appearanceSettings
            .sink { [weak self] settings in
                self?.saveAppearanceSettings(settings)
            }
            .store(in: &cancellables)
        
        $collaborationSettings
            .sink { [weak self] settings in
                self?.saveCollaborationSettings(settings)
            }
            .store(in: &cancellables)
    }
    
    private func loadSettings() {
        editorSettings = loadEditorSettings()
        appearanceSettings = loadAppearanceSettings()
        collaborationSettings = loadCollaborationSettings()
    }
    
    private func saveEditorSettings(_ settings: EditorSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            userDefaults.set(data, forKey: "editorSettings")
        }
    }
    
    private func saveAppearanceSettings(_ settings: AppearanceSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            userDefaults.set(data, forKey: "appearanceSettings")
        }
    }
    
    private func saveCollaborationSettings(_ settings: CollaborationSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            userDefaults.set(data, forKey: "collaborationSettings")
        }
    }
    
    private func loadEditorSettings() -> EditorSettings {
        guard let data = userDefaults.data(forKey: "editorSettings"),
              let settings = try? JSONDecoder().decode(EditorSettings.self, from: data) else {
            return EditorSettings()
        }
        return settings
    }
    
    private func loadAppearanceSettings() -> AppearanceSettings {
        guard let data = userDefaults.data(forKey: "appearanceSettings"),
              let settings = try? JSONDecoder().decode(AppearanceSettings.self, from: data) else {
            return AppearanceSettings()
        }
        return settings
    }
    
    private func loadCollaborationSettings() -> CollaborationSettings {
        guard let data = userDefaults.data(forKey: "collaborationSettings"),
              let settings = try? JSONDecoder().decode(CollaborationSettings.self, from: data) else {
            return CollaborationSettings()
        }
        return settings
    }
    
    // MARK: - Cleanup
    
    /// Cleanup method for proper resource release
    func cleanup() {
        Logger.app.debug("SettingsService cleanup")
        cancellables.removeAll()
    }
}

// MARK: - Editor Settings
struct EditorSettings: Codable {
    var showLineNumbers: Bool = true
    var showAutoCompletion: Bool = true
    var showFindReplace: Bool = false
    var selectedFont: String = "SF Mono"
    var fontSize: CGFloat = 13
    var tabSize: Int = 4
    var wordWrap: Bool = true
    var showInvisibles: Bool = false
    var autoSaveInterval: TimeInterval = 30.0
    var enableSpellCheck: Bool = true
    var enableSmartFormatting: Bool = true
}

// MARK: - Appearance Settings
struct AppearanceSettings: Codable {
    var colorSchemeName: String = "light"
    var showStatistics: Bool = true
    var showToolbar: Bool = true
    var showStatusBar: Bool = true
    var animationSpeedRaw: String = "normal"
    var showCustomizationPanel: Bool = false
    
    var colorScheme: ColorScheme {
        colorSchemeName == "dark" ? .dark : .light
    }
    
    var animationSpeed: AnimationSpeed {
        AnimationSpeed(rawValue: animationSpeedRaw) ?? .normal
    }
}

// MARK: - Collaboration Settings
struct CollaborationSettings: Codable {
    var enableRealTimeCollaboration: Bool = false
    var showCommentsPanel: Bool = false
    var showVersionHistory: Bool = false
    var showCollaboratorsPanel: Bool = false
    var autoSyncInterval: TimeInterval = 5.0
    var enableConflictResolution: Bool = true
} 