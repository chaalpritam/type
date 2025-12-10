//
//  DocumentDelegate.swift
//  type
//
//  Document-Based MVC Architecture - Inspired by Beat's BeatDocumentDelegate
//  This protocol defines the basic document interface without editor specifics.
//

import Foundation
import AppKit

// MARK: - Document Delegate Protocol
/// Base protocol for document handling - used when no editor interaction is needed
/// Mirrors Beat's BeatDocumentDelegate
@MainActor
protocol DocumentDelegate: AnyObject {
    // MARK: - Document Properties
    
    /// The unique identifier for this document
    var documentId: UUID { get }
    
    /// The document settings
    var documentSettings: DocumentSettings { get }
    
    /// The export settings
    var exportSettings: ExportSettings { get }
    
    // MARK: - Content Access
    
    /// The raw text content
    var text: String { get set }
    
    /// Content buffer - keeps text until view is initialized
    var contentBuffer: String? { get set }
    
    /// The document outline
    var outline: [OutlineScene] { get }
    
    /// The display name for the document
    var displayName: String { get }
    
    // MARK: - Parser
    
    /// The fountain parser for this document
    var parser: FountainParser { get }
    
    // MARK: - Page Settings
    
    /// The page size
    var pageSize: PageSize { get set }
    
    /// Whether to print scene numbers
    var printSceneNumbers: Bool { get set }
    
    /// Whether to show scene number labels
    var showSceneNumberLabels: Bool { get set }
    
    /// Whether to show page numbers
    var showPageNumbers: Bool { get set }
}

// MARK: - Document Settings
/// Settings stored within the document
/// Similar to Beat's BeatDocumentSettings
class DocumentSettings: ObservableObject {
    @Published var revisionMode: Bool = false
    @Published var revisionLevel: Int = 0
    @Published var showRevisions: Bool = true
    @Published var showTags: Bool = false
    @Published var locked: Bool = false
    @Published var printSynopsis: Bool = false
    @Published var printNotes: Bool = false
    @Published var printSections: Bool = true
    @Published var coloredPages: Bool = false
    @Published var characterGenders: [String: String] = [:]
    
    /// Custom data storage for extensions
    private var customData: [String: Any] = [:]
    
    func getBool(_ key: String) -> Bool {
        return customData[key] as? Bool ?? false
    }
    
    func setBool(_ key: String, value: Bool) {
        customData[key] = value
    }
    
    func getString(_ key: String) -> String? {
        return customData[key] as? String
    }
    
    func setString(_ key: String, value: String) {
        customData[key] = value
    }
    
    func getInt(_ key: String) -> Int {
        return customData[key] as? Int ?? 0
    }
    
    func setInt(_ key: String, value: Int) {
        customData[key] = value
    }
    
    func getValue(_ key: String) -> Any? {
        return customData[key]
    }
    
    func setValue(_ key: String, value: Any) {
        customData[key] = value
    }
}

// MARK: - Export Settings
/// Settings for exporting documents
/// Similar to Beat's BeatExportSettings
class ExportSettings: ObservableObject {
    @Published var pageSize: PageSize = .usLetter
    @Published var printSceneNumbers: Bool = true
    @Published var printDialogueNumbers: Bool = false
    @Published var printSynopsis: Bool = false
    @Published var printNotes: Bool = false
    @Published var printSections: Bool = true
    @Published var showPageNumbers: Bool = true
    @Published var header: String = ""
    @Published var footer: String = ""
    @Published var additionalStyles: String = ""
    
    /// Export format
    @Published var format: DocumentExportFormat = .pdf
}

// MARK: - Page Size
enum PageSize: Int, CaseIterable {
    case usLetter = 0
    case a4 = 1
    
    var displayName: String {
        switch self {
        case .usLetter: return "US Letter"
        case .a4: return "A4"
        }
    }
    
    var dimensions: CGSize {
        switch self {
        case .usLetter: return CGSize(width: 612, height: 792)  // 8.5 x 11 inches at 72 dpi
        case .a4: return CGSize(width: 595, height: 842)        // 210 x 297 mm at 72 dpi
        }
    }
}

// MARK: - Document Export Format
enum DocumentExportFormat: Int, CaseIterable {
    case pdf = 0
    case fdx = 1
    case fountain = 2
    case plainText = 3
    case html = 4
    
    var displayName: String {
        switch self {
        case .pdf: return "PDF"
        case .fdx: return "Final Draft (FDX)"
        case .fountain: return "Fountain"
        case .plainText: return "Plain Text"
        case .html: return "HTML"
        }
    }
    
    var fileExtension: String {
        switch self {
        case .pdf: return "pdf"
        case .fdx: return "fdx"
        case .fountain: return "fountain"
        case .plainText: return "txt"
        case .html: return "html"
        }
    }
}

// MARK: - Document Setting Keys
/// Constants for document setting keys
struct DocumentSettingKeys {
    static let locked = "locked"
    static let revisionMode = "revisionMode"
    static let revisionLevel = "revisionLevel"
    static let showRevisions = "showRevisions"
    static let showTags = "showTags"
    static let pageSize = "pageSize"
    static let printSceneNumbers = "printSceneNumbers"
    static let printSynopsis = "printSynopsis"
    static let printNotes = "printNotes"
    static let coloredPages = "coloredPages"
    static let characterGenders = "characterGenders"
    static let caretPosition = "caretPosition"
}
