//
//  DocumentViewController+Text.swift
//  type
//
//  Document-Based MVC Architecture - Text Extension
//  Inspired by Beat's BeatDocumentViewController+TextEvents
//
//  Handles text editing operations and events.
//

import Foundation
import AppKit

// MARK: - Text Operations Extension
extension DocumentViewController {
    
    // MARK: - Text Insertion
    
    /// Add string at index
    func addString(_ string: String, at index: Int) {
        addString(string, at: index, skipAutomaticLineBreaks: false)
    }
    
    /// Add string at index with option to skip automatic line breaks
    func addString(_ string: String, at index: Int, skipAutomaticLineBreaks: Bool) {
        textIO.insertText(string, at: index)
        lastEditedRange = NSRange(location: index, length: string.count)
    }
    
    /// Replace range with string
    func replaceRange(_ range: NSRange, withString string: String) {
        textIO.replaceRange(range, with: string)
        lastEditedRange = NSRange(location: range.location, length: string.count)
    }
    
    /// Replace string at index
    func replaceString(_ oldString: String, withString newString: String, at index: Int) {
        let range = NSRange(location: index, length: oldString.count)
        replaceRange(range, withString: newString)
    }
    
    /// Remove range
    func removeRange(_ range: NSRange) {
        textIO.deleteRange(range)
        lastEditedRange = NSRange(location: range.location, length: 0)
    }
    
    // MARK: - Line Operations
    
    /// Get line at index
    func lineAt(_ index: Int) -> String? {
        let lines = text.components(separatedBy: .newlines)
        guard index >= 0 && index < lines.count else { return nil }
        return lines[index]
    }
    
    /// Get line index for character position
    func lineIndexForPosition(_ position: Int) -> Int {
        var currentPosition = 0
        let lines = text.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            let lineLength = line.count + 1 // +1 for newline
            if position < currentPosition + lineLength {
                return index
            }
            currentPosition += lineLength
        }
        
        return lines.count - 1
    }
    
    /// Get character position for line start
    func positionForLineStart(_ lineIndex: Int) -> Int {
        var position = 0
        let lines = text.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            if index == lineIndex {
                return position
            }
            position += line.count + 1 // +1 for newline
        }
        
        return position
    }
    
    // MARK: - Scene Operations
    
    /// Move scene from one position to another
    func moveScene(_ scene: OutlineScene, from: Int, to: Int) {
        let sceneText = String(text[Range(scene.textRange, in: text)!])
        
        // Remove from original position
        removeRange(scene.textRange)
        
        // Calculate new position
        let newPosition = to < from ? to : to - scene.length
        
        // Insert at new position
        addString(sceneText, at: newPosition)
    }
    
    /// Get scene at position
    func sceneAtPosition(_ position: Int) -> OutlineScene? {
        return outline.last { scene in
            scene.position <= position && position < scene.position + scene.length
        }
    }
    
    /// Get scene by number
    func sceneWithNumber(_ sceneNumber: String) -> OutlineScene? {
        return outline.first { $0.sceneNumber == sceneNumber }
    }
    
    // MARK: - Character Input
    
    private static var characterInputMode: Bool = false
    private static var characterInputLine: FountainElement?
    
    /// Whether character input mode is active
    var characterInput: Bool {
        get { Self.characterInputMode }
        set { Self.characterInputMode = newValue }
    }
    
    /// The line for character input
    var characterInputForLine: FountainElement? {
        get { Self.characterInputLine }
        set { Self.characterInputLine = newValue }
    }
    
    /// Start character input mode
    func startCharacterInput(at line: FountainElement) {
        characterInput = true
        characterInputForLine = line
    }
    
    /// End character input mode
    func endCharacterInput() {
        characterInput = false
        characterInputForLine = nil
    }
    
    // MARK: - Text Processing
    
    /// Process text after editing
    func processTextAfterEdit() {
        // Re-parse
        parser.parse(text)
        
        // Update formatting
        formatting.formatChangedLines()
        
        // Update views
        textDidChange()
        
        // Notify selection observers if cursor moved
        selectionDidChange()
    }
    
    /// Apply automatic formatting
    func applyAutomaticFormatting() {
        // Check for automatic uppercase (character names after empty line)
        if let currentLine = currentLine,
           let previousLine = getPreviousLine() {
            
            if previousLine.isEmpty && !currentLine.text.isEmpty {
                // Could be a character name - check if it's all uppercase
                let uppercased = currentLine.text.uppercased()
                if currentLine.text == uppercased && currentLine.text.count > 0 {
                    // This is likely a character name
                }
            }
        }
    }
    
    private func getPreviousLine() -> String? {
        let lineIndex = lineIndexForPosition(selectedRange.location)
        guard lineIndex > 0 else { return nil }
        return lineAt(lineIndex - 1)
    }
}

// MARK: - Text Storage Extension
extension DocumentViewController {
    
    /// Get the text storage (for compatibility)
    var textStorage: NSTextStorage? {
        guard let attrText = attributedTextCache else { return nil }
        let storage = NSTextStorage(attributedString: attrText)
        return storage
    }
    
    /// Get the layout manager (for compatibility)
    var layoutManager: NSLayoutManager? {
        return textStorage?.layoutManagers.first
    }
}
