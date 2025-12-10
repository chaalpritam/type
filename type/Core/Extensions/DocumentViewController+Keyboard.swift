//
//  DocumentViewController+Keyboard.swift
//  type
//
//  Document-Based MVC Architecture - Keyboard Extension
//  Inspired by Beat's BeatDocumentViewController+KeyboardEvents
//
//  Handles keyboard input and commands.
//

import Foundation
import AppKit

// MARK: - Keyboard Extension
extension DocumentViewController {
    
    // MARK: - Key Commands
    
    /// Handle key command
    func handleKeyCommand(_ event: NSEvent) -> Bool {
        // Check for modifier keys
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        
        // Command key shortcuts
        if modifiers.contains(.command) {
            return handleCommandKeyEvent(event)
        }
        
        // Control key shortcuts
        if modifiers.contains(.control) {
            return handleControlKeyEvent(event)
        }
        
        // Option/Alt key shortcuts
        if modifiers.contains(.option) {
            return handleOptionKeyEvent(event)
        }
        
        // Regular key handling
        return handleRegularKeyEvent(event)
    }
    
    // MARK: - Command Key Events (⌘)
    
    private func handleCommandKeyEvent(_ event: NSEvent) -> Bool {
        guard let characters = event.charactersIgnoringModifiers else { return false }
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let hasShift = modifiers.contains(.shift)
        
        switch characters.lowercased() {
        case "s":
            if hasShift {
                // ⌘⇧S - Save As
                NotificationCenter.default.post(name: .saveDocumentAs, object: self)
            } else {
                // ⌘S - Save
                NotificationCenter.default.post(name: .saveDocument, object: self)
            }
            return true
            
        case "z":
            if hasShift {
                // ⌘⇧Z - Redo
                performRedo()
            } else {
                // ⌘Z - Undo
                performUndo()
            }
            return true
            
        case "f":
            if hasShift {
                // ⌘⇧F - Focus Mode
                toggleFocusMode()
            } else {
                // ⌘F - Find/Replace
                toggleFindReplace()
            }
            return true
            
        case "p":
            if hasShift {
                // ⌘⇧P - Toggle Preview
                togglePreview()
            }
            return true
            
        case "o":
            if hasShift {
                // ⌘⇧O - Toggle Outline
                toggleOutline()
            }
            return true
            
        case "b":
            // ⌘B - Bold (wrap selection with **)
            applyFormatting(.bold)
            return true
            
        case "i":
            // ⌘I - Italic (wrap selection with *)
            applyFormatting(.italic)
            return true
            
        case "u":
            // ⌘U - Underline (wrap selection with _)
            applyFormatting(.underline)
            return true
            
        case "/":
            // ⌘/ - Toggle comment (wrap with /* */)
            applyFormatting(.comment)
            return true
            
        default:
            break
        }
        
        return false
    }
    
    // MARK: - Control Key Events (⌃)
    
    private func handleControlKeyEvent(_ event: NSEvent) -> Bool {
        guard let characters = event.charactersIgnoringModifiers else { return false }
        
        switch characters.lowercased() {
        case "n":
            // ⌃N - Next scene
            navigateToNextScene()
            return true
            
        case "p":
            // ⌃P - Previous scene
            navigateToPreviousScene()
            return true
            
        case "g":
            // ⌃G - Go to scene
            // Show go to scene dialog
            return true
            
        default:
            break
        }
        
        return false
    }
    
    // MARK: - Option Key Events (⌥)
    
    private func handleOptionKeyEvent(_ event: NSEvent) -> Bool {
        guard let characters = event.charactersIgnoringModifiers else { return false }
        
        switch characters.lowercased() {
        case "1":
            // ⌥1 - Scene Heading
            formatCurrentLineAs(.sceneHeading)
            return true
            
        case "2":
            // ⌥2 - Action
            formatCurrentLineAs(.action)
            return true
            
        case "3":
            // ⌥3 - Character
            formatCurrentLineAs(.character)
            return true
            
        case "4":
            // ⌥4 - Dialogue
            formatCurrentLineAs(.dialogue)
            return true
            
        case "5":
            // ⌥5 - Parenthetical
            formatCurrentLineAs(.parenthetical)
            return true
            
        case "6":
            // ⌥6 - Transition
            formatCurrentLineAs(.transition)
            return true
            
        default:
            break
        }
        
        return false
    }
    
    // MARK: - Regular Key Events
    
