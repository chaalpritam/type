//
//  DocumentStatusIndicator.swift
//  type
//
//  Enhanced autosave feedback and document state visibility for user confidence
//

import SwiftUI
import Combine

// MARK: - Document State
enum DocumentState {
    case unsaved          // New document, never saved
    case saved            // All changes saved
    case saving           // Currently saving
    case modified         // Has unsaved changes
    case saveFailed(String) // Save failed with error
    case syncing          // Syncing with collaboration server
    case syncFailed(String) // Sync failed with error

    var icon: String {
        switch self {
        case .unsaved:
            return "doc"
        case .saved:
            return "checkmark.circle.fill"
        case .saving:
            return "arrow.clockwise"
        case .modified:
            return "pencil.circle.fill"
        case .saveFailed:
            return "exclamationmark.triangle.fill"
        case .syncing:
            return "arrow.triangle.2.circlepath"
        case .syncFailed:
            return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .unsaved:
            return .secondary
        case .saved:
            return .green
        case .saving:
            return .blue
        case .modified:
            return .orange
        case .saveFailed, .syncFailed:
            return .red
        case .syncing:
            return .purple
        }
    }

    var description: String {
        switch self {
        case .unsaved:
            return "Not saved"
        case .saved:
            return "All changes saved"
        case .saving:
            return "Saving..."
        case .modified:
            return "Unsaved changes"
        case .saveFailed(let error):
            return "Save failed: \(error)"
        case .syncing:
            return "Syncing..."
        case .syncFailed(let error):
            return "Sync failed: \(error)"
        }
    }

    var isAnimated: Bool {
        switch self {
        case .saving, .syncing:
            return true
        default:
            return false
        }
    }
}

// MARK: - Document Status Indicator
struct DocumentStatusIndicator: View {
    @ObservedObject var fileService: FileManagementService
    @ObservedObject var statisticsService: StatisticsService

    @State private var lastSaveTime: Date?
    @State private var documentState: DocumentState = .unsaved
    @State private var showDetailedStatus = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        HStack(spacing: 12) {
            // Status Icon and Text
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showDetailedStatus.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: documentState.icon)
                        .foregroundColor(documentState.color)
                        .rotationEffect(.degrees(documentState.isAnimated ? rotationAngle : 0))
                        .animation(
                            documentState.isAnimated ?
                                Animation.linear(duration: 1.5).repeatForever(autoreverses: false) :
                                .default,
                            value: rotationAngle
                        )

                    if !showDetailedStatus {
                        Text(shortStatusText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(documentState.color.opacity(0.1))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showDetailedStatus, arrowEdge: .bottom) {
                DetailedStatusPopover(
                    documentState: documentState,
                    lastSaveTime: lastSaveTime,
                    fileService: fileService,
                    statisticsService: statisticsService
                )
            }

            // Live word count
            LiveStatsBadge(statisticsService: statisticsService)
        }
        .onAppear {
            updateDocumentState()
            if documentState.isAnimated {
                rotationAngle = 360
            }
        }
        .onChange(of: fileService.isDocumentModified) { _ in
            updateDocumentState()
        }
        .onChange(of: fileService.isSaving) { _ in
            updateDocumentState()
            if documentState.isAnimated {
                rotationAngle = 360
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .documentSaved)) { notification in
            if let saveTime = notification.object as? Date {
                lastSaveTime = saveTime
                updateDocumentState()

                // Reset animation
                rotationAngle = 0
            }
        }
    }

    private var shortStatusText: String {
        switch documentState {
        case .saved:
            if let lastSave = lastSaveTime {
                return timeSinceLastSave(lastSave)
            }
            return "Saved"
        case .modified:
            return "Modified"
        case .saving:
            return "Saving"
        case .saveFailed:
            return "Failed"
        case .syncing:
            return "Syncing"
        case .syncFailed:
            return "Sync failed"
        case .unsaved:
            return "Not saved"
        }
    }

    private func updateDocumentState() {
        if fileService.isSaving {
            documentState = .saving
        } else if fileService.isDocumentModified {
            documentState = .modified
        } else if fileService.currentFileURL != nil {
            documentState = .saved
        } else {
            documentState = .unsaved
        }
    }

    private func timeSinceLastSave(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))

        if seconds < 60 {
            return "Just now"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            return "\(minutes)m ago"
        } else if seconds < 86400 {
            let hours = seconds / 3600
            return "\(hours)h ago"
        } else {
            let days = seconds / 86400
            return "\(days)d ago"
        }
    }
}

