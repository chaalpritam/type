//
//  DocumentViewController+Export.swift
//  type
//
//  Document-Based MVC Architecture - Export Extension
//  Inspired by Beat's BeatDocumentViewController+Export
//
//  Handles document export operations.
//

import Foundation
import AppKit
import UniformTypeIdentifiers

// MARK: - Export Extension
extension DocumentViewController {
    
    // MARK: - Export to PDF
    
    /// Export document to PDF
    func exportToPDF() async throws -> URL? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.pdf]
        panel.nameFieldStringValue = "\(fileNameString).pdf"
        panel.title = "Export as PDF"
        panel.message = "Choose where to save the PDF"
        
        guard let window = documentWindow else {
            let response = panel.runModal()
            guard response == .OK, let url = panel.url else { return nil }
            try await performPDFExport(to: url)
            return url
        }
        
        let response = await panel.beginSheetModal(for: window)
        guard response == .OK, let url = panel.url else { return nil }
        
        try await performPDFExport(to: url)
        return url
    }
    
    private func performPDFExport(to url: URL) async throws {
        // Generate PDF from preview
        let pdfData = generatePDFData()
        try pdfData.write(to: url)
        Logger.document.info("Exported PDF to: \(url.lastPathComponent)")
    }
    
    private func generatePDFData() -> Data {
        // Create PDF with screenplay formatting
        let pdfMeta = [
            kCGPDFContextCreator: "Type - Screenplay Editor",
            kCGPDFContextAuthor: NSUserName(),
            kCGPDFContextTitle: fileNameString
        ] as [CFString: Any]
        
        let pageRect = CGRect(origin: .zero, size: pageSize.dimensions)
        let data = NSMutableData()
        
        guard let consumer = CGDataConsumer(data: data),
              let context = CGContext(consumer: consumer, mediaBox: nil, pdfMeta as CFDictionary) else {
            return Data()
        }
        
        // Render pages
        for page in previewController.previewPages {
            var mediaBox = pageRect
            context.beginPDFPage(nil)
            context.beginPage(mediaBox: &mediaBox)
            
            // Set up text rendering
            context.setFillColor(NSColor.black.cgColor)
            
            // Render page content
            let font = NSFont(name: "Courier", size: 12) ?? NSFont.systemFont(ofSize: 12)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: NSColor.black
            ]
            
            var yPosition: CGFloat = pageRect.height - 72 // 1 inch margin
            let leftMargin: CGFloat = 72 // 1 inch
            let lineHeight: CGFloat = 14.4 // 12pt line height
            
            for line in page.lines {
                let attributedLine = NSAttributedString(string: line, attributes: attributes)
                let textRect = CGRect(x: leftMargin, y: yPosition - lineHeight, width: pageRect.width - 144, height: lineHeight)
                
                // Draw text
                let frameSetter = CTFramesetterCreateWithAttributedString(attributedLine)
                let path = CGPath(rect: textRect, transform: nil)
                let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributedLine.length), path, nil)
                
                context.saveGState()
                context.translateBy(x: 0, y: pageRect.height)
                context.scaleBy(x: 1, y: -1)
                context.translateBy(x: 0, y: -(yPosition))
                CTFrameDraw(frame, context)
                context.restoreGState()
                
                yPosition -= lineHeight
            }
            
            // Add page number
            let pageNumberText = "\(page.pageNumber)."
            let pageNumberAttr = NSAttributedString(string: pageNumberText, attributes: attributes)
            let pageNumberRect = CGRect(x: pageRect.width - 72, y: 36, width: 36, height: lineHeight)
            
            let pnFrameSetter = CTFramesetterCreateWithAttributedString(pageNumberAttr)
            let pnPath = CGPath(rect: pageNumberRect, transform: nil)
            let pnFrame = CTFramesetterCreateFrame(pnFrameSetter, CFRangeMake(0, pageNumberAttr.length), pnPath, nil)
            
            context.saveGState()
            context.translateBy(x: 0, y: pageRect.height)
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: 0, y: -36)
            CTFrameDraw(pnFrame, context)
            context.restoreGState()
            
            context.endPDFPage()
        }
        
        context.closePDF()
        
        return data as Data
    }
    
    // MARK: - Export to FDX (Final Draft)
    
    /// Export document to Final Draft format
    func exportToFDX() async throws -> URL? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "fdx") ?? .xml]
        panel.nameFieldStringValue = "\(fileNameString).fdx"
        panel.title = "Export as Final Draft"
        panel.message = "Choose where to save the FDX file"
        
        guard let window = documentWindow else {
            let response = panel.runModal()
            guard response == .OK, let url = panel.url else { return nil }
            try await performFDXExport(to: url)
            return url
        }
        
        let response = await panel.beginSheetModal(for: window)
        guard response == .OK, let url = panel.url else { return nil }
        
        try await performFDXExport(to: url)
        return url
    }
    
    private func performFDXExport(to url: URL) async throws {
        let fdxContent = generateFDXContent()
        try fdxContent.write(to: url, atomically: true, encoding: .utf8)
        Logger.document.info("Exported FDX to: \(url.lastPathComponent)")
    }
    
    private func generateFDXContent() -> String {
        var fdx = """
        <?xml version="1.0" encoding="UTF-8"?>
        <FinalDraft DocumentType="Script" Template="No" Version="1">
        <Content>
        
        """
        
        for element in parser.elements {
            let type = fdxElementType(for: element.type)
            let escapedText = element.text
                .replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
            
            fdx += "<Paragraph Type=\"\(type)\">\n"
            fdx += "  <Text>\(escapedText)</Text>\n"
            fdx += "</Paragraph>\n"
        }
        
        fdx += """
        </Content>
        </FinalDraft>
        """
        
        return fdx
    }
    
    private func fdxElementType(for type: FountainElementType) -> String {
        switch type {
        case .sceneHeading: return "Scene Heading"
        case .forceSceneHeading: return "Scene Heading"
        case .action: return "Action"
        case .forceAction: return "Action"
        case .character: return "Character"
        case .dialogue: return "Dialogue"
        case .parenthetical: return "Parenthetical"
        case .transition: return "Transition"
        case .centered: return "Action"
        case .titlePage: return "Action"
        case .section: return "Action"
        case .synopsis: return "Action"
        case .note: return "Action"
        case .boneyard: return "Action"
        case .pageBreak: return "Action"
        case .lyrics: return "Action"
        case .emphasis: return "Action"
        case .dualDialogue: return "Dialogue"
        case .unknown: return "Action"
        }
    }
    
    // MARK: - Export to HTML
    
    /// Export document to HTML
    func exportToHTML() async throws -> URL? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.html]
        panel.nameFieldStringValue = "\(fileNameString).html"
        panel.title = "Export as HTML"
        panel.message = "Choose where to save the HTML file"
        
        guard let window = documentWindow else {
            let response = panel.runModal()
            guard response == .OK, let url = panel.url else { return nil }
            try await performHTMLExport(to: url)
            return url
        }
        
        let response = await panel.beginSheetModal(for: window)
        guard response == .OK, let url = panel.url else { return nil }
        
        try await performHTMLExport(to: url)
        return url
    }
    
    private func performHTMLExport(to url: URL) async throws {
        let htmlContent = generateHTMLContent()
        try htmlContent.write(to: url, atomically: true, encoding: .utf8)
        Logger.document.info("Exported HTML to: \(url.lastPathComponent)")
    }
    
    private func generateHTMLContent() -> String {
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>\(fileNameString)</title>
            <style>
                body {
                    font-family: "Courier Prime", Courier, monospace;
                    font-size: 12pt;
                    max-width: 6in;
                    margin: 1in auto;
                    line-height: 1.2;
                }
                .scene-heading {
                    font-weight: bold;
                    margin-top: 2em;
                }
                .action {
                    margin: 1em 0;
                }
                .character {
                    margin-left: 2in;
                    margin-top: 1em;
                    font-weight: bold;
                }
                .dialogue {
                    margin-left: 1in;
                    margin-right: 1.5in;
                }
                .parenthetical {
                    margin-left: 1.5in;
                    margin-right: 2in;
                    font-style: italic;
                }
                .transition {
                    text-align: right;
                    margin-top: 1em;
                }
                .centered {
                    text-align: center;
                }
            </style>
        </head>
        <body>
        
        """
        
        for element in parser.elements {
            let cssClass = htmlClass(for: element.type)
            let escapedText = element.text
                .replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
            
            html += "<p class=\"\(cssClass)\">\(escapedText)</p>\n"
        }
        
        html += """
        </body>
        </html>
        """
        
        return html
    }
    
    private func htmlClass(for type: FountainElementType) -> String {
        switch type {
        case .sceneHeading: return "scene-heading"
        case .action: return "action"
        case .character: return "character"
        case .dialogue: return "dialogue"
        case .parenthetical: return "parenthetical"
        case .transition: return "transition"
        case .centered: return "centered"
        default: return "action"
        }
    }
    
    // MARK: - Export to Plain Text
    
    /// Export document to plain text
    func exportToPlainText() async throws -> URL? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.plainText]
        panel.nameFieldStringValue = "\(fileNameString).txt"
        panel.title = "Export as Plain Text"
        
        guard let window = documentWindow else {
            let response = panel.runModal()
            guard response == .OK, let url = panel.url else { return nil }
            try text.write(to: url, atomically: true, encoding: .utf8)
            return url
        }
        
        let response = await panel.beginSheetModal(for: window)
        guard response == .OK, let url = panel.url else { return nil }
        
        try text.write(to: url, atomically: true, encoding: .utf8)
        Logger.document.info("Exported plain text to: \(url.lastPathComponent)")
        return url
    }
    
    // MARK: - Print
    
    /// Print the document
    func printDocument() {
        let printInfo = NSPrintInfo.shared
        printInfo.paperSize = pageSize.dimensions
        printInfo.topMargin = 72
        printInfo.bottomMargin = 72
        printInfo.leftMargin = 72
        printInfo.rightMargin = 72
        
        // Create print operation
        let printView = createPrintView()
        let printOperation = NSPrintOperation(view: printView, printInfo: printInfo)
        
        printOperation.showsPrintPanel = true
        printOperation.showsProgressPanel = true
        
        if let window = documentWindow {
            printOperation.runModal(for: window, delegate: nil, didRun: nil, contextInfo: nil)
        } else {
            printOperation.run()
        }
    }
    
    private func createPrintView() -> NSView {
        // Create a simple text view for printing
        let textView = NSTextView(frame: NSRect(origin: .zero, size: pageSize.dimensions))
        textView.string = text
        textView.font = NSFont(name: "Courier", size: 12)
        return textView
    }
}
