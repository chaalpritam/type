import SwiftUI

// MARK: - Outline Node Detail View
struct OutlineNodeDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    let node: OutlineNode
    @ObservedObject var outlineDatabase: OutlineDatabase
    @State private var showEditView = false
    
    var body: some View {
        VStack(spacing: 0) {
            DetailModalHeader(
                title: node.title,
                subtitle: node.nodeType.rawValue,
                onDone: { dismiss() },
                onEdit: { showEditView = true }
            )
            
            ScrollView {
                VStack(spacing: TypeSpacing.xl) {
                    // Status row
                    HStack(spacing: TypeSpacing.lg) {
                        DetailStat(label: "Status", value: node.metadata.status.rawValue, color: statusColor(for: node.metadata.status))
                        DetailStat(label: "Priority", value: node.metadata.priority.rawValue, color: priorityColor(for: node.metadata.priority))
                        DetailStat(label: "Words", value: "\(node.metadata.wordCount)", color: TypeColors.accent)
                    }
                    .padding(TypeSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: TypeRadius.md)
                            .fill(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
                    )
                    
                    // Badges
                    if node.metadata.isCompleted || node.metadata.isImportant {
                        HStack(spacing: TypeSpacing.sm) {
                            if node.metadata.isCompleted {
                                TypeNodeBadge(icon: "checkmark.circle.fill", text: "Completed", color: TypeColors.sceneGreen)
                            }
                            if node.metadata.isImportant {
                                TypeNodeBadge(icon: "star.fill", text: "Important", color: TypeColors.sceneYellow)
                            }
                            Spacer()
                        }
                    }
                    
                    // Content
                    if !node.content.isEmpty {
                        DetailSection(title: "Content") {
                            Text(node.content)
                                .font(TypeTypography.body)
                                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    // Metadata
                    DetailSection(title: "Details") {
                        VStack(spacing: TypeSpacing.sm) {
                            if let sceneNumber = node.metadata.sceneNumber {
                                DetailRow(label: "Scene Number", value: "\(sceneNumber)")
                            }
                            if let actNumber = node.metadata.actNumber {
                                DetailRow(label: "Act Number", value: "\(actNumber)")
                            }
                            if let sequence = node.metadata.sequenceNumber {
                                DetailRow(label: "Sequence", value: "\(sequence)")
                            }
                            DetailRow(label: "Level", value: "\(node.level)")
                            DetailRow(label: "Children", value: "\(node.children.count)")
                            DetailRow(label: "Created", value: node.createdAt.formatted(date: .abbreviated, time: .omitted))
                            DetailRow(label: "Updated", value: node.updatedAt.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                    
                    // Characters
                    if !node.metadata.characters.isEmpty {
                        DetailSection(title: "Characters") {
                            FlowLayout(spacing: TypeSpacing.xs) {
                                ForEach(node.metadata.characters, id: \.self) { character in
                                    Text(character)
                                        .font(TypeTypography.caption)
                                        .foregroundColor(TypeColors.scenePink)
                                        .padding(.horizontal, TypeSpacing.sm)
                                        .padding(.vertical, TypeSpacing.xxs)
                                        .background(TypeColors.scenePink.opacity(0.1))
                                        .cornerRadius(TypeRadius.full)
                                }
                            }
                        }
                    }
                    
                    // Locations
                    if !node.metadata.locations.isEmpty {
                        DetailSection(title: "Locations") {
                            FlowLayout(spacing: TypeSpacing.xs) {
                                ForEach(node.metadata.locations, id: \.self) { location in
                                    Text(location)
                                        .font(TypeTypography.caption)
                                        .foregroundColor(TypeColors.sceneGreen)
                                        .padding(.horizontal, TypeSpacing.sm)
                                        .padding(.vertical, TypeSpacing.xxs)
                                        .background(TypeColors.sceneGreen.opacity(0.1))
                                        .cornerRadius(TypeRadius.full)
                                }
                            }
                        }
                    }
                    
                    // Tags
                    if !node.metadata.tags.isEmpty {
                        DetailSection(title: "Tags") {
                            FlowLayout(spacing: TypeSpacing.xs) {
                                ForEach(node.metadata.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(TypeTypography.caption)
                                        .foregroundColor(TypeColors.accent)
                                        .padding(.horizontal, TypeSpacing.sm)
                                        .padding(.vertical, TypeSpacing.xxs)
                                        .background(TypeColors.accent.opacity(0.1))
                                        .cornerRadius(TypeRadius.full)
                                }
                            }
                        }
                    }
                    
                    // Notes
                    if !node.metadata.notes.isEmpty {
                        DetailSection(title: "Notes") {
                            Text(node.metadata.notes)
                                .font(TypeTypography.body)
                                .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    // Children
                    if !node.children.isEmpty {
                        DetailSection(title: "Children (\(node.children.count))") {
                            VStack(spacing: TypeSpacing.xs) {
                                ForEach(node.children) { child in
                                    TypeChildNodeRow(child: child, outlineDatabase: outlineDatabase)
                                }
                            }
                        }
                    }
                }
                .padding(TypeSpacing.xl)
            }
        }
        .frame(minWidth: 480, minHeight: 500)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
        .sheet(isPresented: $showEditView) {
            OutlineNodeEditView(node: node, outlineDatabase: outlineDatabase, isNewNode: false)
        }
    }
    
    private func statusColor(for status: OutlineStatus) -> Color {
        switch status {
        case .draft: return TypeColors.tertiaryTextLight
        case .outline: return TypeColors.sceneBlue
        case .inProgress: return TypeColors.sceneOrange
        case .completed: return TypeColors.sceneGreen
        case .revised: return TypeColors.scenePurple
        case .final: return TypeColors.sceneRed
        case .archived: return TypeColors.sceneOrange
        }
    }
    
    private func priorityColor(for priority: OutlinePriority) -> Color {
        switch priority {
        case .low: return TypeColors.sceneGreen
        case .medium: return TypeColors.sceneOrange
        case .high: return TypeColors.sceneRed
        case .critical: return TypeColors.scenePurple
        }
    }
}

// MARK: - Type Node Badge
struct TypeNodeBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: TypeSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(TypeTypography.caption)
        }
        .foregroundColor(color)
        .padding(.horizontal, TypeSpacing.sm)
        .padding(.vertical, TypeSpacing.xxs)
        .background(color.opacity(0.1))
        .cornerRadius(TypeRadius.full)
    }
}

// MARK: - Type Child Node Row
struct TypeChildNodeRow: View {
    @Environment(\.colorScheme) var colorScheme
    let child: OutlineNode
    @ObservedObject var outlineDatabase: OutlineDatabase
    @State private var isHovered = false
    
    var body: some View {
        Button(action: { outlineDatabase.selectNode(child.id) }) {
            HStack(spacing: TypeSpacing.sm) {
                Image(systemName: iconForNodeType(child.nodeType))
                    .font(.system(size: 11))
                    .foregroundColor(colorForNodeType(child.nodeType))
                    .frame(width: 16)
                
                Text(child.title)
                    .font(TypeTypography.body)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    .lineLimit(1)
                
                Spacer()
                
                if child.metadata.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(TypeColors.sceneGreen)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            }
            .padding(.horizontal, TypeSpacing.sm)
            .padding(.vertical, TypeSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: TypeRadius.sm)
                    .fill(isHovered ? (colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.03)) : .clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovered = hovering }
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
        case .title: return TypeColors.sceneBlue
        case .act: return TypeColors.scenePurple
        case .sequence: return TypeColors.sceneOrange
        case .scene: return TypeColors.sceneGreen
        case .beat: return TypeColors.sceneRed
        case .character: return TypeColors.scenePink
        case .location: return TypeColors.sceneOrange
        case .theme: return TypeColors.sceneYellow
        case .subplot: return TypeColors.sceneCyan
        case .note: return TypeColors.tertiaryTextLight
        case .section: return TypeColors.sceneBlue
        case .chapter: return TypeColors.sceneCyan
        case .part: return TypeColors.sceneCyan
        case .episode: return TypeColors.sceneRed
        case .custom: return TypeColors.secondaryTextLight
        }
    }
}

// MARK: - Outline Node Edit View
struct OutlineNodeEditView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State var node: OutlineNode
    @ObservedObject var outlineDatabase: OutlineDatabase
    let isNewNode: Bool
    
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
        VStack(spacing: 0) {
            ModalHeader(
                title: isNewNode ? "New Node" : "Edit Node",
                onCancel: { dismiss() },
                onSave: saveNode,
                canSave: !title.isEmpty
            )
            
            ScrollView {
                VStack(spacing: TypeSpacing.xl) {
                    // Basic Info
                    ModalSection(title: "Basic Information") {
                        VStack(spacing: TypeSpacing.md) {
                            ModalTextField(label: "Title", placeholder: "Node title", text: $title)
                            ModalEnumDropdown(label: "Type", selection: $nodeType)
                            ModalTextArea(label: "Content", placeholder: "Node content", text: $content)
                        }
                    }
                    
                    // Status
                    ModalSection(title: "Status & Priority") {
                        VStack(spacing: TypeSpacing.md) {
                            HStack(spacing: TypeSpacing.md) {
                                ModalEnumDropdown(label: "Status", selection: $status)
                                ModalEnumDropdown(label: "Priority", selection: $priority)
                            }
                            
                            HStack(spacing: TypeSpacing.lg) {
                                TypeEditToggle(title: "Completed", isOn: $isCompleted, color: TypeColors.sceneGreen)
                                TypeEditToggle(title: "Important", isOn: $isImportant, color: TypeColors.sceneYellow)
                                Spacer()
                            }
                        }
                    }
                    
                    // Tags
                    ModalSection(title: "Tags") {
                        ModalTagList(items: $tags, newItem: $newTag, placeholder: "Add a tag", color: TypeColors.accent)
                    }
                    
                    // Notes
                    ModalSection(title: "Notes") {
                        ModalTextArea(label: "", placeholder: "Additional notes", text: $notes)
                    }
                    
                    // Color
                    ModalSection(title: "Color") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: TypeSpacing.sm) {
                            ForEach(SceneColor.allCases, id: \.self) { sceneColor in
                                Circle()
                                    .fill(sceneColor.color)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle()
                                            .stroke(color == sceneColor ? (colorScheme == .dark ? Color.white : Color.black) : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture { color = sceneColor }
                            }
                        }
                    }
                }
                .padding(TypeSpacing.xl)
            }
        }
        .frame(minWidth: 500, minHeight: 600)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
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
        
        dismiss()
    }
}

// MARK: - Type Edit Toggle
struct TypeEditToggle: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        Button(action: { isOn.toggle() }) {
            HStack(spacing: TypeSpacing.xs) {
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundColor(isOn ? color : (colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight))
                
                Text(title)
                    .font(TypeTypography.body)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Outline Priority Badge
struct OutlinePriorityBadge: View {
    let priority: OutlinePriority
    
    var body: some View {
        Text(priority.rawValue)
            .font(TypeTypography.caption2)
            .foregroundColor(priorityColor)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(priorityColor.opacity(0.12))
            .cornerRadius(TypeRadius.xs)
    }
    
    private var priorityColor: Color {
        switch priority {
        case .low: return TypeColors.sceneGreen
        case .medium: return TypeColors.sceneOrange
        case .high: return TypeColors.sceneRed
        case .critical: return TypeColors.scenePurple
        }
    }
}

// MARK: - Metadata Item
struct MetadataItem: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(TypeTypography.caption)
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            Text(value)
                .font(TypeTypography.body)
                .fontWeight(.medium)
                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
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
