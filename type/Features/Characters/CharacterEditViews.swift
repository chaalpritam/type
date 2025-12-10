import SwiftUI

// MARK: - Character Edit View
struct CharacterEditView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State var character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    let isNewCharacter: Bool
    
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
        VStack(spacing: 0) {
            // Header
            ModalHeader(
                title: isNewCharacter ? "New Character" : "Edit Character",
                onCancel: { dismiss() },
                onSave: saveCharacter,
                canSave: !name.isEmpty
            )
            
            // Content
            ScrollView {
                VStack(spacing: TypeSpacing.xl) {
                    // Basic Info
                    ModalSection(title: "Basic Information") {
                        VStack(spacing: TypeSpacing.md) {
                            ModalTextField(label: "Name", placeholder: "Character name", text: $name)
                            ModalTextArea(label: "Description", placeholder: "Brief character description", text: $description)
                            
                            HStack(spacing: TypeSpacing.md) {
                                ModalTextField(label: "Age", placeholder: "Age", text: $age)
                                    .frame(width: 80)
                                ModalTextField(label: "Occupation", placeholder: "Job or role", text: $occupation)
                                ModalDropdown(label: "Gender", selection: $gender, options: Gender.allCases)
                            }
                        }
                    }
                    
                    // Character Details
                    ModalSection(title: "Details") {
                        VStack(spacing: TypeSpacing.md) {
                            ModalTextArea(label: "Appearance", placeholder: "Physical description", text: $appearance)
                            ModalTextArea(label: "Personality", placeholder: "Personality traits", text: $personality)
                            ModalTextArea(label: "Background", placeholder: "Character history", text: $background)
                        }
                    }
                    
                    // Goals
                    ModalSection(title: "Goals") {
                        ModalTagList(items: $goals, newItem: $newGoal, placeholder: "Add a goal", color: TypeColors.sceneGreen)
                    }
                    
                    // Conflicts
                    ModalSection(title: "Conflicts") {
                        ModalTagList(items: $conflicts, newItem: $newConflict, placeholder: "Add a conflict", color: TypeColors.sceneRed)
                    }
                    
                    // Tags
                    ModalSection(title: "Tags") {
                        ModalTagList(items: $tags, newItem: $newTag, placeholder: "Add a tag", color: TypeColors.accent)
                    }
                }
                .padding(TypeSpacing.xl)
            }
        }
        .frame(minWidth: 520, idealWidth: 580, minHeight: 600, idealHeight: 700)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
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
}

// MARK: - Modal Header
struct ModalHeader: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let onCancel: () -> Void
    let onSave: () -> Void
    var canSave: Bool = true
    
    var body: some View {
        HStack {
            Button("Cancel") { onCancel() }
                .font(TypeTypography.body)
                .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                .buttonStyle(.plain)
            
            Spacer()
            
            Text(title)
                .font(TypeTypography.headline)
                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
            
            Spacer()
            
            Button("Save") { onSave() }
                .font(TypeTypography.body)
                .fontWeight(.medium)
                .foregroundColor(canSave ? TypeColors.accent : (colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight))
                .buttonStyle(.plain)
                .disabled(!canSave)
        }
        .padding(.horizontal, TypeSpacing.lg)
        .frame(height: 48)
        .background(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight),
            alignment: .bottom
        )
    }
}

// MARK: - Modal Section
struct ModalSection<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.md) {
            Text(title.uppercased())
                .font(TypeTypography.caption)
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                .tracking(0.8)
            
            content
        }
    }
}

// MARK: - Modal Text Field
struct ModalTextField: View {
    @Environment(\.colorScheme) var colorScheme
    let label: String
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
            if !label.isEmpty {
                Text(label)
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
            }
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(TypeTypography.body)
                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                .padding(.horizontal, TypeSpacing.sm)
                .padding(.vertical, TypeSpacing.sm)
                .focused($isFocused)
                .background(
                    RoundedRectangle(cornerRadius: TypeRadius.sm)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: TypeRadius.sm)
                        .stroke(isFocused ? TypeColors.accent.opacity(0.5) : (colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight), lineWidth: isFocused ? 1.5 : 0.5)
                )
                .animation(TypeAnimation.quick, value: isFocused)
        }
    }
}

// MARK: - Modal Text Area
struct ModalTextArea: View {
    @Environment(\.colorScheme) var colorScheme
    let label: String
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
            if !label.isEmpty {
                Text(label)
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
            }
            
