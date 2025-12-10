import SwiftUI

// MARK: - Outline Main View
struct OutlineView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var outlineDatabase: OutlineDatabase
    @Binding var isVisible: Bool
    @State private var showAddNode = false
    @State private var showSearchFilters = false
    @State private var hoveredNodeId: UUID?
    @State private var selectedNodeForAction: OutlineNode?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            TypeOutlineHeader(
                statistics: outlineDatabase.statistics,
                onAddNode: { showAddNode = true }
            )
            
            // Search bar
            TypeOutlineSearchBar(
                searchFilters: $outlineDatabase.searchFilters,
                showFilters: $showSearchFilters,
                onSearch: { query in
                    _ = outlineDatabase.searchNodes(query)
                }
            )
            
            // Breadcrumb
            if !outlineDatabase.navigation.breadcrumb.isEmpty {
                TypeOutlineBreadcrumb(
                    breadcrumb: outlineDatabase.navigation.breadcrumb,
                    outlineDatabase: outlineDatabase
                )
            }
            
            // Content
            if outlineDatabase.outline.rootNodes.isEmpty {
                TypeEmptyState(
                    icon: "list.bullet.indent",
                    title: "No Outline",
                    message: "Your document outline will appear here as you write."
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(outlineDatabase.outline.rootNodes) { node in
                            TypeOutlineNodeRow(
                                node: node,
                                outlineDatabase: outlineDatabase,
                                hoveredNodeId: $hoveredNodeId,
                                selectedNodeForAction: $selectedNodeForAction
                            )
                        }
                    }
                    .padding(.vertical, TypeSpacing.sm)
                }
            }
        }
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
        .sheet(isPresented: $showAddNode) {
            OutlineNodeEditView(
                node: OutlineNode(title: "", nodeType: .scene),
                outlineDatabase: outlineDatabase,
                isNewNode: true
            )
        }
        .sheet(item: $selectedNodeForAction) { node in
            OutlineNodeDetailView(
                node: node,
                outlineDatabase: outlineDatabase
            )
        }
    }
}

// MARK: - Type Outline Header
struct TypeOutlineHeader: View {
    @Environment(\.colorScheme) var colorScheme
    let statistics: OutlineStatistics
    let onAddNode: () -> Void
    
    var body: some View {
        VStack(spacing: TypeSpacing.md) {
            // Title row
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
                    Text("Outline")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    
                    Text("\(statistics.totalNodes) nodes in your screenplay")
                        .font(TypeTypography.caption)
                        .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                }
                
                Spacer()
                
                Button(action: onAddNode) {
                    HStack(spacing: TypeSpacing.xs) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .medium))
                        Text("Add")
                            .font(TypeTypography.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, TypeSpacing.md)
                    .padding(.vertical, TypeSpacing.sm)
                    .background(TypeColors.accent)
                    .cornerRadius(TypeRadius.sm)
                }
                .buttonStyle(.plain)
            }
            
            // Stats row
            HStack(spacing: TypeSpacing.md) {
                TypeOutlineStatCard(
                    value: "\(statistics.totalNodes)",
                    label: "Nodes",
                    icon: "list.bullet",
                    color: TypeColors.accent
                )
                
                TypeOutlineStatCard(
                    value: "\(statistics.completedNodes)",
                    label: "Done",
                    icon: "checkmark.circle",
                    color: TypeColors.sceneGreen
                )
                
                TypeOutlineStatCard(
                    value: "\(statistics.totalWords)",
                    label: "Words",
                    icon: "text.word.spacing",
                    color: TypeColors.scenePurple
                )
                
                TypeOutlineStatCard(
                    value: String(format: "%.0f%%", statistics.outlineHealth.overallHealth * 100),
                    label: "Health",
                    icon: "heart",
                    color: statistics.outlineHealth.overallHealth > 0.7 ? TypeColors.sceneGreen : TypeColors.sceneOrange
                )
            }
        }
        .padding(TypeSpacing.md)
        .background(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight),
            alignment: .bottom
        )
    }
}

