import SwiftUI
import Features.Collaboration.CollaborationManager

// MARK: - Comments Panel
struct CommentsPanel: View {
    @ObservedObject var collaborationManager: CollaborationManager
    @State private var newCommentText = ""
    @State private var selectedLine: Int?
    @State private var showResolvedComments = false
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Comments")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Toggle("Show Resolved", isOn: $showResolvedComments)
                    .toggleStyle(SwitchToggleStyle())
                    .scaleEffect(0.8)
                
                Button(action: { isVisible = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Comments List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredComments) { comment in
                        CommentView(
                            comment: comment,
                            collaborationManager: collaborationManager
                        )
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Add Comment
            HStack {
                TextField("Add a comment...", text: $newCommentText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...3)
                
                Button("Add") {
                    if !newCommentText.isEmpty {
                        collaborationManager.addComment(
                            text: newCommentText,
                            lineNumber: selectedLine ?? 0,
                            selection: nil
                        )
                        newCommentText = ""
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(newCommentText.isEmpty)
            }
            .padding()
        }
        .frame(minWidth: 300, maxWidth: 400)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var filteredComments: [Comment] {
        if showResolvedComments {
            return collaborationManager.comments
        } else {
            return collaborationManager.comments.filter { !$0.isResolved }
        }
    }
}

// MARK: - Comment View
struct CommentView: View {
    let comment: Comment
    @ObservedObject var collaborationManager: CollaborationManager
    @State private var showReplies = false
    @State private var newReplyText = ""
    @State private var isReplying = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Comment Header
            HStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text(comment.author.displayName.prefix(1).uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(comment.author.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Line \(comment.lineNumber) • \(comment.timestamp, style: .relative)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(comment.isResolvedDisplay)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(comment.isResolved ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                        )
                        .foregroundColor(comment.isResolved ? .green : .orange)
                    
                    Menu {
                        Button("Reply") {
                            isReplying = true
                        }
                        
                        if !comment.isResolved {
                            Button("Resolve") {
                                collaborationManager.resolveComment(commentId: comment.id)
                            }
                        }
                        
                        Button("Delete", role: .destructive) {
                            collaborationManager.deleteComment(commentId: comment.id)
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Comment Text
            Text(comment.text)
                .font(.body)
                .textSelection(.enabled)
            
            // Replies
            if !comment.replies.isEmpty {
                Button(action: { showReplies.toggle() }) {
                    HStack {
                        Text("\(comment.replies.count) replies")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                        
                        Image(systemName: showReplies ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                    }
                }
                .buttonStyle(.plain)
                
                if showReplies {
                    VStack(spacing: 8) {
                        ForEach(comment.replies) { reply in
                            ReplyView(reply: reply)
                        }
                    }
                    .padding(.leading, 20)
                }
            }
            
            // Reply Input
            if isReplying {
                VStack(spacing: 8) {
                    TextField("Write a reply...", text: $newReplyText, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(2...4)
                    
                    HStack {
                        Button("Cancel") {
                            isReplying = false
                            newReplyText = ""
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Button("Reply") {
                            collaborationManager.replyToComment(commentId: comment.id, text: newReplyText)
                            isReplying = false
                            newReplyText = ""
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newReplyText.isEmpty)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
}

// MARK: - Reply View
struct ReplyView: View {
    let reply: CommentReply
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Text(reply.author.displayName.prefix(1).uppercased())
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
                
                Text(reply.author.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("• \(reply.timestamp, style: .relative)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            Text(reply.text)
                .font(.caption)
                .textSelection(.enabled)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(NSColor.windowBackgroundColor))
        )
    }
}

// MARK: - Version History
struct VersionHistory: View {
    @ObservedObject var collaborationManager: CollaborationManager
    @State private var selectedVersion: DocumentVersion?
    @State private var showCreateVersion = false
    @State private var versionDescription = ""
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Version History")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Create Version") {
                    showCreateVersion = true
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: { isVisible = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Versions List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(collaborationManager.versions.reversed()) { version in
                        VersionRow(
                            version: version,
                            isSelected: selectedVersion?.id == version.id
                        ) {
                            selectedVersion = version
                        }
                    }
                }
                .padding()
            }
        }
        .frame(minWidth: 300, maxWidth: 400)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showCreateVersion) {
            CreateVersionSheet(
                collaborationManager: collaborationManager,
                versionDescription: $versionDescription
            )
        }
    }
}

// MARK: - Version Row
struct VersionRow: View {
    let version: DocumentVersion
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(version.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(version.timestamp, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text(version.author.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Create Version Sheet
struct CreateVersionSheet: View {
    @ObservedObject var collaborationManager: CollaborationManager
    @Binding var versionDescription: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create New Version")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Version Description")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Describe the changes in this version...", text: $versionDescription, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Create Version") {
                    // This would need the current document content
                    collaborationManager.createVersion(
                        content: "Current document content",
                        description: versionDescription
                    )
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(versionDescription.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
    }
}

// MARK: - Sharing Dialog
struct SharingDialog: View {
    @ObservedObject var collaborationManager: CollaborationManager
    @State private var emailAddresses = ""
    @State private var selectedRole: CollaboratorRole = .commenter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with close button
            HStack {
                Text("Share Document")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Email Addresses")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Enter email addresses separated by commas", text: $emailAddresses, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(2...4)
                
                Text("Separate multiple email addresses with commas")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Permission Level")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("Role", selection: $selectedRole) {
                    ForEach(CollaboratorRole.allCases, id: \.self) { role in
                        VStack(alignment: .leading) {
                            Text(role.rawValue)
                            Text(role.permissions.map { $0.rawValue }.joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .tag(role)
                    }
                }
                .pickerStyle(.menu)
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Share") {
                    let emails = emailAddresses
                        .components(separatedBy: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    
                    collaborationManager.shareDocument(emails: emails, role: selectedRole)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(emailAddresses.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
    }
}

// MARK: - Invite Collaborator Sheet
struct InviteCollaboratorSheet: View {
    @ObservedObject var collaborationManager: CollaborationManager
    @State private var emailAddresses = ""
    @State private var selectedRole: CollaboratorRole = .commenter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with close button
            HStack {
                Text("Invite Collaborators")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Email Addresses")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Enter email addresses separated by commas", text: $emailAddresses, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(2...4)
                
                Text("Separate multiple email addresses with commas")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Permission Level")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("Role", selection: $selectedRole) {
                    ForEach(CollaboratorRole.allCases, id: \.self) { role in
                        VStack(alignment: .leading) {
                            Text(role.rawValue)
                            Text(role.permissions.map { $0.rawValue }.joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .tag(role)
                    }
                }
                .pickerStyle(.menu)
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Invite") {
                    let emails = emailAddresses
                        .components(separatedBy: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    
                    collaborationManager.shareDocument(emails: emails, role: selectedRole)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(emailAddresses.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
    }
}

// MARK: - Collaborators Panel
struct CollaboratorsPanel: View {
    @ObservedObject var collaborationManager: CollaborationManager
    @State private var showInviteDialog = false
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Collaborators")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Invite") {
                    showInviteDialog = true
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: { isVisible = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Online Users
            if !collaborationManager.onlineUsers.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Online")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal)
                    
                    ForEach(collaborationManager.onlineUsers) { user in
                        CollaboratorRow(collaborator: user, isOnline: true)
                    }
                }
                .padding(.vertical, 8)
                
                Divider()
            }
            
            // All Collaborators
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(collaborationManager.collaborators) { collaborator in
                        CollaboratorRow(
                            collaborator: collaborator,
                            isOnline: collaborator.isOnline
                        )
                    }
                }
                .padding()
            }
        }
        .frame(minWidth: 250, maxWidth: 300)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showInviteDialog) {
            InviteCollaboratorSheet(collaborationManager: collaborationManager)
        }
    }
}

// MARK: - Collaborator Row
struct CollaboratorRow: View {
    let collaborator: Collaborator
    let isOnline: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(collaborator.displayName.prefix(1).uppercased())
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
                
                if isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color(NSColor.windowBackgroundColor), lineWidth: 2)
                        )
                        .offset(x: 12, y: 12)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(collaborator.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(collaborator.role.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isOnline {
                Text("Online")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
} 