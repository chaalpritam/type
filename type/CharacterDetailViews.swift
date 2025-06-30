import SwiftUI

// MARK: - Character Detail View
struct CharacterDetailView: View {
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @State private var showEditView = false
    @State private var showAddArc = false
    @State private var showAddRelationship = false
    @State private var showAddNote = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Character header
                    CharacterHeaderView(character: character)
                    
                    // Character information
                    CharacterInfoSection(character: character)
                    
                    // Character arcs
                    CharacterArcsSection(
                        character: character,
                        characterDatabase: characterDatabase,
                        showAddArc: $showAddArc
                    )
                    
                    // Character relationships
                    CharacterRelationshipsSection(
                        character: character,
                        characterDatabase: characterDatabase,
                        showAddRelationship: $showAddRelationship
                    )
                    
                    // Character notes
                    CharacterNotesSection(
                        character: character,
                        characterDatabase: characterDatabase,
                        showAddNote: $showAddNote
                    )
                    
                    // Character statistics
                    CharacterStatsSection(character: character)
                }
                .padding()
            }
            .navigationTitle(character.name)
            
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
                CharacterEditView(
                    character: character,
                    characterDatabase: characterDatabase,
                    isNewCharacter: false
                )
            }
            .sheet(isPresented: $showAddArc) {
                CharacterArcEditView(
                    arc: CharacterArc(name: ""),
                    character: character,
                    characterDatabase: characterDatabase,
                    isNewArc: true
                )
            }
            .sheet(isPresented: $showAddRelationship) {
                CharacterRelationshipEditView(
                    relationship: CharacterRelationship(targetCharacter: ""),
                    character: character,
                    characterDatabase: characterDatabase,
                    isNewRelationship: true
                )
            }
            .sheet(isPresented: $showAddNote) {
                CharacterNoteEditView(
                    note: CharacterNote(title: "", content: ""),
                    character: character,
                    characterDatabase: characterDatabase,
                    isNewNote: true
                )
            }
        }
    }
}