// MARK: - Live Stats Badge
struct LiveStatsBadge: View {
    @ObservedObject var statisticsService: StatisticsService

    @State private var wordCountChanged = false
    @State private var previousWordCount = 0

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "doc.text")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("\(statisticsService.wordCount)")
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.medium)
                .foregroundColor(wordCountChanged ? .green : .primary)
                .animation(.easeInOut(duration: 0.2), value: wordCountChanged)

            Text("words")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
        .onChange(of: statisticsService.wordCount) { newCount in
            if newCount != previousWordCount {
                wordCountChanged = true
                previousWordCount = newCount

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    wordCountChanged = false
                }
            }
        }
    }
}

// MARK: - Detailed Status Popover
struct DetailedStatusPopover: View {
    let documentState: DocumentState
    let lastSaveTime: Date?
    @ObservedObject var fileService: FileManagementService
    @ObservedObject var statisticsService: StatisticsService

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: documentState.icon)
                    .foregroundColor(documentState.color)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(documentState.description)
                        .font(.headline)

                    if let lastSave = lastSaveTime {
                        Text("Last saved: \(formatDate(lastSave))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }

            Divider()

            // Document Info
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "File", value: fileService.currentFileURL?.lastPathComponent ?? "Untitled")
                InfoRow(label: "Location", value: fileService.currentFileURL?.deletingLastPathComponent().path ?? "Not saved")
                InfoRow(label: "Word count", value: "\(statisticsService.wordCount)")
                InfoRow(label: "Page count", value: "\(statisticsService.pageCount)")
                InfoRow(label: "Characters", value: "\(statisticsService.characterCount)")
            }

            Divider()

            // Autosave Settings
            VStack(alignment: .leading, spacing: 8) {
                Text("Autosave")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)

                    Text("Enabled (every 30 seconds)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if statisticsService.currentSessionStartTime != nil {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.blue)
                            .font(.caption)

                        Text("Session: \(formatDuration(statisticsService.getCurrentSessionDuration()))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Actions
            HStack(spacing: 8) {
                if fileService.currentFileURL != nil && fileService.isDocumentModified {
                    Button("Save Now") {
                        fileService.saveDocumentSync()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Button("Open Location") {
                    if let url = fileService.currentFileURL {
                        NSWorkspace.shared.activateFileViewerSelecting([url])
                    }
                }
                .buttonStyle(.bordered)
                .disabled(fileService.currentFileURL == nil)
            }
        }
        .padding()
        .frame(width: 320)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 90, alignment: .leading)

            Text(value)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}

// MARK: - Autosave Progress Indicator
struct AutosaveProgressIndicator: View {
    @ObservedObject var fileService: FileManagementService

    @State private var progress: Double = 0
    @State private var timer: Timer?

    private let autosaveInterval: TimeInterval = 30 // 30 seconds

    var body: some View {
        if fileService.isDocumentModified && fileService.currentFileURL != nil {
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.caption)
                        .foregroundColor(.blue)

                    Text("Next autosave in \(Int((1 - progress) * autosaveInterval))s")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(.blue)
                    .frame(width: 150)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(6)
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
            .onChange(of: fileService.isDocumentModified) { modified in
                if !modified {
                    stopTimer()
                    progress = 0
                } else {
                    startTimer()
                }
            }
        }
    }

    private func startTimer() {
        stopTimer()
        progress = 0

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            progress += 0.1 / autosaveInterval

            if progress >= 1.0 {
                progress = 0
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let documentSaved = Notification.Name("documentSaved")
    static let documentModified = Notification.Name("documentModified")
    static let autosaveTriggered = Notification.Name("autosaveTriggered")
}
