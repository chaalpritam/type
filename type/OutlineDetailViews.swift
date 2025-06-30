import SwiftUI

// MARK: - Outline Node Detail View
struct OutlineNodeDetailView: View {
    let node: OutlineNode
    @ObservedObject var outlineDatabase: OutlineDatabase
    @Environment(\.dismiss) private var dismiss
    @State private var showEditView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: iconForNodeType(node.nodeType))
                                .font(.title2)
                                .foregroundColor(colorForNodeType(node.nodeType))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(node.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(node.nodeType.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Edit") {
                                showEditView.toggle()
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        // Status and priority badges
                        HStack(spacing: 8) {
                            OutlineStatusBadge(status: node.metadata.status)
                            OutlinePriorityBadge(priority: node.metadata.priority)
                            
                            if node.metadata.isCompleted {
                                Label("Completed", systemImage: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            
                            if node.metadata.isImportant {
                                Label("Important", systemImage: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                    
                    // Content
                    if !node.content.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Content")
                                .font(.headline)
                            
                            Text(node.content)
                                .font(.body)
                                .padding()
                                .background(Color(NSColor.windowBackgroundColor))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(NSColor.controlBackgroundColor), lineWidth: 1)
                                )
                        }
                    }
                    
                    // Metadata
                    OutlineMetadataView(metadata: node.metadata)
                    
                    // Children
                    if !node.children.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Children (\(node.children.count))")
                                .font(.headline)
                            
                            ForEach(node.children) { child in
                                OutlineChildNodeView(
                                    child: child,
                                    outlineDatabase: outlineDatabase
                                )
                            }
                        }
                    }
                    
                    // Statistics
                    OutlineNodeStatisticsView(node: node)
                }
                .padding()
            }
            .navigationTitle("Node Details")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showEditView) {
            OutlineNodeEditView(
                node: node,
                outlineDatabase: outlineDatabase,
                isNewNode: false
            )
        }
    }
    
    private func iconForNodeType(_ type: NodeType) -> String {
        switch type {
        case .title: return "textformat"
        case .act: return "rectangle.split.3x1"
        case .sequence: return "list.number"
        case .scene: return "film"
        case .beat: return "waveform.path.ecg"
        case .character: return "person"
        case .location: return "mappin.and.ellipse"
        case .theme: return "lightbulb"
        case .subplot: return "arrow.branch"
        case .note: return "note.text"
        case .section: return "folder"
        case .chapter: return "book"
        case .part: return "doc.text"
        case .episode: return "tv"
        case .custom: return "circle"
        }
    }
    
    private func colorForNodeType(_ type: NodeType) -> Color {
        switch type {
        case .title: return .blue
        case .act: return .purple
        case .sequence: return .orange
        case .scene: return .green
        case .beat: return .red
        case .character: return .pink
        case .location: return .brown
        case .theme: return .yellow
        case .subplot: return .cyan
        case .note: return .gray
        case .section: return .indigo
        case .chapter: return .mint
        case .part: return .teal
        case .episode: return .red
        case .custom: return .secondary
        }
    }
}

// MARK: - Outline Node Edit View
struct OutlineNodeEditView: View {
    @State var node: OutlineNode
    @ObservedObject var outlineDatabase: OutlineDatabase
    let isNewNode: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var content: String
    @State private var nodeType: NodeType
    @State private var status: OutlineStatus
    @State private var priority: OutlinePriority
    @State private var isCompleted: Bool
    @State private var isImportant: Bool
    @State private var tags: [String]
    @State private var notes: String
    @State private var color: SceneColor
    @State private var newTag: String = ""
    