            TextEditor(text: $text)
                .font(TypeTypography.body)
                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                .scrollContentBackground(.hidden)
                .padding(TypeSpacing.sm)
                .frame(minHeight: 60, maxHeight: 100)
                .focused($isFocused)
                .background(
                    RoundedRectangle(cornerRadius: TypeRadius.sm)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: TypeRadius.sm)
                        .stroke(isFocused ? TypeColors.accent.opacity(0.5) : (colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight), lineWidth: isFocused ? 1.5 : 0.5)
                )
                .overlay(
                    Group {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(TypeTypography.body)
                                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                                .padding(.horizontal, TypeSpacing.sm)
                                .padding(.vertical, TypeSpacing.sm + 4)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
                .animation(TypeAnimation.quick, value: isFocused)
        }
    }
}

// MARK: - Modal Dropdown
struct ModalDropdown<T: CaseIterable & Hashable & RawRepresentable>: View where T.RawValue == String {
    @Environment(\.colorScheme) var colorScheme
    let label: String
    @Binding var selection: T?
    let options: [T]
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
            Text(label)
                .font(TypeTypography.caption)
                .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
            
            Menu {
                Button("None") { selection = nil }
                Divider()
                ForEach(options, id: \.self) { option in
                    Button(option.rawValue) { selection = option }
                }
            } label: {
                HStack {
                    Text(selection?.rawValue ?? "Select")
                        .font(TypeTypography.body)
                        .foregroundColor(selection == nil ?
                                         (colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight) :
                                         (colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                }
                .padding(.horizontal, TypeSpacing.sm)
                .padding(.vertical, TypeSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: TypeRadius.sm)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: TypeRadius.sm)
                        .stroke(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight, lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Modal Tag List
struct ModalTagList: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var items: [String]
    @Binding var newItem: String
    let placeholder: String
    let color: Color
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.sm) {
            // Tags
            if !items.isEmpty {
                FlowLayout(spacing: TypeSpacing.xs) {
                    ForEach(items, id: \.self) { item in
                        HStack(spacing: 4) {
                            Text(item)
                                .font(TypeTypography.caption)
                            
                            Button(action: { removeItem(item) }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 8, weight: .bold))
                            }
                            .buttonStyle(.plain)
                        }
                        .foregroundColor(color)
                        .padding(.horizontal, TypeSpacing.sm)
                        .padding(.vertical, TypeSpacing.xs)
                        .background(color.opacity(0.1))
                        .cornerRadius(TypeRadius.full)
                    }
                }
            }
            
            // Add new
            HStack(spacing: TypeSpacing.sm) {
                TextField(placeholder, text: $newItem)
                    .textFieldStyle(.plain)
                    .font(TypeTypography.body)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    .focused($isFocused)
                    .onSubmit { addItem() }
                
                Button(action: addItem) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(newItem.isEmpty ? (colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight) : color)
                }
                .buttonStyle(.plain)
                .disabled(newItem.isEmpty)
            }
            .padding(.horizontal, TypeSpacing.sm)
            .padding(.vertical, TypeSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: TypeRadius.sm)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: TypeRadius.sm)
                    .stroke(isFocused ? color.opacity(0.5) : (colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight), lineWidth: isFocused ? 1.5 : 0.5)
            )
        }
    }
    
    private func addItem() {
        guard !newItem.isEmpty else { return }
        items.append(newItem)
        newItem = ""
    }
    
    private func removeItem(_ item: String) {
        items.removeAll { $0 == item }
    }
}