    private func handleRegularKeyEvent(_ event: NSEvent) -> Bool {
        let keyCode = event.keyCode
        
        switch keyCode {
        case 36: // Return
            handleReturnKey()
            return true
            
        case 48: // Tab
            handleTabKey(shift: event.modifierFlags.contains(.shift))
            return true
            
        case 53: // Escape
            handleEscapeKey()
            return true
            
        default:
            break
        }
        
        return false
    }
    
    // MARK: - Key Handlers
    
    private func handleReturnKey() {
        // Check if we're in character input mode
        if characterInput {
            endCharacterInput()
        }
        
        // Check current line type for smart behavior
        if let currentElement = currentLine {
            switch currentElement.type {
            case .character:
                // After character, start dialogue
                characterInput = false
            case .parenthetical:
                // After parenthetical, continue dialogue
                break
            case .dialogue:
                // After dialogue, could be more dialogue or new element
                break
            default:
                break
            }
        }
    }
    
    private func handleTabKey(shift: Bool) {
        if shift {
            // Shift-Tab: Decrease indent or move to previous field
        } else {
            // Tab: Increase indent or auto-complete
            if autoComplete.isActive {
                // Select first suggestion
                if let firstSuggestion = autoComplete.suggestions.first {
                    autoComplete.selectSuggestion(firstSuggestion)
                }
            }
        }
    }
    
    private func handleEscapeKey() {
        // Cancel character input
        if characterInput {
            endCharacterInput()
        }
        
        // Hide autocomplete
        if autoComplete.isActive {
            autoComplete.isActive = false
        }
        
        // Exit focus mode
        if isFocusMode {
            toggleFocusMode()
        }
    }
    
    // MARK: - Navigation
    
    /// Navigate to next scene
    func navigateToNextScene() {
        guard let currentScene = currentScene,
              let currentIndex = outline.firstIndex(of: currentScene),
              currentIndex < outline.count - 1 else { return }
        
        let nextScene = outline[currentIndex + 1]
        scrollToScene(nextScene)
        selectedRange = NSRange(location: nextScene.position, length: 0)
    }
    
    /// Navigate to previous scene
    func navigateToPreviousScene() {
        guard let currentScene = currentScene,
              let currentIndex = outline.firstIndex(of: currentScene),
              currentIndex > 0 else { return }
        
        let previousScene = outline[currentIndex - 1]
        scrollToScene(previousScene)
        selectedRange = NSRange(location: previousScene.position, length: 0)
    }
    
    // MARK: - Formatting
    
    /// Format type for keyboard shortcuts
    enum FormatType {
        case bold
        case italic
        case underline
        case comment
    }
    
    /// Apply formatting to selection
    func applyFormatting(_ format: FormatType) {
        guard selectedRange.length > 0 else { return }
        guard let swiftRange = Range(selectedRange, in: text) else { return }
        
        let selectedText = String(text[swiftRange])
        var formattedText: String
        
        switch format {
        case .bold:
            formattedText = "**\(selectedText)**"
        case .italic:
            formattedText = "*\(selectedText)*"
        case .underline:
            formattedText = "_\(selectedText)_"
        case .comment:
            formattedText = "/* \(selectedText) */"
        }
        
        replaceRange(selectedRange, withString: formattedText)
    }
    
    /// Format current line as specific type
    func formatCurrentLineAs(_ type: FountainElementType) {
        let lineIndex = lineIndexForPosition(selectedRange.location)
        guard var line = lineAt(lineIndex) else { return }
        
        let lineStart = positionForLineStart(lineIndex)
        let lineRange = NSRange(location: lineStart, length: line.count)
        
        // Remove existing formatting markers
        line = line.trimmingCharacters(in: .whitespaces)
        
        // Apply new formatting based on type
        var formattedLine = line
        
        switch type {
        case .sceneHeading:
            if !line.hasPrefix(".") && 
               !line.uppercased().hasPrefix("INT.") && 
               !line.uppercased().hasPrefix("EXT.") {
                formattedLine = ".\(line.uppercased())"
            }
        case .character:
            formattedLine = "@\(line.uppercased())"
        case .transition:
            if !line.uppercased().hasSuffix("TO:") {
                formattedLine = "> \(line.uppercased())"
            }
        case .action:
            formattedLine = "!\(line)"
        case .centered:
            formattedLine = ">\(line)<"
        default:
            break
        }
        
        if formattedLine != line {
            replaceRange(lineRange, withString: formattedLine)
        }
    }
}
