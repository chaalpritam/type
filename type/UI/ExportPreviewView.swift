//
//  ExportPreviewView.swift
//  type
//
//  Export preview dialog for better user control and reduced export errors
//

import SwiftUI
import AppKit

// MARK: - Export Options
struct ExportOptions {
    // PDF options
    var includePageNumbers: Bool = true
    var includeHeader: Bool = false
    var headerText: String = ""
    var pageNumberPosition: PageNumberPosition = .bottomRight

    // HTML options
    var includeCSS: Bool = true
    var customCSS: String = ""

    // General options
    var paperSize: PaperSize = .letter
    var includeNotes: Bool = false
    var includeRevisionMarkers: Bool = false

    enum PageNumberPosition: String, CaseIterable {
        case topRight = "Top Right"
        case topCenter = "Top Center"
        case bottomRight = "Bottom Right"
        case bottomCenter = "Bottom Center"
    }

    enum PaperSize: String, CaseIterable {
        case letter = "Letter (8.5\" x 11\")"
        case a4 = "A4 (8.27\" x 11.69\")"
        case legal = "Legal (8.5\" x 14\")"

        var dimensions: CGSize {
            switch self {
            case .letter: return CGSize(width: 612, height: 792)  // 8.5" x 11"
            case .a4: return CGSize(width: 595, height: 842)      // 8.27" x 11.69"
            case .legal: return CGSize(width: 612, height: 1008)  // 8.5" x 14"
            }
        }
    }
}

// MARK: - Export Preview View
struct ExportPreviewView: View {
    @ObservedObject var documentController: DocumentViewController
    @Binding var isPresented: Bool

    @State private var selectedFormat: ExportFormat = .pdf
    @State private var exportOptions = ExportOptions()
    @State private var isExporting = false
    @State private var exportError: String?
    @State private var showSuccessMessage = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Export Preview")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Main Content
            HStack(spacing: 0) {
                // Options Panel
                VStack(alignment: .leading, spacing: 16) {
                    // Format Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Export Format")
                            .font(.headline)

                        ForEach(ExportFormat.allCases) { format in
                            FormatButton(
                                format: format,
                                isSelected: selectedFormat == format
                            ) {
                                selectedFormat = format
                            }
                        }
                    }

                    Divider()

                    // Format-specific options
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            switch selectedFormat {
                            case .pdf:
                                PDFOptionsView(options: $exportOptions)
                            case .html:
                                HTMLOptionsView(options: $exportOptions)
                            case .finalDraft:
                                FDXOptionsView(options: $exportOptions)
                            case .fountain:
                                EmptyView()
                            case .plainText:
                                PlainTextOptionsView(options: $exportOptions)
                            }
                        }
                    }

                    Spacer()

                    // Error Message
                    if let error = exportError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }

                    // Success Message
                    if showSuccessMessage {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Export successful!")
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }

                    // Action Buttons
                    HStack(spacing: 12) {
                        Button("Cancel") {
                            isPresented = false
                        }
                        .buttonStyle(.bordered)

                        Button("Export") {
                            Task {
                                await performExport()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isExporting)
                    }
                }
                .frame(width: 280)
                .padding()
                .background(Color(NSColor.controlBackgroundColor))

                Divider()

                // Preview Panel
                VStack(spacing: 0) {
                    // Preview Header
                    HStack {
                        Text("Preview")
                            .font(.headline)

                        Spacer()

                        Text("\(documentController.parser.elements.count) elements")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("•")
                            .foregroundColor(.secondary)

                        Text("~\(estimatedPages) pages")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(NSColor.windowBackgroundColor))

                    Divider()

                    // Preview Content
                    ScrollView {
                        PreviewContentView(
                            documentController: documentController,
                            format: selectedFormat,
                            options: exportOptions
                        )
                        .padding()
                    }
                }
            }
        }
        .frame(width: 900, height: 600)
    }

    private var estimatedPages: Int {
        max(1, documentController.wordCount / 250)
    }

    private func performExport() async {
        isExporting = true
        exportError = nil
        showSuccessMessage = false

        do {
            let url: URL?
            switch selectedFormat {
            case .pdf:
                url = try await documentController.exportToPDF()
            case .finalDraft:
                url = try await documentController.exportToFDX()
            case .fountain:
                url = nil  // Fountain export to be implemented
            case .html:
                url = try await documentController.exportToHTML()
            case .plainText:
                url = try await documentController.exportToPlainText()
            }

            if url != nil {
                showSuccessMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isPresented = false
                }
            }
        } catch {
            exportError = "Export failed: \(error.localizedDescription)"
        }

        isExporting = false
    }
}