// MARK: - Type Outline Stat Card
struct TypeOutlineStatCard: View {
    @Environment(\.colorScheme) var colorScheme
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: TypeSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 24, height: 24)
                .background(color.opacity(0.12))
                .cornerRadius(TypeRadius.xs)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                Text(label)
                    .font(TypeTypography.caption2)
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Type Outline Search Bar
struct TypeOutlineSearchBar: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var searchFilters: OutlineSearchFilters
    @Binding var showFilters: Bool
    let onSearch: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: TypeSpacing.sm) {
                // Search field
                HStack(spacing: TypeSpacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12))
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                    
                    TextField("Search outline...", text: $searchFilters.searchText)
                        .textFieldStyle(.plain)
                        .font(TypeTypography.body)
                        .onSubmit { onSearch(searchFilters.searchText) }
                    
                    if !searchFilters.searchText.isEmpty {
                        Button(action: { searchFilters.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, TypeSpacing.sm)
                .padding(.vertical, TypeSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: TypeRadius.sm)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                )
                
                // Filter button
                Button(action: { withAnimation(TypeAnimation.standard) { showFilters.toggle() } }) {
                    Image(systemName: showFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .font(.system(size: 16))
                        .foregroundColor(showFilters ? TypeColors.accent : (colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, TypeSpacing.md)
            .padding(.vertical, TypeSpacing.sm)
            
            // Filter panel
            if showFilters {
                TypeOutlineFilterPanel(searchFilters: $searchFilters)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight),
            alignment: .bottom
        )
    }
}

// MARK: - Type Outline Filter Panel
struct TypeOutlineFilterPanel: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var searchFilters: OutlineSearchFilters
    
    var body: some View {
        VStack(spacing: TypeSpacing.md) {
            // Header
            HStack {
                Text("Filters")
                    .font(TypeTypography.subheadline)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                Spacer()
                
                Button("Clear") {
                    searchFilters = OutlineSearchFilters()
                }
                .font(TypeTypography.caption)
                .foregroundColor(TypeColors.accent)
                .buttonStyle(.plain)
            }
            
            // Filter options
            HStack(spacing: TypeSpacing.md) {
                TypeOutlineFilterPicker(title: "Type", selection: $searchFilters.nodeType, options: NodeType.allCases)
                TypeOutlineFilterPicker(title: "Status", selection: $searchFilters.status, options: OutlineStatus.allCases)
                TypeOutlineFilterPicker(title: "Priority", selection: $searchFilters.priority, options: OutlinePriority.allCases)
            }
            
            // Toggles
            HStack(spacing: TypeSpacing.lg) {
                TypeFilterToggleButton(title: "Completed", isOn: $searchFilters.showCompleted)
                TypeFilterToggleButton(title: "Drafts", isOn: $searchFilters.showDrafts)
                TypeFilterToggleButton(title: "Archived", isOn: $searchFilters.showArchived)
                Spacer()
            }
        }
        .padding(TypeSpacing.md)
        .background(colorScheme == .dark ? Color.black.opacity(0.2) : Color.black.opacity(0.03))
    }
}

// MARK: - Type Outline Filter Picker
struct TypeOutlineFilterPicker<T: CaseIterable & Hashable & RawRepresentable>: View where T.RawValue == String {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    @Binding var selection: T?
    let options: [T]
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
            Text(title)
                .font(TypeTypography.caption2)
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            
            Menu {
                Button("Any") { selection = nil }
                Divider()
                ForEach(options, id: \.self) { option in
                    Button(option.rawValue) { selection = option }
                }
            } label: {
                HStack {
                    Text(selection?.rawValue ?? "Any")
                        .font(TypeTypography.caption)
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9))
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                }
                .padding(.horizontal, TypeSpacing.sm)
                .padding(.vertical, TypeSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: TypeRadius.xs)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05))
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Type Filter Toggle Button
struct TypeFilterToggleButton: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: { isOn.toggle() }) {
            HStack(spacing: TypeSpacing.xs) {
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .font(.system(size: 12))
                    .foregroundColor(isOn ? TypeColors.accent : (colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight))
                
                Text(title)
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Type Outline Breadcrumb
struct TypeOutlineBreadcrumb: View {
    @Environment(\.colorScheme) var colorScheme
    let breadcrumb: [UUID]
    @ObservedObject var outlineDatabase: OutlineDatabase
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TypeSpacing.xs) {
                ForEach(Array(breadcrumb.enumerated()), id: \.element) { index, nodeId in
                    if let node = findNode(nodeId, in: outlineDatabase.outline.rootNodes) {
                        Button(action: { outlineDatabase.selectNode(nodeId) }) {
                            Text(node.title)
                                .font(TypeTypography.caption)
                                .foregroundColor(TypeColors.accent)
                                .padding(.horizontal, TypeSpacing.sm)
                                .padding(.vertical, TypeSpacing.xxs)
                                .background(TypeColors.accent.opacity(0.1))
                                .cornerRadius(TypeRadius.xs)
                        }
                        .buttonStyle(.plain)
                        
                        if index < breadcrumb.count - 1 {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 9))
                                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                        }
                    }
                }
            }
            .padding(.horizontal, TypeSpacing.md)
        }
        .padding(.vertical, TypeSpacing.xs)
        .background(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight),
            alignment: .bottom
        )
    }
    
    private func findNode(_ nodeId: UUID, in nodes: [OutlineNode]) -> OutlineNode? {
        for node in nodes {
            if node.id == nodeId { return node }
            if let found = findNode(nodeId, in: node.children) { return found }
        }
        return nil
    }
}

