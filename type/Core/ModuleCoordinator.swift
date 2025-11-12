import Foundation
import SwiftUI
import Combine

// MARK: - Module Coordinator Protocol
/// Base protocol for all module coordinators
protocol ModuleCoordinator: ObservableObject {
    associatedtype ModuleView: View
    
    /// Update the coordinator when the document changes
    func updateDocument(_ document: ScreenplayDocument?)
    
    /// Create the main view for this module
    func createView() -> ModuleView
    
    /// Clean up resources when module is deactivated
    func cleanup()
}

// MARK: - Base Module Coordinator
/// Base implementation for module coordinators
class BaseModuleCoordinator: ObservableObject {
    // MARK: - Properties
    let documentService: DocumentService
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(documentService: DocumentService) {
        self.documentService = documentService
        setupBindings()
    }
    
    // MARK: - Methods
    func updateDocument(_ document: ScreenplayDocument?) {
        // Override in subclasses
    }
    
    func cleanup() {
        cancellables.removeAll()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Common bindings can be set up here
    }
} 