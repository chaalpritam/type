import Foundation

class TextHistoryManager: ObservableObject {
    @Published var canUndo: Bool = false
    @Published var canRedo: Bool = false
    
    private var history: [String] = []
    private var currentIndex: Int = -1
    private let maxHistorySize: Int = 100
    
    init() {
        // Initialize with empty state
        addToHistory("")
    }
    
    func addToHistory(_ text: String) {
        // Remove any redo history if we're adding a new state
        if currentIndex < history.count - 1 {
            history.removeSubrange((currentIndex + 1)...)
        }
        
        // Add new state
        history.append(text)
        currentIndex += 1
        
        // Limit history size
        if history.count > maxHistorySize {
            history.removeFirst()
            currentIndex -= 1
        }
        
        updateButtons()
    }
    
    func undo() -> String? {
        guard canUndo else { return nil }
        
        currentIndex -= 1
        updateButtons()
        return history[currentIndex]
    }
    
    func redo() -> String? {
        guard canRedo else { return nil }
        
        currentIndex += 1
        updateButtons()
        return history[currentIndex]
    }
    
    private func updateButtons() {
        canUndo = currentIndex > 0
        canRedo = currentIndex < history.count - 1
    }
    
    func clearHistory() {
        history.removeAll()
        currentIndex = -1
        updateButtons()
    }
    
    func getCurrentText() -> String {
        guard currentIndex >= 0 && currentIndex < history.count else { return "" }
        return history[currentIndex]
    }
} 