// MARK: - Type Outline Node Row
struct TypeOutlineNodeRow: View {
    @Environment(\.colorScheme) var colorScheme
    let node: OutlineNode
    @ObservedObject var outlineDatabase: OutlineDatabase
    @Binding var hoveredNodeId: UUID?
    @Binding var selectedNodeForAction: OutlineNode?
    
    private var isHovered: Bool { hoveredNodeId == node.id }
    private var isExpanded: Bool { outlineDatabase.navigation.expandedNodes.contains(node.id) }
    private var isSelected: Bool { outlineDatabase.selectedNodes.contains(node.id) }
    
    var body: some View {
        VStack(spacing: 0) {
            // Node row
            HStack(spacing: TypeSpacing.sm) {
                // Indent
                ForEach(0..<node.level, id: \.self) { _ in
                    Rectangle()
                        .fill(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight)
                        .frame(width: 1, height: 20)
                        .padding(.leading, TypeSpacing.sm)
                }
                
                // Expand/collapse
                if !node.children.isEmpty {
                    Button(action: {
                        withAnimation(TypeAnimation.quick) {
                            if isExpanded {
                                outlineDatabase.collapseNode(node.id)
                            } else {
                                outlineDatabase.expandNode(node.id)
                            }
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear.frame(width: 16, height: 16)
                }
                
                // Icon
                Image(systemName: iconForNodeType(node.nodeType))
                    .font(.system(size: 12))
                    .foregroundColor(colorForNodeType(node.nodeType))
                    .frame(width: 16)
                
                // Title
                Text(node.title)
                    .font(TypeTypography.body)
                    .foregroundColor(isSelected ? TypeColors.accent : (colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight))
                    .lineLimit(1)
                
                Spacer()
                
                // Metadata
                HStack(spacing: TypeSpacing.sm) {
                    if outlineDatabase.outline.showWordCounts && node.metadata.wordCount > 0 {
                        Text("\(node.metadata.wordCount)")
                            .font(TypeTypography.caption2)
                            .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                    }
                    
                    if outlineDatabase.outline.showStatus {
                        TypeOutlineStatusBadge(status: node.metadata.status)
                    }
                    
                    if node.metadata.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(TypeColors.sceneGreen)
                    }
                    
                    if node.metadata.isImportant {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(TypeColors.sceneYellow)
                    }
                }
            }
            .padding(.horizontal, TypeSpacing.md)
            .padding(.vertical, TypeSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: TypeRadius.sm)
                    .fill(isHovered || isSelected ?
                          (colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.03)) :
                          .clear)
                    .padding(.horizontal, TypeSpacing.sm)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                outlineDatabase.selectNode(node.id)
            }
            .onHover { hovering in
                hoveredNodeId = hovering ? node.id : nil
            }
            .contextMenu {
                Button("Add Child") {
                    let childNode = OutlineNode(title: "New Node", nodeType: .scene, level: node.level + 1)
                    outlineDatabase.addNode(childNode, to: node.id)
                }
                Button("Add Sibling") {
                    let siblingNode = OutlineNode(title: "New Node", nodeType: .scene, level: node.level)
                    outlineDatabase.addNode(siblingNode, to: node.parentId)
                }
                Divider()
                Button("View Details") {
                    selectedNodeForAction = node
                }
                Divider()
                Button("Delete", role: .destructive) {
                    outlineDatabase.removeNode(node.id)
                }
            }
            
            // Children
            if !node.children.isEmpty && isExpanded {
                ForEach(node.children) { childNode in
                    TypeOutlineNodeRow(
                        node: childNode,
                        outlineDatabase: outlineDatabase,
                        hoveredNodeId: $hoveredNodeId,
                        selectedNodeForAction: $selectedNodeForAction
                    )
                }
            }
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
        case .title: return TypeColors.sceneBlue
        case .act: return TypeColors.scenePurple
        case .sequence: return TypeColors.sceneOrange
        case .scene: return TypeColors.sceneGreen
        case .beat: return TypeColors.sceneRed
        case .character: return TypeColors.scenePink
        case .location: return TypeColors.sceneOrange
        case .theme: return TypeColors.sceneYellow
        case .subplot: return TypeColors.sceneCyan
        case .note: return colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight
        case .section: return TypeColors.sceneBlue
        case .chapter: return TypeColors.sceneCyan
        case .part: return TypeColors.sceneCyan
        case .episode: return TypeColors.sceneRed
        case .custom: return colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight
        }
    }
}

// MARK: - Type Outline Status Badge
struct TypeOutlineStatusBadge: View {
    let status: OutlineStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(TypeTypography.caption2)
            .foregroundColor(statusColor)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.12))
            .cornerRadius(TypeRadius.xs)
    }
    
    private var statusColor: Color {
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
}

