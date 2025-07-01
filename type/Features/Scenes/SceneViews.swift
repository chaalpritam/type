import SwiftUI
import Data.SceneModels
import Features.Scenes.SceneDatabase

// MARK: - Scene Management Main View
struct SceneManagementView: View {
    @ObservedObject var sceneDatabase: SceneDatabase
    @State private var showAddScene = false
    @State private var showSearchFilters = false
    @State private var showStatistics = false
    @State private var showBookmarks = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with statistics
                SceneManagementHeader(
                    statistics: sceneDatabase.statistics,
                    showStatistics: $showStatistics
                )
                
                // Search and filters
                SceneSearchBar(
                    searchFilters: $sceneDatabase.searchFilters,
                    showFilters: $showSearchFilters,
                    searchHistory: sceneDatabase.searchHistory,
                    onSearch: { query in
                        sceneDatabase.addToSearchHistory(query)
                    }
                )
                
                // Scene navigation controls
                SceneNavigationControls(sceneDatabase: sceneDatabase)
                
                // Scene content based on view mode
                SceneContentView(
                    scenes: sceneDatabase.filteredScenes(),
                    selectedScene: $sceneDatabase.selectedScene,
                    currentSceneIndex: sceneDatabase.currentSceneIndex,
                    viewMode: sceneDatabase.searchFilters.viewMode,
                    onSceneSelect: { scene in
                        sceneDatabase.goToScene(scene)
                    },
                    onSceneDelete: { scene in
                        sceneDatabase.deleteScene(scene)
                    }
                )
            }
            .navigationTitle("Scene Management")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Bookmarks") {
                        showBookmarks.toggle()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddScene.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddScene) {
                SceneEditView(
                    scene: Scene(heading: "", content: "", lineNumber: 0),
                    sceneDatabase: sceneDatabase,
                    isNewScene: true
                )
            }
            .sheet(isPresented: $showStatistics) {
                SceneStatisticsView(statistics: sceneDatabase.statistics)
            }
            .sheet(isPresented: $showBookmarks) {
                SceneBookmarksView(sceneDatabase: sceneDatabase)
            }
        }
        .sheet(item: $sceneDatabase.selectedScene) { scene in
            SceneDetailView(
                scene: scene,
                sceneDatabase: sceneDatabase
            )
        }
    }
}

