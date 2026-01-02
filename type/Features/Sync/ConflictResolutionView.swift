import SwiftUI

// MARK: - Conflict Resolution View
struct ConflictResolutionView: View {
    @ObservedObject var syncCoordinator: SyncCoordinator
    let conflict: SyncConflict

    @Environment(\.dismiss) private var dismiss

    @State private var selectedResolution: ResolutionChoice = .keepLocal
    @State private var isResolving: Bool = false

    enum ResolutionChoice {
        case keepLocal
        case keepRemote
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .imageScale(.large)

                Text("Sync Conflict Detected")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Conflict description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Conflict Information")
                            .font(.headline)

                        Text(conflict.message)
                            .foregroundColor(.secondary)

                        HStack {
                            VStack(alignment: .leading) {
                                Text("Local version:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(conflict.localTimestamp, style: .date)
                                    .font(.caption)
                                Text(conflict.localTimestamp, style: .time)
                                    .font(.caption)
                            }

                            Spacer()

                            VStack(alignment: .leading) {
                                Text("Remote version:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(conflict.remoteTimestamp, style: .date)
                                    .font(.caption)
                                Text(conflict.remoteTimestamp, style: .time)
                                    .font(.caption)
                            }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.05))
                        .cornerRadius(8)
                    }

                    Divider()

                    // Resolution options
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose Resolution")
                            .font(.headline)

                        // Keep Local
                        Button(action: { selectedResolution = .keepLocal }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: selectedResolution == .keepLocal ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedResolution == .keepLocal ? .blue : .secondary)
                                    .imageScale(.large)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Keep Local Version")
                                        .font(.headline)
                                    Text("Use your local changes and overwrite the remote version")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }
                            .padding()
                            .background(selectedResolution == .keepLocal ? Color.blue.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedResolution == .keepLocal ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)

                        // Keep Remote
                        Button(action: { selectedResolution = .keepRemote }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: selectedResolution == .keepRemote ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedResolution == .keepRemote ? .blue : .secondary)
                                    .imageScale(.large)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Keep Remote Version")
                                        .font(.headline)
                                    Text("Discard your local changes and use the remote version")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }
                            .padding()
                            .background(selectedResolution == .keepRemote ? Color.blue.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedResolution == .keepRemote ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }

            Divider()

            // Action buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    syncCoordinator.dismissConflict()
                    dismiss()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(action: handleResolve) {
                    if isResolving {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("Resolve Conflict")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isResolving)
            }
            .padding()
        }
        .frame(width: 600, height: 500)
    }

    // MARK: - Private Methods

    private func handleResolve() {
        isResolving = true

        Task {
            let resolution: ConflictResolution = selectedResolution == .keepLocal ? .keepLocal : .keepRemote

            await syncCoordinator.resolveConflict(resolution: resolution)

            isResolving = false
            dismiss()
        }
    }
}
