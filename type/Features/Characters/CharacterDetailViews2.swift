import SwiftUI

// MARK: - Character Arc Detail View
struct CharacterArcDetailView: View {
    let arc: CharacterArc
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @State private var showEditView = false
    @State private var showAddMilestone = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            )
                        
                        VStack(spacing: 8) {
                            Text(arc.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(arc.arcType.rawValue)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            StatusBadge(status: arc.status)
                        }
                        
                        if !arc.description.isEmpty {
                            Text(arc.description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .modalSectionStyle()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Arc Information", icon: "info.circle")
                        
                        VStack(spacing: 12) {
                            if let startScene = arc.startScene {
                                InfoRow(title: "Start Scene", value: startScene)
                            }
                            
                            if let endScene = arc.endScene {
                                InfoRow(title: "End Scene", value: endScene)
                            }
                            
                            InfoRow(title: "Milestones", value: "\(arc.milestones.count)")
                            
                            InfoRow(title: "Created", value: arc.createdAt.formatted(date: .abbreviated, time: .omitted))
                            
                            InfoRow(title: "Updated", value: arc.updatedAt.formatted(date: .abbreviated, time: .omitted))
                        }
                        
                        if !arc.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.headline)
                                
                                Text(arc.notes)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .modalSectionStyle()
                }
                .modalContainer()
            }
            .navigationTitle(arc.name)
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        showEditView.toggle()
                    }
                }
            }
            .sheet(isPresented: $showEditView) {
                CharacterArcEditView(
                    arc: arc,
                    character: character,
                    characterDatabase: characterDatabase,
                    isNewArc: false
                )
            }
            .sheet(isPresented: $showAddMilestone) {
                ArcMilestoneEditView(
                    milestone: ArcMilestone(name: ""),
                    arc: arc,
                    character: character,
                    characterDatabase: characterDatabase,
                    isNewMilestone: true
                )
            }
        }
    }
}

// MARK: - Arc Header View
struct ArcHeaderView: View {
    let arc: CharacterArc
    
    var body: some View {
        VStack(spacing: 16) {
            // Arc icon
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title)
                        .foregroundColor(.blue)
                )
            
            VStack(spacing: 8) {
                Text(arc.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(arc.arcType.rawValue)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                StatusBadge(status: arc.status)
            }
            
            if !arc.description.isEmpty {
                Text(arc.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .modalSectionStyle()
    }
}

// MARK: - Arc Info Section
struct ArcInfoSection: View {
    let arc: CharacterArc
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Arc Information", icon: "info.circle")
            
            VStack(spacing: 12) {
                if let startScene = arc.startScene {
                    InfoRow(title: "Start Scene", value: startScene)
                }
                
                if let endScene = arc.endScene {
                    InfoRow(title: "End Scene", value: endScene)
                }
                
                InfoRow(title: "Milestones", value: "\(arc.milestones.count)")
                
                InfoRow(title: "Created", value: arc.createdAt.formatted(date: .abbreviated, time: .omitted))
                
                InfoRow(title: "Updated", value: arc.updatedAt.formatted(date: .abbreviated, time: .omitted))
            }
            
            if !arc.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.headline)
                    
                    Text(arc.notes)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Arc Milestones Section
struct ArcMilestonesSection: View {
    let arc: CharacterArc
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @Binding var showAddMilestone: Bool
    @State private var selectedMilestone: ArcMilestone?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SectionHeader(title: "Milestones", icon: "flag.fill")
                Spacer()
                Button("Add Milestone") {
                    showAddMilestone.toggle()
                }
                .buttonStyle(.bordered)
            }
            
            if arc.milestones.isEmpty {
                Text("No milestones defined yet.")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(arc.milestones) { milestone in
                        ArcMilestoneRowView(milestone: milestone)
                            .onTapGesture {
                                selectedMilestone = milestone
                            }
                    }
                }
            }
        }
        .sheet(item: $selectedMilestone) { milestone in
            ArcMilestoneDetailView(
                milestone: milestone,
                arc: arc,
                character: character,
                characterDatabase: characterDatabase
            )
        }
    }
}

// MARK: - Arc Milestone Row View
struct ArcMilestoneRowView: View {
    let milestone: ArcMilestone
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(milestone.name)
                    .font(.headline)
                
                Spacer()
                