// MARK: - Character Arc Edit View
struct CharacterArcEditView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State var arc: CharacterArc
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    let isNewArc: Bool
    
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
        VStack(spacing: 0) {
            ModalHeader(
                title: isNewArc ? "New Arc" : "Edit Arc",
                onCancel: { dismiss() },
                onSave: saveArc,
                canSave: !name.isEmpty
            )
            
            ScrollView {
                VStack(spacing: TypeSpacing.xl) {
                    ModalSection(title: "Arc Information") {
                        VStack(spacing: TypeSpacing.md) {
                            ModalTextField(label: "Name", placeholder: "Arc name", text: $name)
                            ModalTextArea(label: "Description", placeholder: "What happens in this arc", text: $description)
                            
                            HStack(spacing: TypeSpacing.md) {
                                ModalEnumDropdown(label: "Type", selection: $arcType)
                                ModalEnumDropdown(label: "Status", selection: $status)
                            }
                        }
                    }
                    
                    ModalSection(title: "Scene References") {
                        HStack(spacing: TypeSpacing.md) {
                            ModalTextField(label: "Start Scene", placeholder: "Scene name", text: $startScene)
                            ModalTextField(label: "End Scene", placeholder: "Scene name", text: $endScene)
                        }
                    }
                    
                    ModalSection(title: "Notes") {
                        ModalTextArea(label: "", placeholder: "Additional notes", text: $notes)
                    }
                }
                .padding(TypeSpacing.xl)
            }
        }
        .frame(minWidth: 480, idealWidth: 520, minHeight: 500, idealHeight: 550)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
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

// MARK: - Modal Enum Dropdown
struct ModalEnumDropdown<T: CaseIterable & Hashable & RawRepresentable>: View where T.RawValue == String {
    @Environment(\.colorScheme) var colorScheme
    let label: String
    @Binding var selection: T
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
            Text(label)
                .font(TypeTypography.caption)
                .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
            
            Menu {
                ForEach(Array(T.allCases), id: \.self) { option in
                    Button(option.rawValue) { selection = option }
                }
            } label: {
                HStack {
                    Text(selection.rawValue)
                        .font(TypeTypography.body)
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                }
                .padding(.horizontal, TypeSpacing.sm)
                .padding(.vertical, TypeSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: TypeRadius.sm)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: TypeRadius.sm)
                        .stroke(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight, lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Character Relationship Edit View
struct CharacterRelationshipEditView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State var relationship: CharacterRelationship
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    let isNewRelationship: Bool
    
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
        VStack(spacing: 0) {
            ModalHeader(
                title: isNewRelationship ? "New Relationship" : "Edit Relationship",
                onCancel: { dismiss() },
                onSave: saveRelationship,
                canSave: !targetCharacter.isEmpty
            )
            
            ScrollView {
                VStack(spacing: TypeSpacing.xl) {
                    ModalSection(title: "Relationship") {
                        VStack(spacing: TypeSpacing.md) {
                            ModalTextField(label: "Character", placeholder: "Related character name", text: $targetCharacter)
                            
                            HStack(spacing: TypeSpacing.md) {
                                ModalEnumDropdown(label: "Type", selection: $relationshipType)
                                ModalEnumDropdown(label: "Strength", selection: $strength)
                            }
                            
                            ModalTextArea(label: "Description", placeholder: "Describe the relationship", text: $description)
                        }
                    }
                    
                    ModalSection(title: "Notes") {
                        ModalTextArea(label: "", placeholder: "Additional notes", text: $notes)
                    }
                }
                .padding(TypeSpacing.xl)
            }
        }
        .frame(minWidth: 450, idealWidth: 500, minHeight: 450, idealHeight: 500)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
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
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State var note: CharacterNote
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    let isNewNote: Bool
    
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
        VStack(spacing: 0) {
            ModalHeader(
                title: isNewNote ? "New Note" : "Edit Note",
                onCancel: { dismiss() },
                onSave: saveNote,
                canSave: !title.isEmpty && !content.isEmpty
            )
            
            ScrollView {
                VStack(spacing: TypeSpacing.xl) {
                    ModalSection(title: "Note") {
                        VStack(spacing: TypeSpacing.md) {
                            HStack(spacing: TypeSpacing.md) {
                                ModalTextField(label: "Title", placeholder: "Note title", text: $title)
                                ModalEnumDropdown(label: "Type", selection: $type)
                                    .frame(width: 140)
                            }
                        }
                    }
                    
                    ModalSection(title: "Content") {
                        ModalTextArea(label: "", placeholder: "Write your note here...", text: $content)
                    }
                    
                    ModalSection(title: "Reference (Optional)") {
                        HStack(spacing: TypeSpacing.md) {
                            ModalTextField(label: "Scene", placeholder: "Related scene", text: $scene)
                            ModalTextField(label: "Line", placeholder: "Line #", text: $lineNumber)
                                .frame(width: 80)
                        }
                    }
                }
                .padding(TypeSpacing.xl)
            }
        }
        .frame(minWidth: 450, idealWidth: 500, minHeight: 450, idealHeight: 500)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
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
