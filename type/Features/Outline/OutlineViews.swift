import SwiftUI

// MARK: - Outline Main View
struct OutlineView: View {
    @ObservedObject var outlineDatabase: OutlineDatabase
    @Binding var isVisible: Bool
    @State private var showAddNode = false
    @State private var showTemplates = false
    @State private var showStatistics = false
    @State private var showSearchFilters = false
    @State private var selectedNodeForAction: OutlineNode?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with statistics
                OutlineHeaderView(
                    statistics: outlineDatabase.statistics,
                    showStatistics: $showStatistics
                )
                
                // Search and filters
                OutlineSearchBar(
                    searchFilters: $outlineDatabase.searchFilters,
                    showFilters: $showSearchFilters,
                    searchHistory: outlineDatabase.navigation.searchHistory,
                    onSearch: { query in
                        _ = outlineDatabase.searchNodes(query)
                    }
                )
                
                // Breadcrumb navigation
                if !outlineDatabase.navigation.breadcrumb.isEmpty {
                    OutlineBreadcrumbView(
                        breadcrumb: outlineDatabase.navigation.breadcrumb,
                        outlineDatabase: outlineDatabase
                    )
                }
                
                // Outline content
                OutlineContentView(
                    nodes: outlineDatabase.outline.rootNodes,
                    outlineDatabase: outlineDatabase,
                    selectedNodeForAction: $selectedNodeForAction
                )
            }
            .navigationTitle("Document Outline")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { isVisible = false }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddNode.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddNode) {
                OutlineNodeEditView(
                    node: OutlineNode(title: "", nodeType: .scene),
                    outlineDatabase: outlineDatabase,
                    isNewNode: true
                )
            }
            .sheet(isPresented: $showTemplates) {
                OutlineTemplatesView(outlineDatabase: outlineDatabase)
            }
            .sheet(isPresented: $showStatistics) {
                OutlineStatisticsView(statistics: outlineDatabase.statistics)
            }
        }
        .sheet(item: $selectedNodeForAction) { node in
            OutlineNodeDetailView(
                node: node,
                outlineDatabase: outlineDatabase
            )
        }
    }
}

// MARK: - Outline Header View
struct OutlineHeaderView: View {
    let statistics: OutlineStatistics
    @Binding var showStatistics: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            EnhancedHeaderView(
                title: "Document Outline",
                subtitle: "\(statistics.totalNodes) nodes • \(statistics.completedNodes) completed • \(String(format: "%.1f", statistics.averageWordsPerNode)) avg words"
            ) {
                Button("View Stats") {
                    showStatistics.toggle()
                }
                .buttonStyle(.bordered)
            }
            
            // Quick stats cards
            HStack(spacing: 12) {
                EnhancedStatCard(
                    title: "Nodes",
                    value: "\(statistics.totalNodes)",
                    icon: "list.bullet"
                )
                
                EnhancedStatCard(
                    title: "Completed",
                    value: "\(statistics.completedNodes)",
                    icon: "checkmark.circle"
                )
                
                EnhancedStatCard(
                    title: "Total Words",
                    value: "\(statistics.totalWords)",
                    icon: "text.word.spacing"
                )
                
                EnhancedStatCard(
                    title: "Health",
                    value: String(format: "%.0f%%", statistics.outlineHealth.overallHealth * 100),
                    icon: "heart",
                    color: statistics.outlineHealth.overallHealth > 0.7 ? .green : .orange
                )
            }
            .padding(.horizontal, ToolbarMetrics.horizontalPadding)
            .padding(.bottom, ToolbarMetrics.verticalPadding)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Outline Search Bar
struct OutlineSearchBar: View {
    @Binding var searchFilters: OutlineSearchFilters
    @Binding var showFilters: Bool
    let searchHistory: [String]
    let onSearch: (String) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                EnhancedSearchField(
                    text: $searchFilters.searchText,
                    placeholder: "Search outline..."
                )
                .onSubmit {
                    onSearch(searchFilters.searchText)
                }
                
                Button(action: { showFilters.toggle() }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            
            if showFilters {
                OutlineFilterView(searchFilters: $searchFilters)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.horizontal)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showFilters)
    }
}