                MilestoneStatusBadge(status: milestone.status)
            }
            
            if !milestone.description.isEmpty {
                Text(milestone.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                if let scene = milestone.scene {
                    Text("Scene: \(scene)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(milestone.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .modalSectionStyle(padding: 12)
    }
}

// MARK: - Character Relationship Detail View
struct CharacterRelationshipDetailView: View {
    let relationship: CharacterRelationship
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @State private var showEditView = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "person.2.fill")
                                    .font(.title)
                                    .foregroundColor(.green)
                            )
                        
                        VStack(spacing: 8) {
                            Text(relationship.targetCharacter)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(relationship.relationshipType.rawValue)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(relationship.strength.rawValue)
                                .font(.subheadline)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(6)
                        }
                        
                        if !relationship.description.isEmpty {
                            Text(relationship.description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .modalSectionStyle()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Relationship Information", icon: "info.circle")
                        
                        VStack(spacing: 12) {
                            InfoRow(title: "Type", value: relationship.relationshipType.rawValue)
                            InfoRow(title: "Strength", value: relationship.strength.rawValue)
                            InfoRow(title: "Created", value: relationship.createdAt.formatted(date: .abbreviated, time: .omitted))
                        }
                        
                        if !relationship.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.headline)
                                
                                Text(relationship.notes)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .modalSectionStyle()
                }
                .modalContainer()
            }
            .navigationTitle("Relationship")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        showEditView.toggle()
                    }
                }
            }
            .sheet(isPresented: $showEditView) {
                CharacterRelationshipEditView(
                    relationship: relationship,
                    character: character,
                    characterDatabase: characterDatabase,
                    isNewRelationship: false
                )
            }
        }
    }
}

// MARK: - Character Note Detail View
struct CharacterNoteDetailView: View {
    let note: CharacterNote
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @State private var showEditView = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "note.text")
                                    .font(.title)
                                    .foregroundColor(.orange)
                            )
                        
                        VStack(spacing: 8) {
                            Text(note.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(note.type.rawValue)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .modalSectionStyle()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Note Content", icon: "text.alignleft")
                        
                        Text(note.content)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            if let scene = note.scene {
                                InfoRow(title: "Scene", value: scene)
                            }
                            
                            if let lineNumber = note.lineNumber {
                                InfoRow(title: "Line Number", value: "\(lineNumber)")
                            }
                            
                            InfoRow(title: "Created", value: note.createdAt.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                    .modalSectionStyle()
                }
                .modalContainer()
            }
            .navigationTitle("Note")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        showEditView.toggle()
                    }
                }
            }
            .sheet(isPresented: $showEditView) {
                CharacterNoteEditView(
                    note: note,
                    character: character,
                    characterDatabase: characterDatabase,
                    isNewNote: false
                )
            }
        }
    }
}

