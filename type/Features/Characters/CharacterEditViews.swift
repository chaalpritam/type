import SwiftUI

// MARK: - Character Edit View
struct CharacterEditView: View {
    @State var character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    let isNewCharacter: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var description: String
    @State private var age: String
    @State private var gender: Gender?
    @State private var occupation: String
    @State private var appearance: String
    @State private var personality: String
    @State private var background: String
    @State private var goals: [String]
    @State private var conflicts: [String]
    @State private var tags: [String]
    @State private var newGoal: String = ""
    @State private var newConflict: String = ""
    @State private var newTag: String = ""
    
    init(character: Character, characterDatabase: CharacterDatabase, isNewCharacter: Bool) {
        self.character = character
        self.characterDatabase = characterDatabase
        self.isNewCharacter = isNewCharacter
        
        // Initialize state variables
        self._name = State(initialValue: character.name)
        self._description = State(initialValue: character.description)
        self._age = State(initialValue: character.age?.description ?? "")
        self._gender = State(initialValue: character.gender)
        self._occupation = State(initialValue: character.occupation ?? "")
        self._appearance = State(initialValue: character.appearance ?? "")
        self._personality = State(initialValue: character.personality ?? "")
        self._background = State(initialValue: character.background ?? "")
        self._goals = State(initialValue: character.goals)
        self._conflicts = State(initialValue: character.conflicts)
        self._tags = State(initialValue: character.tags)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Basic Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Basic Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            TextField("Character Name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Description", text: $description, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                            
                            HStack {
                                TextField("Age", text: $age)
                                
                                Picker("Gender", selection: $gender) {
                                    Text("Unspecified").tag(nil as Gender?)
                                    ForEach(Gender.allCases, id: \.self) { gender in
                                        Text(gender.rawValue).tag(gender as Gender?)
                                    }
                                }
                            }
                            
                            TextField("Occupation", text: $occupation)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .modalSectionStyle()
                    
                    // Character Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Character Details")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            TextField("Appearance", text: $appearance, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(2...4)
                            
                            TextField("Personality", text: $personality, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(2...4)
                            
                            TextField("Background", text: $background, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                        }
                    }
                    .modalSectionStyle()
                    
                    // Goals
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Goals")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            ForEach(goals, id: \.self) { goal in
                                Text(goal)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            .onDelete(perform: deleteGoal)
                            
                            HStack {
                                TextField("Add goal", text: $newGoal)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button("Add") {
                                    if !newGoal.isEmpty {
                                        goals.append(newGoal)
                                        newGoal = ""
                                    }
                                }
                                .disabled(newGoal.isEmpty)
                            }
                        }
                    }
                    .modalSectionStyle()
                    
                    // Conflicts
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Conflicts")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            ForEach(conflicts, id: \.self) { conflict in
                                Text(conflict)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            .onDelete(perform: deleteConflict)
                            
                            HStack {
                                TextField("Add conflict", text: $newConflict)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button("Add") {
                                    if !newConflict.isEmpty {
                                        conflicts.append(newConflict)
                                        newConflict = ""
                                    }
                                }
                                .disabled(newConflict.isEmpty)
                            }
                        }
                    }
                    .modalSectionStyle()
                    
                    // Tags
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            .onDelete(perform: deleteTag)
                            
                            HStack {
                                TextField("Add tag", text: $newTag)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button("Add") {
                                    if !newTag.isEmpty {
                                        tags.append(newTag)
                                        newTag = ""
                                    }
                                }
                                .disabled(newTag.isEmpty)
                            }
                        }
                    }
                    .modalSectionStyle()
                }
                .modalContainer()
            }
            .navigationTitle(isNewCharacter ? "New Character" : "Edit Character")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        saveCharacter()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveCharacter() {
        var updatedCharacter = character
        updatedCharacter.name = name
        updatedCharacter.description = description
        updatedCharacter.age = Int(age)
        updatedCharacter.gender = gender
        updatedCharacter.occupation = occupation.isEmpty ? nil : occupation
        updatedCharacter.appearance = appearance.isEmpty ? nil : appearance
        updatedCharacter.personality = personality.isEmpty ? nil : personality
        updatedCharacter.background = background.isEmpty ? nil : background
        updatedCharacter.goals = goals
        updatedCharacter.conflicts = conflicts
        updatedCharacter.tags = tags
        
        if isNewCharacter {
            characterDatabase.addCharacter(updatedCharacter)
        } else {
            characterDatabase.updateCharacter(updatedCharacter)
        }
        
        dismiss()
    }
    
    private func deleteGoal(offsets: IndexSet) {
        goals.remove(atOffsets: offsets)
    }
    
    private func deleteConflict(offsets: IndexSet) {
        conflicts.remove(atOffsets: offsets)
    }
    
    private func deleteTag(offsets: IndexSet) {
        tags.remove(atOffsets: offsets)
    }
}

// MARK: - Character Arc Edit View
struct CharacterArcEditView: View {
    @State var arc: CharacterArc
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    let isNewArc: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var description: String
    @State private var arcType: ArcType
    @State private var status: ArcStatus
    @State private var startScene: String
    @State private var endScene: String
    @State private var notes: String
    