// MARK: - Format Button
struct FormatButton: View {
    let format: ExportFormat
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: format.icon)
                    .frame(width: 20)

                Text(format.rawValue)
                    .font(.subheadline)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - PDF Options View
struct PDFOptionsView: View {
    @Binding var options: ExportOptions

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PDF Options")
                .font(.headline)

            Toggle("Include page numbers", isOn: $options.includePageNumbers)

            if options.includePageNumbers {
                Picker("Position", selection: $options.pageNumberPosition) {
                    ForEach(ExportOptions.PageNumberPosition.allCases, id: \.self) { position in
                        Text(position.rawValue).tag(position)
                    }
                }
                .pickerStyle(.menu)
            }

            Toggle("Include header", isOn: $options.includeHeader)

            if options.includeHeader {
                TextField("Header text", text: $options.headerText)
                    .textFieldStyle(.roundedBorder)
            }

            Picker("Paper size", selection: $options.paperSize) {
                ForEach(ExportOptions.PaperSize.allCases, id: \.self) { size in
                    Text(size.rawValue).tag(size)
                }
            }
            .pickerStyle(.menu)

            Toggle("Include notes", isOn: $options.includeNotes)
        }
    }
}

// MARK: - HTML Options View
struct HTMLOptionsView: View {
    @Binding var options: ExportOptions

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HTML Options")
                .font(.headline)

            Toggle("Include CSS styling", isOn: $options.includeCSS)

            if options.includeCSS {
                Text("Custom CSS (optional)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextEditor(text: $options.customCSS)
                    .font(.system(.caption, design: .monospaced))
                    .frame(height: 100)
                    .border(Color.gray.opacity(0.2))
            }

            Toggle("Include notes", isOn: $options.includeNotes)
        }
    }
}

// MARK: - FDX Options View
struct FDXOptionsView: View {
    @Binding var options: ExportOptions

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Final Draft Options")
                .font(.headline)

            Toggle("Include notes", isOn: $options.includeNotes)

            Toggle("Include revision markers", isOn: $options.includeRevisionMarkers)

            Text("The FDX file will be compatible with Final Draft 8 and later.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
    }
}

// MARK: - Plain Text Options View
struct PlainTextOptionsView: View {
    @Binding var options: ExportOptions

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Plain Text Options")
                .font(.headline)

            Text("The file will be exported as-is in Fountain format.")
                .font(.caption)
                .foregroundColor(.secondary)

            Toggle("Include notes", isOn: $options.includeNotes)
        }
    }
}

// MARK: - Preview Content View
struct PreviewContentView: View {
    @ObservedObject var documentController: DocumentViewController
    let format: ExportFormat
    let options: ExportOptions

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Page-like preview
            ZStack {
                // Paper background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

                VStack(alignment: .leading, spacing: 0) {
                    // Header (if enabled)
                    if options.includeHeader && !options.headerText.isEmpty {
                        Text(options.headerText)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.black.opacity(0.7))
                            .padding(.top, 20)
                            .padding(.horizontal, 60)
                    }

                    // Content preview (first page)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            let elements = Array(documentController.parser.elements.prefix(30))
                            ForEach(0..<elements.count, id: \.self) { index in
                                PreviewElement(element: elements[index], format: format)
                            }

                            if documentController.parser.elements.count > 30 {
                                Text("... (\(documentController.parser.elements.count - 30) more elements)")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.gray)
                                    .italic()
                                    .padding(.top, 20)
                            }
                        }
                        .padding(60)
                    }

                    Spacer()

                    // Page number (if enabled)
                    if options.includePageNumbers {
                        HStack {
                            if options.pageNumberPosition == .topCenter || options.pageNumberPosition == .bottomCenter {
                                Spacer()
                            }

                            Text("1.")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.black.opacity(0.7))

                            if options.pageNumberPosition == .topCenter || options.pageNumberPosition == .bottomCenter {
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 60)
                        .padding(.bottom, 20)
                    }
                }
            }
            .aspectRatio(options.paperSize.dimensions.width / options.paperSize.dimensions.height, contentMode: .fit)
            .frame(maxWidth: 600)
        }
    }
}

// MARK: - Preview Element
struct PreviewElement: View {
    let element: FountainElement
    let format: ExportFormat

    var body: some View {
        Text(element.text)
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: alignment)
            .padding(.leading, leadingPadding)
    }

    private var alignment: Alignment {
        switch element.type {
        case .character:
            return .leading
        case .transition:
            return .trailing
        case .centered:
            return .center
        default:
            return .leading
        }
    }

    private var leadingPadding: CGFloat {
        switch element.type {
        case .character:
            return 120
        case .dialogue:
            return 60
        case .parenthetical:
            return 80
        default:
            return 0
        }
    }
}