// MARK: - Outline Filter View
struct OutlineFilterView: View {
    @Binding var searchFilters: OutlineSearchFilters
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Filters")
                    .font(.headline)
                Spacer()
                Button("Clear All") {
                    searchFilters = OutlineSearchFilters()
                }
                .font(.caption)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                // Node type filter
                VStack(alignment: .leading, spacing: 4) {
                    Text("Node Type")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Node Type", selection: $searchFilters.nodeType) {
                        Text("Any").tag(nil as NodeType?)
                        ForEach(NodeType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type as NodeType?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Status filter
                VStack(alignment: .leading, spacing: 4) {
                    Text("Status")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Status", selection: $searchFilters.status) {
                        Text("Any").tag(nil as OutlineStatus?)
                        ForEach(OutlineStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status as OutlineStatus?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Priority filter
                VStack(alignment: .leading, spacing: 4) {
                    Text("Priority")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Priority", selection: $searchFilters.priority) {
                        Text("Any").tag(nil as OutlinePriority?)
                        ForEach(OutlinePriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority as OutlinePriority?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Level filter
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Level", selection: $searchFilters.level) {
                        Text("Any").tag(nil as Int?)
                        ForEach(0..<6, id: \.self) { level in
                            Text("Level \(level)").tag(level as Int?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            
            // Visibility toggles
            VStack(spacing: 8) {
                Toggle("Show Completed", isOn: $searchFilters.showCompleted)
                Toggle("Show Drafts", isOn: $searchFilters.showDrafts)
                Toggle("Show Archived", isOn: $searchFilters.showArchived)
            }
            
            // Sort options
            HStack {
                Text("Sort by")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Sort by", selection: $searchFilters.sortBy) {
                    ForEach(OutlineSortOrder.allCases, id: \.self) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Button(action: {
                    searchFilters.sortOrder = searchFilters.sortOrder == .forward ? .reverse : .forward
                }) {
                    Image(systemName: searchFilters.sortOrder == .forward ? "arrow.up" : "arrow.down")
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Outline Breadcrumb View
struct OutlineBreadcrumbView: View {
    let breadcrumb: [UUID]
    @ObservedObject var outlineDatabase: OutlineDatabase
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(breadcrumb.enumerated()), id: \.element) { index, nodeId in
                    if let node = findNode(nodeId, in: outlineDatabase.outline.rootNodes) {
                        Button(action: {
                            outlineDatabase.selectNode(nodeId)
                        }) {
                            Text(node.title)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.1))
                                .foregroundColor(.accentColor)
                                .cornerRadius(4)
                        }
                        
                        if index < breadcrumb.count - 1 {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 4)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private func findNode(_ nodeId: UUID, in nodes: [OutlineNode]) -> OutlineNode? {
        for node in nodes {
            if node.id == nodeId {
                return node
            }
            if let found = findNode(nodeId, in: node.children) {
                return found
            }
        }
        return nil
    }
}

// MARK: - Outline Content View
struct OutlineContentView: View {
    let nodes: [OutlineNode]
    @ObservedObject var outlineDatabase: OutlineDatabase
    @Binding var selectedNodeForAction: OutlineNode?
    
    var body: some View {
        List {
            ForEach(nodes) { node in
                OutlineNodeRowView(
                    node: node,
                    outlineDatabase: outlineDatabase,
                    selectedNodeForAction: $selectedNodeForAction
                )
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Outline Node Row View
struct OutlineNodeRowView: View {
    let node: OutlineNode
    @ObservedObject var outlineDatabase: OutlineDatabase
    @Binding var selectedNodeForAction: OutlineNode?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                // Indent based on level
                ForEach(0..<node.level, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2)
                        .frame(height: 20)
                }
                
                // Expand/collapse button
                if !node.children.isEmpty {
                    Button(action: {
                        if outlineDatabase.navigation.expandedNodes.contains(node.id) {
                            outlineDatabase.collapseNode(node.id)
                        } else {
                            outlineDatabase.expandNode(node.id)
                        }
                    }) {
                        Image(systemName: outlineDatabase.navigation.expandedNodes.contains(node.id) ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 16, height: 16)
                    }
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 16, height: 16)
                }
                
                // Node icon
                Image(systemName: iconForNodeType(node.nodeType))
                    .font(.caption)
                    .foregroundColor(colorForNodeType(node.nodeType))
                    .frame(width: 16, height: 16)
                
                // Node title
                Text(node.title)
                    .font(.body)
                    .lineLimit(1)
                    .foregroundColor(outlineDatabase.selectedNodes.contains(node.id) ? .accentColor : .primary)
                
                Spacer()
                
                // Node metadata
                HStack(spacing: 8) {
                    if outlineDatabase.outline.showWordCounts && node.metadata.wordCount > 0 {
                        Text("\(node.metadata.wordCount)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    if outlineDatabase.outline.showStatus {
                        OutlineStatusBadge(status: node.metadata.status)
                    }
                    
                    if node.metadata.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    if node.metadata.isImportant {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .onTapGesture {
                outlineDatabase.selectNode(node.id)
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
                Button("Edit") {
                    selectedNodeForAction = node
                }
                Button("Delete", role: .destructive) {
                    outlineDatabase.removeNode(node.id)
                }
            }
            
            // Children nodes
            if !node.children.isEmpty && outlineDatabase.navigation.expandedNodes.contains(node.id) {
                ForEach(node.children) { childNode in
                    OutlineNodeRowView(
                        node: childNode,
                        outlineDatabase: outlineDatabase,
                        selectedNodeForAction: $selectedNodeForAction
                    )
                    .padding(.leading, 20)
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

// MARK: - Outline Status Badge
struct OutlineStatusBadge: View {
    let status: OutlineStatus
    
    var statusColor: Color {
        switch status {
        case .draft: return .gray
        case .outline: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        case .revised: return .purple
        case .final: return .red
        case .archived: return .brown
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption2)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(4)
    }
}

// MARK: - Outline Templates View
struct OutlineTemplatesView: View {
    @ObservedObject var outlineDatabase: OutlineDatabase
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(outlineDatabase.templates) { template in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(template.name)
                                .font(.headline)
                            Spacer()
                            Text(template.templateType.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if !template.description.isEmpty {
                            Text(template.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("\(template.structure.count) nodes")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        outlineDatabase.applyTemplate(template)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Templates")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Outline Statistics View
struct OutlineStatisticsView: View {
    let statistics: OutlineStatistics
    
    var body: some View {
        NavigationView {
            List {
                Section("Overview") {
                    HStack {
                        Label("Total Nodes", systemImage: "list.bullet")
                        Spacer()
                        Text("\(statistics.totalNodes)")
                    }
                    HStack {
                        Label("Completed", systemImage: "checkmark.circle")
                        Spacer()
                        Text("\(statistics.completedNodes)")
                    }
                    HStack {
                        Label("Total Words", systemImage: "text.word.spacing")
                        Spacer()
                        Text("\(statistics.totalWords)")
                    }
                    HStack {
                        Label("Avg Words/Node", systemImage: "text.alignleft")
                        Spacer()
                        Text(String(format: "%.1f", statistics.averageWordsPerNode))
                    }
                }
                
                Section("By Type") {
                    ForEach(NodeType.allCases, id: \.self) { type in
                        HStack {
                            Text(type.rawValue)
                            Spacer()
                            Text("\(statistics.nodesByType[type] ?? 0)")
                        }
                    }
                }
                
                Section("By Status") {
                    ForEach(OutlineStatus.allCases, id: \.self) { status in
                        HStack {
                            Text(status.rawValue)
                            Spacer()
                            Text("\(statistics.nodesByStatus[status] ?? 0)")
                        }
                    }
                }
                
                Section("Health") {
                    HStack {
                        Text("Overall Health")
                        Spacer()
                        Text(String(format: "%.0f%%", statistics.outlineHealth.overallHealth * 100))
                            .foregroundColor(statistics.outlineHealth.overallHealth > 0.7 ? .green : .orange)
                    }
                    
                    if !statistics.outlineHealth.issues.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Issues:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ForEach(statistics.outlineHealth.issues, id: \.self) { issue in
                                Text("• \(issue.rawValue)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Outline Statistics")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { }
                }
            }
        }
    }
}