// MARK: - Character Header View
struct CharacterHeaderView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            // Character avatar
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(String(character.name.prefix(1)).uppercased())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                )
            
            VStack(spacing: 8) {
                Text(character.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                if let occupation = character.occupation {
                    Text(occupation)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                if let age = character.age {
                    Text("Age: \(age)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Quick stats
            HStack(spacing: 20) {
                VStack {
                    Text("\(character.dialogueCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Dialogue")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(character.sceneCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Scenes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(character.arcs.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Arcs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

// MARK: - Character Info Section
struct CharacterInfoSection: View {
    let character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Character Information", icon: "person.fill")
            
            VStack(spacing: 12) {
                if !character.description.isEmpty {
                    InfoRow(title: "Description", value: character.description)
                }
                
                if let appearance = character.appearance {
                    InfoRow(title: "Appearance", value: appearance)
                }
                
                if let personality = character.personality {
                    InfoRow(title: "Personality", value: personality)
                }
                
                if let background = character.background {
                    InfoRow(title: "Background", value: background)
                }
                
                if !character.goals.isEmpty {
                    InfoRow(title: "Goals", value: character.goals.joined(separator: ", "))
                }
                
                if !character.conflicts.isEmpty {
                    InfoRow(title: "Conflicts", value: character.conflicts.joined(separator: ", "))
                }
                
                if !character.tags.isEmpty {
                    InfoRow(title: "Tags", value: character.tags.joined(separator: ", "))
                }
            }
        }
    }
}

// MARK: - Character Arcs Section
struct CharacterArcsSection: View {
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @Binding var showAddArc: Bool
    @State private var selectedArc: CharacterArc?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SectionHeader(title: "Character Arcs", icon: "chart.line.uptrend.xyaxis")
                Spacer()
                Button("Add Arc") {
                    showAddArc.toggle()
                }
                .buttonStyle(.bordered)
            }
            
            if character.arcs.isEmpty {
                Text("No character arcs defined yet.")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(character.arcs) { arc in
                        CharacterArcRowView(arc: arc)
                            .onTapGesture {
                                selectedArc = arc
                            }
                    }
                }
            }
        }
        .sheet(item: $selectedArc) { arc in
            CharacterArcDetailView(
                arc: arc,
                character: character,
                characterDatabase: characterDatabase
            )
        }
    }
}

// MARK: - Character Arc Row View
struct CharacterArcRowView: View {
    let arc: CharacterArc
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(arc.name)
                    .font(.headline)
                
                Spacer()
                
                StatusBadge(status: arc.status)
            }
            
            if !arc.description.isEmpty {
                Text(arc.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Text(arc.arcType.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
                
                Text("\(arc.milestones.count) milestones")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(arc.updatedAt, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Character Relationships Section
struct CharacterRelationshipsSection: View {
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @Binding var showAddRelationship: Bool
    @State private var selectedRelationship: CharacterRelationship?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SectionHeader(title: "Relationships", icon: "person.2.fill")
                Spacer()
                Button("Add Relationship") {
                    showAddRelationship.toggle()
                }
                .buttonStyle(.bordered)
            }
            
            if character.relationships.isEmpty {
                Text("No relationships defined yet.")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(character.relationships) { relationship in
                        CharacterRelationshipRowView(relationship: relationship)
                            .onTapGesture {
                                selectedRelationship = relationship
                            }
                    }
                }
            }
        }
        .sheet(item: $selectedRelationship) { relationship in
            CharacterRelationshipDetailView(
                relationship: relationship,
                character: character,
                characterDatabase: characterDatabase
            )
        }
    }
}

// MARK: - Character Relationship Row View
struct CharacterRelationshipRowView: View {
    let relationship: CharacterRelationship
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(relationship.targetCharacter)
                    .font(.headline)
                
                Spacer()
                
                Text(relationship.relationshipType.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(4)
            }
            
            if !relationship.description.isEmpty {
                Text(relationship.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Text(relationship.strength.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(relationship.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Character Notes Section
struct CharacterNotesSection: View {
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @Binding var showAddNote: Bool
    @State private var selectedNote: CharacterNote?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SectionHeader(title: "Notes", icon: "note.text")
                Spacer()
                Button("Add Note") {
                    showAddNote.toggle()
                }
                .buttonStyle(.bordered)
            }
            
            if character.notes.isEmpty {
                Text("No notes yet.")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(character.notes) { note in
                        CharacterNoteRowView(note: note)
                            .onTapGesture {
                                selectedNote = note
                            }
                    }
                }
            }
        }
        .sheet(item: $selectedNote) { note in
            CharacterNoteDetailView(
                note: note,
                character: character,
                characterDatabase: characterDatabase
            )
        }
    }
}

// MARK: - Character Note Row View
struct CharacterNoteRowView: View {
    let note: CharacterNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.title)
                    .font(.headline)
                
                Spacer()
                
                Text(note.type.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(4)
            }
            
            Text(note.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                if let scene = note.scene {
                    Text("Scene: \(scene)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(note.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Character Stats Section
struct CharacterStatsSection: View {
    let character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Statistics", icon: "chart.bar.fill")
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                CharacterStatCard(title: "First Appearance", value: character.firstAppearance?.description ?? "N/A", icon: "play.fill")
                CharacterStatCard(title: "Last Appearance", value: character.lastAppearance?.description ?? "N/A", icon: "stop.fill")
                CharacterStatCard(title: "Total Dialogue", value: "\(character.dialogueCount)", icon: "message.fill")
                CharacterStatCard(title: "Total Scenes", value: "\(character.sceneCount)", icon: "film.fill")
            }
        }
    }
}

// MARK: - Helper Views
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.headline)
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(value)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct StatusBadge: View {
    let status: ArcStatus
    
    var statusColor: Color {
        switch status {
        case .planned: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        case .abandoned: return .red
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