// MARK: - Character Statistics View
struct CharacterStatisticsView: View {
    let statistics: CharacterStatistics
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Overview", icon: "chart.bar.fill")
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            CharacterStatCard(title: "Total Characters", value: "\(statistics.totalCharacters)", icon: "person.3.fill")
                            CharacterStatCard(title: "With Dialogue", value: "\(statistics.charactersWithDialogue)", icon: "message.fill")
                            CharacterStatCard(title: "With Arcs", value: "\(statistics.charactersWithArcs)", icon: "chart.line.uptrend.xyaxis")
                            CharacterStatCard(title: "Avg Dialogue", value: String(format: "%.1f", statistics.averageDialogueCount), icon: "text.bubble.fill")
                        }
                    }
                    .modalSectionStyle()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Gender Distribution", icon: "person.2.fill")
                        
                        VStack(spacing: 12) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                if let count = statistics.charactersByGender[gender], count > 0 {
                                    HStack {
                                        Text(gender.rawValue)
                                            .font(.body)
                                        
                                        Spacer()
                                        
                                        Text("\(count)")
                                            .font(.headline)
                                            .foregroundColor(.accentColor)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    .modalSectionStyle()
                    
                    if let mostActive = statistics.mostActiveCharacter {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Most Active Character", icon: "star.fill")
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Circle()
                                        .fill(Color.accentColor.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text(String(mostActive.name.prefix(1)).uppercased())
                                                .font(.headline)
                                                .foregroundColor(.accentColor)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(mostActive.name)
                                            .font(.headline)
                                        
                                        if let occupation = mostActive.occupation {
                                            Text(occupation)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                
                                HStack(spacing: 20) {
                                    VStack {
                                        Text("\(mostActive.dialogueCount)")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        Text("Dialogue")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack {
                                        Text("\(mostActive.sceneCount)")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        Text("Scenes")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack {
                                        Text("\(mostActive.arcs.count)")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        Text("Arcs")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .modalSectionStyle()
                        }
                        .modalSectionStyle()
                    }
                }
                .modalContainer()
            }
            .navigationTitle("Character Statistics")
            
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Helper Views
struct MilestoneStatusBadge: View {
    let status: MilestoneStatus
    
    var statusColor: Color {
        switch status {
        case .planned: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        case .skipped: return .red
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(4)
    }
}

// MARK: - Arc Milestone Edit View
struct ArcMilestoneEditView: View {
    @State var milestone: ArcMilestone
    let arc: CharacterArc
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    let isNewMilestone: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var description: String
    @State private var scene: String
    @State private var lineNumber: String
    @State private var status: MilestoneStatus
    @State private var notes: String
    
    init(milestone: ArcMilestone, arc: CharacterArc, character: Character, characterDatabase: CharacterDatabase, isNewMilestone: Bool) {
        self.milestone = milestone
        self.arc = arc
        self.character = character
        self.characterDatabase = characterDatabase
        self.isNewMilestone = isNewMilestone
        
        self._name = State(initialValue: milestone.name)
        self._description = State(initialValue: milestone.description)
        self._scene = State(initialValue: milestone.scene ?? "")
        self._lineNumber = State(initialValue: milestone.lineNumber?.description ?? "")
        self._status = State(initialValue: milestone.status)
        self._notes = State(initialValue: milestone.notes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Milestone Information") {
                    TextField("Milestone Name", text: $name)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Status", selection: $status) {
                        ForEach(MilestoneStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
                
                Section(header: Text("Reference")) {
                    TextField("Scene", text: $scene)
                    TextField("Line Number", text: $lineNumber)
                }
                
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                }
            }
            .navigationTitle(isNewMilestone ? "New Milestone" : "Edit Milestone")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        saveMilestone()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveMilestone() {
        var updatedMilestone = milestone
        updatedMilestone.name = name
        updatedMilestone.description = description
        updatedMilestone.scene = scene.isEmpty ? nil : scene
        updatedMilestone.lineNumber = Int(lineNumber)
        updatedMilestone.status = status
        updatedMilestone.notes = notes
        
        // Update the arc with the new milestone
        var updatedArc = arc
        if isNewMilestone {
            updatedArc.milestones.append(updatedMilestone)
        } else {
            if let index = updatedArc.milestones.firstIndex(where: { $0.id == milestone.id }) {
                updatedArc.milestones[index] = updatedMilestone
            }
        }
        
        characterDatabase.updateArc(for: character, arc: updatedArc)
        dismiss()
    }
}

// MARK: - Arc Milestone Detail View
struct ArcMilestoneDetailView: View {
    let milestone: ArcMilestone
    let arc: CharacterArc
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @State private var showEditView = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Milestone header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "flag.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            )
                        
                        VStack(spacing: 8) {
                            Text(milestone.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            MilestoneStatusBadge(status: milestone.status)
                        }
                        
                        if !milestone.description.isEmpty {
                            Text(milestone.description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .modalSectionStyle()
                    
                    // Milestone information
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Milestone Information", icon: "info.circle")
                        
                        VStack(spacing: 12) {
                            if let scene = milestone.scene {
                                InfoRow(title: "Scene", value: scene)
                            }
                            
                            if let lineNumber = milestone.lineNumber {
                                InfoRow(title: "Line Number", value: "\(lineNumber)")
                            }
                            
                            InfoRow(title: "Created", value: milestone.createdAt.formatted(date: .abbreviated, time: .omitted))
                        }
                        
                        if !milestone.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.headline)
                                
                                Text(milestone.notes)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .modalSectionStyle()
                }
                .modalContainer()
            }
            .navigationTitle("Milestone")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        showEditView.toggle()
                    }
                }
            }
            .sheet(isPresented: $showEditView) {
                ArcMilestoneEditView(
                    milestone: milestone,
                    arc: arc,
                    character: character,
                    characterDatabase: characterDatabase,
                    isNewMilestone: false
                )
            }
        }
    }
} 