    init(node: OutlineNode, outlineDatabase: OutlineDatabase, isNewNode: Bool) {
        self.node = node
        self.outlineDatabase = outlineDatabase
        self.isNewNode = isNewNode
        
        _title = State(initialValue: node.title)
        _content = State(initialValue: node.content)
        _nodeType = State(initialValue: node.nodeType)
        _status = State(initialValue: node.metadata.status)
        _priority = State(initialValue: node.metadata.priority)
        _isCompleted = State(initialValue: node.metadata.isCompleted)
        _isImportant = State(initialValue: node.metadata.isImportant)
        _tags = State(initialValue: node.metadata.tags)
        _notes = State(initialValue: node.metadata.notes)
        _color = State(initialValue: node.metadata.color)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Title", text: $title)
                    
                    Picker("Type", selection: $nodeType) {
                        ForEach(NodeType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                }
                
                Section("Status & Priority") {
                    Picker("Status", selection: $status) {
                        ForEach(OutlineStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(OutlinePriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    Toggle("Completed", isOn: $isCompleted)
                    Toggle("Important", isOn: $isImportant)
                }
                
                Section("Tags") {
                    HStack {
                        TextField("Add tag", text: $newTag)
                        Button("Add") {
                            if !newTag.isEmpty && !tags.contains(newTag) {
                                tags.append(newTag)
                                newTag = ""
                            }
                        }
                        .disabled(newTag.isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                HStack {
                                    Text(tag)
                                        .font(.caption)
                                    Button(action: {
                                        tags.removeAll { $0 == tag }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption2)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.1))
                                .foregroundColor(.accentColor)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
                
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                        ForEach(SceneColor.allCases, id: \.self) { sceneColor in
                            Circle()
                                .fill(sceneColor.color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(color == sceneColor ? Color.primary : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    color = sceneColor
                                }
                        }
                    }
                }
            }
            .navigationTitle(isNewNode ? "New Node" : "Edit Node")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        saveNode()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveNode() {
        var updatedNode = node
        updatedNode.title = title
        updatedNode.content = content
        updatedNode.nodeType = nodeType
        updatedNode.metadata.status = status
        updatedNode.metadata.priority = priority
        updatedNode.metadata.isCompleted = isCompleted
        updatedNode.metadata.isImportant = isImportant
        updatedNode.metadata.tags = tags
        updatedNode.metadata.notes = notes
        updatedNode.metadata.color = color
        updatedNode.updatedAt = Date()
        
        if isNewNode {
            outlineDatabase.addNode(updatedNode)
        } else {
            outlineDatabase.updateNode(updatedNode)
        }
    }
}

// MARK: - Outline Metadata View
struct OutlineMetadataView: View {
    let metadata: OutlineMetadata
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Metadata")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                MetadataItem(title: "Word Count", value: "\(metadata.wordCount)")
                MetadataItem(title: "Scene Number", value: metadata.sceneNumber?.description ?? "N/A")
                MetadataItem(title: "Act Number", value: metadata.actNumber?.description ?? "N/A")
                MetadataItem(title: "Sequence", value: metadata.sequenceNumber?.description ?? "N/A")
                
                if let estimatedDuration = metadata.estimatedDuration {
                    MetadataItem(title: "Est. Duration", value: formatDuration(estimatedDuration))
                }
                
                if let actualDuration = metadata.actualDuration {
                    MetadataItem(title: "Actual Duration", value: formatDuration(actualDuration))
                }
            }
            
            if !metadata.characters.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Characters")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    FlowLayout(spacing: 4) {
                        ForEach(metadata.characters, id: \.self) { character in
                            Text(character)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            if !metadata.locations.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Locations")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    FlowLayout(spacing: 4) {
                        ForEach(metadata.locations, id: \.self) { location in
                            Text(location)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.1))
                                .foregroundColor(.green)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            if !metadata.tags.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tags")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    FlowLayout(spacing: 4) {
                        ForEach(metadata.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Outline Child Node View
struct OutlineChildNodeView: View {
    let child: OutlineNode
    @ObservedObject var outlineDatabase: OutlineDatabase
    
    var body: some View {
        HStack {
            Image(systemName: iconForNodeType(child.nodeType))
                .font(.caption)
                .foregroundColor(colorForNodeType(child.nodeType))
                .frame(width: 16, height: 16)
            
            Text(child.title)
                .font(.body)
                .lineLimit(1)
            
            Spacer()
            
            if child.metadata.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            outlineDatabase.selectNode(child.id)
        }
    }
    
    private func iconForNodeType(_ type: NodeType) -> String {
        switch type {
        case .title: return "textformat"
        case .act: return "rectangle.split.3x1"
        case .sequence: return "list.number"
        case .scene: return "film"
        case .beat: return "waveform.path.ecg"
        case .character: return "person"
        case .location: return "mappin.and.ellipse"
        case .theme: return "lightbulb"
        case .subplot: return "arrow.branch"
        case .note: return "note.text"
        case .section: return "folder"
        case .chapter: return "book"
        case .part: return "doc.text"
        case .episode: return "tv"
        case .custom: return "circle"
        }
    }
    
    private func colorForNodeType(_ type: NodeType) -> Color {
        switch type {
        case .title: return .blue
        case .act: return .purple
        case .sequence: return .orange
        case .scene: return .green
        case .beat: return .red
        case .character: return .pink
        case .location: return .brown
        case .theme: return .yellow
        case .subplot: return .cyan
        case .note: return .gray
        case .section: return .indigo
        case .chapter: return .mint
        case .part: return .teal
        case .episode: return .red
        case .custom: return .secondary
        }
    }
}

// MARK: - Outline Node Statistics View
struct OutlineNodeStatisticsView: View {
    let node: OutlineNode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                OutlineStatCard(
                    title: "Children",
                    value: "\(node.children.count)",
                    icon: "list.bullet"
                )
                
                OutlineStatCard(
                    title: "Level",
                    value: "\(node.level)",
                    icon: "arrow.down.right"
                )
                
                OutlineStatCard(
                    title: "Order",
                    value: "\(node.order)",
                    icon: "number"
                )
                
                OutlineStatCard(
                    title: "Created",
                    value: formatDate(node.createdAt),
                    icon: "calendar"
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Outline Priority Badge
struct OutlinePriorityBadge: View {
    let priority: OutlinePriority
    
    var priorityColor: Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
    
    var body: some View {
        Text(priority.rawValue)
            .font(.caption2)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(priorityColor.opacity(0.2))
            .foregroundColor(priorityColor)
            .cornerRadius(4)
    }
}

// MARK: - Metadata Item
struct MetadataItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        let positions: [CGPoint]
        let size: CGSize
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var currentPosition = CGPoint.zero
            var lineHeight: CGFloat = 0
            var maxWidth = maxWidth
            
            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)
                
                if currentPosition.x + subviewSize.width > maxWidth && currentPosition.x > 0 {
                    currentPosition.x = 0
                    currentPosition.y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(currentPosition)
                currentPosition.x += subviewSize.width + spacing
                lineHeight = max(lineHeight, subviewSize.height)
            }
            
            self.positions = positions
            self.size = CGSize(width: maxWidth, height: currentPosition.y + lineHeight)
        }
    }
} 