// MARK: - Scene Management Header
struct SceneManagementHeader: View {
    let statistics: SceneStatistics
    @Binding var showStatistics: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scene Management")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(statistics.totalScenes) scenes • \(statistics.completedScenes) completed • \(String(format: "%.1f", statistics.averageSceneLength)) avg words")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("View Stats") {
                    showStatistics.toggle()
                }
                .buttonStyle(.bordered)
            }
            
            // Quick stats cards
            HStack(spacing: 12) {
                SceneStatCard(
                    title: "Total",
                    value: "\(statistics.totalScenes)",
                    icon: "film"
                )
                
                SceneStatCard(
                    title: "Completed",
                    value: "\(statistics.completedScenes)",
                    icon: "checkmark.circle"
                )
                
                SceneStatCard(
                    title: "Avg Length",
                    value: String(format: "%.0f", statistics.averageSceneLength),
                    icon: "text.alignleft"
                )
                
                SceneStatCard(
                    title: "Total Words",
                    value: "\(statistics.totalWordCount)",
                    icon: "text.word.spacing"
                )
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Scene Search Bar
struct SceneSearchBar: View {
    @Binding var searchFilters: SceneSearchFilters
    @Binding var showFilters: Bool
    let searchHistory: [String]
    let onSearch: (String) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search scenes...", text: $searchFilters.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        onSearch(searchFilters.searchText)
                    }
                
                if !searchFilters.searchText.isEmpty {
                    Button(action: { searchFilters.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: { showFilters.toggle() }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            
            if showFilters {
                SceneFilterView(searchFilters: $searchFilters)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.3), value: showFilters)
    }
}

// MARK: - Scene Filter View
struct SceneFilterView: View {
    @Binding var searchFilters: SceneSearchFilters
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Filters")
                    .font(.headline)
                Spacer()
                Button("Clear All") {
                    searchFilters = SceneSearchFilters()
                }
                .font(.caption)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                // Scene type filter
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scene Type")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Scene Type", selection: $searchFilters.sceneType) {
                        Text("Any").tag(nil as SceneType?)
                        ForEach(SceneType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type as SceneType?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Time of day filter
                VStack(alignment: .leading, spacing: 4) {
                    Text("Time of Day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Time of Day", selection: $searchFilters.timeOfDay) {
                        Text("Any").tag(nil as TimeOfDay?)
                        ForEach(TimeOfDay.allCases, id: \.self) { time in
                            Text(time.rawValue).tag(time as TimeOfDay?)
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
                        Text("Any").tag(nil as SceneStatus?)
                        ForEach(SceneStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status as SceneStatus?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Color filter
                VStack(alignment: .leading, spacing: 4) {
                    Text("Color")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Color", selection: $searchFilters.color) {
                        Text("Any").tag(nil as SceneColor?)
                        ForEach(SceneColor.allCases, id: \.self) { color in
                            Text(color.rawValue).tag(color as SceneColor?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            
            // View mode and sort options
            HStack {
                Text("View")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("View Mode", selection: $searchFilters.viewMode) {
                    ForEach(SceneViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Spacer()
                
                Text("Sort by")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Sort by", selection: $searchFilters.sortBy) {
                    ForEach(SceneSortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
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

// MARK: - Scene Navigation Controls
struct SceneNavigationControls: View {
    @ObservedObject var sceneDatabase: SceneDatabase
    
    var body: some View {
        HStack(spacing: 12) {
            // Navigation buttons
            HStack(spacing: 8) {
                Button(action: { sceneDatabase.goToFirstScene() }) {
                    Image(systemName: "backward.end.fill")
                }
                .disabled(sceneDatabase.currentSceneIndex == 0)
                
                Button(action: { sceneDatabase.previousScene() }) {
                    Image(systemName: "backward.fill")
                }
                .disabled(sceneDatabase.currentSceneIndex == 0)
                
                Text("\(sceneDatabase.currentSceneIndex + 1) of \(sceneDatabase.scenes.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(minWidth: 60)
                
                Button(action: { sceneDatabase.nextScene() }) {
                    Image(systemName: "forward.fill")
                }
                .disabled(sceneDatabase.currentSceneIndex >= sceneDatabase.scenes.count - 1)
                
                Button(action: { sceneDatabase.goToLastScene() }) {
                    Image(systemName: "forward.end.fill")
                }
                .disabled(sceneDatabase.currentSceneIndex >= sceneDatabase.scenes.count - 1)
            }
            .buttonStyle(.bordered)
            
            Spacer()
            
            // Quick actions
            HStack(spacing: 8) {
                Button(action: {
                    if let currentScene = sceneDatabase.getScene(by: sceneDatabase.currentSceneIndex) {
                        sceneDatabase.toggleFavoriteScene(sceneDatabase.currentSceneIndex)
                    }
                }) {
                    Image(systemName: sceneDatabase.isFavoriteScene(sceneDatabase.currentSceneIndex) ? "heart.fill" : "heart")
                        .foregroundColor(sceneDatabase.isFavoriteScene(sceneDatabase.currentSceneIndex) ? .red : .secondary)
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    if let currentScene = sceneDatabase.getScene(by: sceneDatabase.currentSceneIndex) {
                        let bookmark = SceneBookmark(
                            sceneIndex: sceneDatabase.currentSceneIndex,
                            name: currentScene.heading,
                            description: "Bookmark for \(currentScene.heading)"
                        )
                        sceneDatabase.addBookmark(bookmark)
                    }
                }) {
                    Image(systemName: "bookmark")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Scene Content View
struct SceneContentView: View {
    let scenes: [Scene]
    @Binding var selectedScene: Scene?
    let currentSceneIndex: Int
    let viewMode: SceneViewMode
    let onSceneSelect: (Scene) -> Void
    let onSceneDelete: (Scene) -> Void
    
    var body: some View {
        Group {
            switch viewMode {
            case .cards:
                SceneCardsView(
                    scenes: scenes,
                    selectedScene: $selectedScene,
                    currentSceneIndex: currentSceneIndex,
                    onSceneSelect: onSceneSelect,
                    onSceneDelete: onSceneDelete
                )
            case .list:
                SceneListView(
                    scenes: scenes,
                    selectedScene: $selectedScene,
                    currentSceneIndex: currentSceneIndex,
                    onSceneSelect: onSceneSelect,
                    onSceneDelete: onSceneDelete
                )
            case .timeline:
                SceneTimelineView(
                    scenes: scenes,
                    selectedScene: $selectedScene,
                    currentSceneIndex: currentSceneIndex,
                    onSceneSelect: onSceneSelect,
                    onSceneDelete: onSceneDelete
                )
            case .grid:
                SceneGridView(
                    scenes: scenes,
                    selectedScene: $selectedScene,
                    currentSceneIndex: currentSceneIndex,
                    onSceneSelect: onSceneSelect,
                    onSceneDelete: onSceneDelete
                )
            }
        }
    }
}

// MARK: - Scene Cards View
struct SceneCardsView: View {
    let scenes: [Scene]
    @Binding var selectedScene: Scene?
    let currentSceneIndex: Int
    let onSceneSelect: (Scene) -> Void
    let onSceneDelete: (Scene) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(scenes.enumerated()), id: \.element.id) { index, scene in
                    SceneCardView(
                        scene: scene,
                        isCurrentScene: index == currentSceneIndex,
                        onSelect: { onSceneSelect(scene) },
                        onDelete: { onSceneDelete(scene) }
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Scene Card View
struct SceneCardView: View {
    let scene: Scene
    let isCurrentScene: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Scene header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(scene.heading)
                        .font(.headline)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Text(scene.location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(scene.timeOfDay.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Scene \(scene.sceneNumber ?? 0)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    SceneStatusBadge(status: scene.status)
                }
            }
            
            // Scene content preview
            if !scene.content.isEmpty {
                Text(scene.content)
                    .font(.body)
                    .lineLimit(3)
                    .foregroundColor(.secondary)
            }
            
            // Scene metadata
            HStack {
                HStack(spacing: 12) {
                    Label("\(scene.wordCount)", systemImage: "text.word.spacing")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(scene.dialogueCount)", systemImage: "message")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(scene.characters.count)", systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if scene.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                if scene.isImportant {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
            
            // Scene tags
            if !scene.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(scene.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(scene.color.color.opacity(0.2))
                                .foregroundColor(scene.color.color)
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrentScene ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            onSelect()
        }
        .contextMenu {
            Button("Edit Scene") {
                onSelect()
            }
            Button("Delete Scene", role: .destructive) {
                onDelete()
            }
        }
    }
}

// MARK: - Scene List View
struct SceneListView: View {
    let scenes: [Scene]
    @Binding var selectedScene: Scene?
    let currentSceneIndex: Int
    let onSceneSelect: (Scene) -> Void
    let onSceneDelete: (Scene) -> Void
    
    var body: some View {
        List {
            ForEach(Array(scenes.enumerated()), id: \.element.id) { index, scene in
                SceneRowView(
                    scene: scene,
                    isCurrentScene: index == currentSceneIndex,
                    onSelect: { onSceneSelect(scene) }
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    onSceneSelect(scene)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("Delete", role: .destructive) {
                        onSceneDelete(scene)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Scene Row View
struct SceneRowView: View {
    let scene: Scene
    let isCurrentScene: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Scene number
            VStack {
                Text("\(scene.sceneNumber ?? 0)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                
                if isCurrentScene {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(scene.heading)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    SceneStatusBadge(status: scene.status)
                }
                
                HStack {
                    Text(scene.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(scene.timeOfDay.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text("\(scene.wordCount) words")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if scene.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Scene Timeline View
struct SceneTimelineView: View {
    let scenes: [Scene]
    @Binding var selectedScene: Scene?
    let currentSceneIndex: Int
    let onSceneSelect: (Scene) -> Void
    let onSceneDelete: (Scene) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(scenes.enumerated()), id: \.element.id) { index, scene in
                    SceneTimelineItemView(
                        scene: scene,
                        isCurrentScene: index == currentSceneIndex,
                        isLast: index == scenes.count - 1,
                        onSelect: { onSceneSelect(scene) }
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Scene Timeline Item View
struct SceneTimelineItemView: View {
    let scene: Scene
    let isCurrentScene: Bool
    let isLast: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Timeline line and dot
            VStack(spacing: 0) {
                Circle()
                    .fill(isCurrentScene ? Color.accentColor : scene.color.color)
                    .frame(width: 12, height: 12)
                
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2)
                        .frame(height: 60)
                }
            }
            .frame(width: 20)
            
            // Scene content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(scene.heading)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("Scene \(scene.sceneNumber ?? 0)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(scene.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !scene.content.isEmpty {
                    Text(scene.content)
                        .font(.caption)
                        .lineLimit(2)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(scene.timeOfDay.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(scene.wordCount) words")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isCurrentScene ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .onTapGesture {
                onSelect()
            }
        }
    }
}

// MARK: - Scene Grid View
struct SceneGridView: View {
    let scenes: [Scene]
    @Binding var selectedScene: Scene?
    let currentSceneIndex: Int
    let onSceneSelect: (Scene) -> Void
    let onSceneDelete: (Scene) -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(Array(scenes.enumerated()), id: \.element.id) { index, scene in
                    SceneGridItemView(
                        scene: scene,
                        isCurrentScene: index == currentSceneIndex,
                        onSelect: { onSceneSelect(scene) }
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Scene Grid Item View
struct SceneGridItemView: View {
    let scene: Scene
    let isCurrentScene: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Scene header
            Text(scene.heading)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Scene metadata
            VStack(alignment: .leading, spacing: 4) {
                Text(scene.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(scene.timeOfDay.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(scene.wordCount) words")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Scene status
            HStack {
                SceneStatusBadge(status: scene.status)
                
                Spacer()
                
                Text("Scene \(scene.sceneNumber ?? 0)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(height: 120)
        .background(scene.color.color.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isCurrentScene ? Color.accentColor : scene.color.color.opacity(0.3), lineWidth: 2)
        )
        .onTapGesture {
            onSelect()
        }
    }
}

// MARK: - Helper Views
struct SceneStatusBadge: View {
    let status: SceneStatus
    
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
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(4)
    }
} 