    init(arc: CharacterArc, character: Character, characterDatabase: CharacterDatabase, isNewArc: Bool) {
        self.arc = arc
        self.character = character
        self.characterDatabase = characterDatabase
        self.isNewArc = isNewArc
        
        self._name = State(initialValue: arc.name)
        self._description = State(initialValue: arc.description)
        self._arcType = State(initialValue: arc.arcType)
        self._status = State(initialValue: arc.status)
        self._startScene = State(initialValue: arc.startScene ?? "")
        self._endScene = State(initialValue: arc.endScene ?? "")
        self._notes = State(initialValue: arc.notes)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Arc Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Arc Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            TextField("Arc Name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Description", text: $description, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                            
                            Picker("Arc Type", selection: $arcType) {
                                ForEach(ArcType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            
                            Picker("Status", selection: $status) {
                                ForEach(ArcStatus.allCases, id: \.self) { status in
                                    Text(status.rawValue).tag(status)
                                }
                            }
                        }
                    }
                    .modalSectionStyle()
                    
                    // Scenes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Scenes")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            TextField("Start Scene", text: $startScene)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("End Scene", text: $endScene)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .modalSectionStyle()
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Notes", text: $notes, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...8)
                    }
                    .modalSectionStyle()
                }
                .modalContainer()
            }
            .navigationTitle(isNewArc ? "New Arc" : "Edit Arc")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        saveArc()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveArc() {
        var updatedArc = arc
        updatedArc.name = name
        updatedArc.description = description
        updatedArc.arcType = arcType
        updatedArc.status = status
        updatedArc.startScene = startScene.isEmpty ? nil : startScene
        updatedArc.endScene = endScene.isEmpty ? nil : endScene
        updatedArc.notes = notes
        
        if isNewArc {
            characterDatabase.addArc(to: character, arc: updatedArc)
        } else {
            characterDatabase.updateArc(for: character, arc: updatedArc)
        }
        
        dismiss()
    }
}

// MARK: - Character Relationship Edit View
struct CharacterRelationshipEditView: View {
    @State var relationship: CharacterRelationship
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    let isNewRelationship: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var targetCharacter: String
    @State private var relationshipType: RelationshipType
    @State private var description: String
    @State private var strength: RelationshipStrength
    @State private var notes: String
    
    init(relationship: CharacterRelationship, character: Character, characterDatabase: CharacterDatabase, isNewRelationship: Bool) {
        self.relationship = relationship
        self.character = character
        self.characterDatabase = characterDatabase
        self.isNewRelationship = isNewRelationship
        
        self._targetCharacter = State(initialValue: relationship.targetCharacter)
        self._relationshipType = State(initialValue: relationship.relationshipType)
        self._description = State(initialValue: relationship.description)
        self._strength = State(initialValue: relationship.strength)
        self._notes = State(initialValue: relationship.notes)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Relationship Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Relationship Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            TextField("Target Character", text: $targetCharacter)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Picker("Relationship Type", selection: $relationshipType) {
                                ForEach(RelationshipType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            
                            TextField("Description", text: $description, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                            
                            Picker("Strength", selection: $strength) {
                                ForEach(RelationshipStrength.allCases, id: \.self) { strength in
                                    Text(strength.rawValue).tag(strength)
                                }
                            }
                        }
                    }
                    .modalSectionStyle()
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Notes", text: $notes, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...8)
                    }
                    .modalSectionStyle()
                }
                .modalContainer()
            }
            .navigationTitle(isNewRelationship ? "New Relationship" : "Edit Relationship")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        saveRelationship()
                    }
                    .disabled(targetCharacter.isEmpty)
                }
            }
        }
    }
    
    private func saveRelationship() {
        var updatedRelationship = relationship
        updatedRelationship.targetCharacter = targetCharacter
        updatedRelationship.relationshipType = relationshipType
        updatedRelationship.description = description
        updatedRelationship.strength = strength
        updatedRelationship.notes = notes
        
        if isNewRelationship {
            characterDatabase.addRelationship(to: character, relationship: updatedRelationship)
        } else {
            characterDatabase.updateRelationship(for: character, relationship: updatedRelationship)
        }
        
        dismiss()
    }
}

// MARK: - Character Note Edit View
struct CharacterNoteEditView: View {
    @State var note: CharacterNote
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    let isNewNote: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var content: String
    @State private var type: NoteType
    @State private var scene: String
    @State private var lineNumber: String
    
    init(note: CharacterNote, character: Character, characterDatabase: CharacterDatabase, isNewNote: Bool) {
        self.note = note
        self.character = character
        self.characterDatabase = characterDatabase
        self.isNewNote = isNewNote
        
        self._title = State(initialValue: note.title)
        self._content = State(initialValue: note.content)
        self._type = State(initialValue: note.type)
        self._scene = State(initialValue: note.scene ?? "")
        self._lineNumber = State(initialValue: note.lineNumber?.description ?? "")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Note Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Note Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            TextField("Title", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Picker("Type", selection: $type) {
                                ForEach(NoteType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                        }
                    }
                    .modalSectionStyle()
                    
                    // Content
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Content")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Note content", text: $content, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(5...15)
                    }
                    .modalSectionStyle()
                    
                    // Reference
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reference")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            TextField("Scene", text: $scene)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Line Number", text: $lineNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .modalSectionStyle()
                }
                .modalContainer()
            }
            .navigationTitle(isNewNote ? "New Note" : "Edit Note")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
    
    private func saveNote() {
        var updatedNote = note
        updatedNote.title = title
        updatedNote.content = content
        updatedNote.type = type
        updatedNote.scene = scene.isEmpty ? nil : scene
        updatedNote.lineNumber = Int(lineNumber)
        
        if isNewNote {
            characterDatabase.addNote(to: character, note: updatedNote)
        } else {
            characterDatabase.updateNote(for: character, note: updatedNote)
        }
        
        dismiss()
    }
} 