// MARK: - Outline Status Badge (kept for compatibility)
struct OutlineStatusBadge: View {
    let status: OutlineStatus
    
    var body: some View {
        TypeOutlineStatusBadge(status: status)
    }
}

// MARK: - Outline Templates View
struct OutlineTemplatesView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var outlineDatabase: OutlineDatabase
    
    var body: some View {
        VStack(spacing: 0) {
            DetailModalHeader(title: "Templates", onDone: { dismiss() })
            
            ScrollView {
                LazyVStack(spacing: TypeSpacing.sm) {
                    ForEach(outlineDatabase.templates) { template in
                        TemplateRow(template: template) {
                            outlineDatabase.applyTemplate(template)
                            dismiss()
                        }
                    }
                }
                .padding(TypeSpacing.lg)
            }
        }
        .frame(minWidth: 400, minHeight: 400)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
    }
}

// MARK: - Template Row
struct TemplateRow: View {
    @Environment(\.colorScheme) var colorScheme
    let template: OutlineTemplate
    let onSelect: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: TypeSpacing.xs) {
                HStack {
                    Text(template.name)
                        .font(TypeTypography.body)
                        .fontWeight(.medium)
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    
                    Spacer()
                    
                    Text(template.templateType.rawValue)
                        .font(TypeTypography.caption2)
                        .foregroundColor(TypeColors.accent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(TypeColors.accent.opacity(0.1))
                        .cornerRadius(TypeRadius.xs)
                }
                
                if !template.description.isEmpty {
                    Text(template.description)
                        .font(TypeTypography.caption)
                        .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                        .lineLimit(2)
                }
                
                Text("\(template.structure.count) nodes")
                    .font(TypeTypography.caption2)
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            }
            .padding(TypeSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: TypeRadius.md)
                    .fill(isHovered ?
                          (colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.03)) :
                          (colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight))
            )
            .overlay(
                RoundedRectangle(cornerRadius: TypeRadius.md)
                    .stroke(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovered = hovering }
    }
}

// MARK: - Outline Statistics View
struct OutlineStatisticsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    let statistics: OutlineStatistics
    
    var body: some View {
        VStack(spacing: 0) {
            DetailModalHeader(title: "Statistics", onDone: { dismiss() })
            
            ScrollView {
                VStack(spacing: TypeSpacing.xl) {
                    // Overview
                    DetailSection(title: "Overview") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: TypeSpacing.md) {
                            StatCard(label: "Total Nodes", value: "\(statistics.totalNodes)", icon: "list.bullet", color: TypeColors.accent)
                            StatCard(label: "Completed", value: "\(statistics.completedNodes)", icon: "checkmark.circle", color: TypeColors.sceneGreen)
                            StatCard(label: "Total Words", value: "\(statistics.totalWords)", icon: "text.word.spacing", color: TypeColors.scenePurple)
                            StatCard(label: "Avg Words", value: String(format: "%.1f", statistics.averageWordsPerNode), icon: "number", color: TypeColors.sceneOrange)
                        }
                    }
                    
                    // By Type
                    DetailSection(title: "By Type") {
                        VStack(spacing: TypeSpacing.sm) {
                            ForEach(NodeType.allCases, id: \.self) { type in
                                if let count = statistics.nodesByType[type], count > 0 {
                                    DistributionRow(label: type.rawValue, value: count, total: statistics.totalNodes)
                                }
                            }
                        }
                    }
                    
                    // Health
                    DetailSection(title: "Health") {
                        VStack(alignment: .leading, spacing: TypeSpacing.sm) {
                            HStack {
                                Text("Overall Health")
                                    .font(TypeTypography.body)
                                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                                
                                Spacer()
                                
                                Text(String(format: "%.0f%%", statistics.outlineHealth.overallHealth * 100))
                                    .font(TypeTypography.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(statistics.outlineHealth.overallHealth > 0.7 ? TypeColors.sceneGreen : TypeColors.sceneOrange)
                            }
                            
                            if !statistics.outlineHealth.issues.isEmpty {
                                VStack(alignment: .leading, spacing: TypeSpacing.xs) {
                                    Text("Issues")
                                        .font(TypeTypography.caption)
                                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                                    
                                    ForEach(statistics.outlineHealth.issues, id: \.self) { issue in
                                        HStack(spacing: TypeSpacing.xs) {
                                            Circle()
                                                .fill(TypeColors.error)
                                                .frame(width: 4, height: 4)
                                            Text(issue.rawValue)
                                                .font(TypeTypography.caption)
                                                .foregroundColor(TypeColors.error)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(TypeSpacing.xl)
            }
        }
        .frame(minWidth: 460, minHeight: 500)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
    }
}
