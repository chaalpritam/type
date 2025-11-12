import SwiftUI

// MARK: - Scene Detail View
struct SceneDetailView: View {
    let scene: Scene
    @ObservedObject var sceneDatabase: SceneDatabase
    @State private var showEditView = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Scene header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(scene.heading)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Scene \(scene.sceneNumber ?? 0)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        SceneStatusBadge(status: scene.status)
                    }
                    .modalSectionStyle()
                    
                    // Scene info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label(scene.location, systemImage: "mappin.and.ellipse")
                            Label(scene.timeOfDay.rawValue, systemImage: "clock")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        HStack(spacing: 16) {
                            Label("\(scene.wordCount)", systemImage: "text.word.spacing")
                            Label("\(scene.dialogueCount)", systemImage: "message")
                            Label("\(scene.characters.count)", systemImage: "person.2")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .modalSectionStyle()
                    
                    // Scene content
                    if !scene.content.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Content")
                                .font(.headline)
                            Text(scene.content)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .modalSectionStyle()
                    }
                    
                    // Scene notes
                    if !scene.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                            ForEach(scene.notes) { note in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(note.title)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(note.content)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .modalSectionStyle(cornerRadius: 8, padding: 12)
                            }
                        }
                        .modalSectionStyle()
                    }
                    
                    // Scene tags
                    if !scene.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.headline)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], spacing: 8) {
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
                        .modalSectionStyle()
                    }
                }
                .modalContainer()
            }
            .navigationTitle("Scene Detail")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") { showEditView.toggle() }
                }
            }
            .sheet(isPresented: $showEditView) {
                SceneEditView(scene: scene, sceneDatabase: sceneDatabase, isNewScene: false)
            }
        }
    }
}

// MARK: - Scene Edit View
struct SceneEditView: View {
    @State var scene: Scene
    @ObservedObject var sceneDatabase: SceneDatabase
    let isNewScene: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var heading: String
    @State private var location: String
    @State private var timeOfDay: TimeOfDay
    @State private var sceneType: SceneType
    @State private var status: SceneStatus
    @State private var color: SceneColor
    @State private var isCompleted: Bool
    @State private var isImportant: Bool
    @State private var content: String
    @State private var tags: String
    
    init(scene: Scene, sceneDatabase: SceneDatabase, isNewScene: Bool) {
        self._scene = State(initialValue: scene)
        self.sceneDatabase = sceneDatabase
        self.isNewScene = isNewScene
        self._heading = State(initialValue: scene.heading)
        self._location = State(initialValue: scene.location)
        self._timeOfDay = State(initialValue: scene.timeOfDay)
        self._sceneType = State(initialValue: scene.sceneType)
        self._status = State(initialValue: scene.status)
        self._color = State(initialValue: scene.color)
        self._isCompleted = State(initialValue: scene.isCompleted)
        self._isImportant = State(initialValue: scene.isImportant)
        self._content = State(initialValue: scene.content)
        self._tags = State(initialValue: scene.tags.joined(separator: ", "))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Scene Info") {
                    TextField("Heading", text: $heading)
                    TextField("Location", text: $location)
                    Picker("Time of Day", selection: $timeOfDay) {
                        ForEach(TimeOfDay.allCases, id: \.self) { time in
                            Text(time.rawValue).tag(time)
                        }
                    }
                    Picker("Type", selection: $sceneType) {
                        ForEach(SceneType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    Picker("Status", selection: $status) {
                        ForEach(SceneStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    Picker("Color", selection: $color) {
                        ForEach(SceneColor.allCases, id: \.self) { color in
                            Text(color.rawValue).tag(color)
                        }
                    }
                    Toggle("Completed", isOn: $isCompleted)
                    Toggle("Important", isOn: $isImportant)
                }
                Section("Content") {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                }
                Section("Tags") {
                    TextField("Comma separated tags", text: $tags)
                }
            }
            .navigationTitle(isNewScene ? "New Scene" : "Edit Scene")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") { saveScene() }
                        .disabled(heading.isEmpty)
                }
            }
        }
    }
    
    private func saveScene() {
        var updatedScene = scene
        updatedScene.heading = heading
        updatedScene.location = location
        updatedScene.timeOfDay = timeOfDay
        updatedScene.sceneType = sceneType
        updatedScene.status = status
        updatedScene.color = color
        updatedScene.isCompleted = isCompleted
        updatedScene.isImportant = isImportant
        updatedScene.content = content
        updatedScene.tags = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        updatedScene.updatedAt = Date()
        if isNewScene {
            sceneDatabase.addScene(updatedScene)
        } else {
            sceneDatabase.updateScene(updatedScene)
        }
        dismiss()
    }
}

// MARK: - Scene Statistics View
struct SceneStatisticsView: View {
    let statistics: SceneStatistics
    
    var body: some View {
        NavigationView {
            List {
                Section("Overview") {
                    HStack {
                        Label("Total Scenes", systemImage: "film")
                        Spacer()
                        Text("\(statistics.totalScenes)")
                    }
                    HStack {
                        Label("Completed", systemImage: "checkmark.circle")
                        Spacer()
                        Text("\(statistics.completedScenes)")
                    }
                    HStack {
                        Label("Total Words", systemImage: "text.word.spacing")
                        Spacer()
                        Text("\(statistics.totalWordCount)")
                    }
                    HStack {
                        Label("Avg Scene Length", systemImage: "text.alignleft")
                        Spacer()
                        Text(String(format: "%.1f", statistics.averageSceneLength))
                    }
                }
                Section("By Status") {
                    ForEach(SceneStatus.allCases, id: \.self) { status in
                        HStack {
                            Text(status.rawValue)
                            Spacer()
                            Text("\(statistics.scenesByStatus[status] ?? 0)")
                        }
                    }
                }
                Section("By Type") {
                    ForEach(SceneType.allCases, id: \.self) { type in
                        HStack {
                            Text(type.rawValue)
                            Spacer()
                            Text("\(statistics.scenesByType[type] ?? 0)")
                        }
                    }
                }
                Section("By Time of Day") {
                    ForEach(TimeOfDay.allCases, id: \.self) { time in
                        HStack {
                            Text(time.rawValue)
                            Spacer()
                            Text("\(statistics.scenesByTimeOfDay[time] ?? 0)")
                        }
                    }
                }
                Section("By Color") {
                    ForEach(SceneColor.allCases, id: \.self) { color in
                        HStack {
                            Text(color.rawValue)
                            Spacer()
                            Text("\(statistics.scenesByColor[color] ?? 0)")
                        }
                    }
                }
            }
            .navigationTitle("Scene Statistics")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { }
                }
            }
        }
    }
}

// MARK: - Scene Bookmarks View
struct SceneBookmarksView: View {
    @ObservedObject var sceneDatabase: SceneDatabase
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sceneDatabase.bookmarks) { bookmark in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(bookmark.name)
                                .font(.headline)
                            Text(bookmark.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(bookmark.createdAt, style: .date)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        sceneDatabase.goToBookmark(bookmark)
                        dismiss()
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let bookmark = sceneDatabase.bookmarks[index]
                        sceneDatabase.deleteBookmark(bookmark)
                    }
                }
            }
            .navigationTitle("Bookmarks")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Scene Stat Card
struct SceneStatCard: View {
    var title: String
    var value: String
    var icon: String
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
            Text(title)
                .font(.caption)
            Text(value)
                .font(.headline)
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
} 
