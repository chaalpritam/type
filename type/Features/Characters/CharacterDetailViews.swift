import SwiftUI

// MARK: - Character Detail View
struct CharacterDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @State private var showEditView = false
    @State private var showAddArc = false
    @State private var showAddRelationship = false
    @State private var showAddNote = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: TypeSpacing.lg) {
                    // Character header
                    TypeCharacterDetailHeader(character: character)
                    
                    // Character information
                    TypeCharacterInfoSection(character: character)
                    
                    // Character arcs
                    TypeCharacterArcsSection(
                        character: character,
                        characterDatabase: characterDatabase,
                        showAddArc: $showAddArc
                    )
                    
                    // Character relationships
                    TypeCharacterRelationshipsSection(
                        character: character,
                        characterDatabase: characterDatabase,
                        showAddRelationship: $showAddRelationship
                    )
                    
                    // Character notes
                    TypeCharacterNotesSection(
                        character: character,
                        characterDatabase: characterDatabase,
                        showAddNote: $showAddNote
                    )
                }
                .padding(TypeSpacing.lg)
            }
            .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
            .navigationTitle(character.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showEditView = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                            Text("Edit")
                        }
                        .font(TypeTypography.caption)
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
        .frame(minWidth: 500, minHeight: 600)
    }
}

// MARK: - Type Character Detail Header
struct TypeCharacterDetailHeader: View {
    @Environment(\.colorScheme) var colorScheme
    let character: Character
    
    var body: some View {
        VStack(spacing: TypeSpacing.lg) {
            // Avatar
            ZStack {
                Circle()
                    .fill(avatarColor.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Text(String(character.name.prefix(1)).uppercased())
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(avatarColor)
            }
            
            // Name and basic info
            VStack(spacing: TypeSpacing.xs) {
                Text(character.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                if let occupation = character.occupation {
                    Text(occupation)
                        .font(TypeTypography.subheadline)
                        .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                }
                
                HStack(spacing: TypeSpacing.md) {
                    if let age = character.age {
                        TypeInfoBadge(text: "Age \(age)", color: TypeColors.sceneBlue)
                    }
                    if let gender = character.gender {
                        TypeInfoBadge(text: gender.rawValue, color: TypeColors.scenePurple)
                    }
                }
            }
            
            // Quick stats
            HStack(spacing: TypeSpacing.xl) {
                TypeQuickStat(value: "\(character.dialogueCount)", label: "Lines", icon: "text.bubble", color: TypeColors.sceneGreen)
                TypeQuickStat(value: "\(character.sceneCount)", label: "Scenes", icon: "film", color: TypeColors.sceneOrange)
                TypeQuickStat(value: "\(character.arcs.count)", label: "Arcs", icon: "chart.line.uptrend.xyaxis", color: TypeColors.scenePurple)
                TypeQuickStat(value: "\(character.relationships.count)", label: "Relations", icon: "person.2", color: TypeColors.sceneCyan)
            }
        }
        .padding(TypeSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: TypeRadius.lg)
                .fill(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
        )
        .overlay(
            RoundedRectangle(cornerRadius: TypeRadius.lg)
                .stroke(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight, lineWidth: 0.5)
        )
    }
    
    private var avatarColor: Color {
        let colors = [TypeColors.sceneRed, TypeColors.sceneOrange, TypeColors.sceneGreen,
                      TypeColors.sceneCyan, TypeColors.sceneBlue, TypeColors.scenePurple, TypeColors.scenePink]
        let index = abs(character.name.hashValue) % colors.count
        return colors[index]
    }
}

// MARK: - Type Info Badge
struct TypeInfoBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(TypeTypography.caption)
            .foregroundColor(color)
            .padding(.horizontal, TypeSpacing.sm)
            .padding(.vertical, TypeSpacing.xxs)
            .background(color.opacity(0.12))
            .cornerRadius(TypeRadius.full)
    }
}

// MARK: - Type Quick Stat
struct TypeQuickStat: View {
    @Environment(\.colorScheme) var colorScheme
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: TypeSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
            
            Text(label)
                .font(TypeTypography.caption2)
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
        }
    }
}

// MARK: - Type Character Info Section
struct TypeCharacterInfoSection: View {
    @Environment(\.colorScheme) var colorScheme
    let character: Character
    
    var body: some View {
        TypeDetailSection(title: "Character Information", icon: "person.fill") {
            VStack(spacing: TypeSpacing.md) {
                if !character.description.isEmpty {
                    TypeInfoRow(title: "Description", value: character.description)
                }
                
                if let appearance = character.appearance {
                    TypeInfoRow(title: "Appearance", value: appearance)
                }
                
                if let personality = character.personality {
                    TypeInfoRow(title: "Personality", value: personality)
                }
                
                if let background = character.background {
                    TypeInfoRow(title: "Background", value: background)
                }
                
                if !character.goals.isEmpty {
                    TypeInfoRow(title: "Goals", value: character.goals.joined(separator: ", "))
                }
                
                if !character.conflicts.isEmpty {
                    TypeInfoRow(title: "Conflicts", value: character.conflicts.joined(separator: ", "))
                }
                
                if !character.tags.isEmpty {
                    TypeTagsRow(title: "Tags", tags: character.tags)
                }
            }
        }
    }
}

// MARK: - Type Detail Section
struct TypeDetailSection<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let icon: String
    var action: (() -> Void)? = nil
    var actionLabel: String = "Add"
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.md) {
            // Header
            HStack {
                HStack(spacing: TypeSpacing.sm) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(TypeColors.accent)
                    
                    Text(title)
                        .font(TypeTypography.subheadline)
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                }
                
                Spacer()
                
                if let action = action {
                    Button(action: action) {
                        HStack(spacing: 3) {
                            Image(systemName: "plus")
                                .font(.system(size: 10))
                            Text(actionLabel)
                                .font(TypeTypography.caption)
                        }
                        .foregroundColor(TypeColors.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Content
            content
        }
        .padding(TypeSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: TypeRadius.md)
                .fill(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
        )
        .overlay(
            RoundedRectangle(cornerRadius: TypeRadius.md)
                .stroke(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight, lineWidth: 0.5)
        )
    }
}

// MARK: - Type Info Row
struct TypeInfoRow: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
            Text(title.uppercased())
                .font(TypeTypography.caption2)
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                .tracking(0.5)
            
            Text(value)
                .font(TypeTypography.body)
                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Type Tags Row
struct TypeTagsRow: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.xs) {
            Text(title.uppercased())
                .font(TypeTypography.caption2)
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                .tracking(0.5)
            
            FlowLayout(spacing: TypeSpacing.xs) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(TypeTypography.caption)
                        .foregroundColor(TypeColors.accent)
                        .padding(.horizontal, TypeSpacing.sm)
                        .padding(.vertical, TypeSpacing.xxs)
                        .background(TypeColors.accent.opacity(0.12))
                        .cornerRadius(TypeRadius.full)
                }
            }
        }
    }
}


// MARK: - Type Character Arcs Section
struct TypeCharacterArcsSection: View {
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @Binding var showAddArc: Bool
    @State private var selectedArc: CharacterArc?
    
    var body: some View {
        TypeDetailSection(title: "Character Arcs", icon: "chart.line.uptrend.xyaxis", action: { showAddArc = true }) {
            if character.arcs.isEmpty {
                TypeEmptyPlaceholder(message: "No character arcs defined yet")
            } else {
                VStack(spacing: TypeSpacing.sm) {
                    ForEach(character.arcs) { arc in
                        TypeArcRow(arc: arc)
                            .onTapGesture { selectedArc = arc }
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

// MARK: - Type Arc Row
struct TypeArcRow: View {
    @Environment(\.colorScheme) var colorScheme
    let arc: CharacterArc
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: TypeSpacing.md) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
                HStack {
                    Text(arc.name)
                        .font(TypeTypography.body)
                        .fontWeight(.medium)
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    
                    TypeStatusBadge(status: arc.status)
                }
                
                HStack(spacing: TypeSpacing.md) {
                    Text(arc.arcType.rawValue)
                        .font(TypeTypography.caption)
                        .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                    
                    Text("\(arc.milestones.count) milestones")
                        .font(TypeTypography.caption)
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
        }
        .padding(TypeSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: TypeRadius.sm)
                .fill(isHovered ?
                      (colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.03)) :
                      .clear)
        )
        .onHover { hovering in isHovered = hovering }
    }
    
    private var statusColor: Color {
        switch arc.status {
        case .planned: return TypeColors.sceneBlue
        case .inProgress: return TypeColors.sceneOrange
        case .completed: return TypeColors.sceneGreen
        case .abandoned: return TypeColors.error
        }
    }
}

// MARK: - Type Status Badge
struct TypeStatusBadge: View {
    let status: ArcStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(TypeTypography.caption2)
            .foregroundColor(statusColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.12))
            .cornerRadius(TypeRadius.full)
    }
    
    private var statusColor: Color {
        switch status {
        case .planned: return TypeColors.sceneBlue
        case .inProgress: return TypeColors.sceneOrange
        case .completed: return TypeColors.sceneGreen
        case .abandoned: return TypeColors.error
        }
    }
}

// MARK: - Type Character Relationships Section
struct TypeCharacterRelationshipsSection: View {
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @Binding var showAddRelationship: Bool
    @State private var selectedRelationship: CharacterRelationship?
    
    var body: some View {
        TypeDetailSection(title: "Relationships", icon: "person.2.fill", action: { showAddRelationship = true }) {
            if character.relationships.isEmpty {
                TypeEmptyPlaceholder(message: "No relationships defined yet")
            } else {
                VStack(spacing: TypeSpacing.sm) {
                    ForEach(character.relationships) { relationship in
                        TypeRelationshipRow(relationship: relationship)
                            .onTapGesture { selectedRelationship = relationship }
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

// MARK: - Type Relationship Row
struct TypeRelationshipRow: View {
    @Environment(\.colorScheme) var colorScheme
    let relationship: CharacterRelationship
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: TypeSpacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(TypeColors.sceneCyan.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Text(String(relationship.targetCharacter.prefix(1)).uppercased())
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(TypeColors.sceneCyan)
            }
            
            VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
                Text(relationship.targetCharacter)
                    .font(TypeTypography.body)
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                HStack(spacing: TypeSpacing.sm) {
                    Text(relationship.relationshipType.rawValue)
                        .font(TypeTypography.caption)
                        .foregroundColor(TypeColors.sceneCyan)
                    
                    Text("•")
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                    
                    Text(relationship.strength.rawValue)
                        .font(TypeTypography.caption)
                        .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
        }
        .padding(TypeSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: TypeRadius.sm)
                .fill(isHovered ?
                      (colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.03)) :
                      .clear)
        )
        .onHover { hovering in isHovered = hovering }
    }
}

// MARK: - Type Character Notes Section
struct TypeCharacterNotesSection: View {
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @Binding var showAddNote: Bool
    @State private var selectedNote: CharacterNote?
    
    var body: some View {
        TypeDetailSection(title: "Notes", icon: "note.text", action: { showAddNote = true }) {
            if character.notes.isEmpty {
                TypeEmptyPlaceholder(message: "No notes yet")
            } else {
                VStack(spacing: TypeSpacing.sm) {
                    ForEach(character.notes) { note in
                        TypeNoteRow(note: note)
                            .onTapGesture { selectedNote = note }
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

// MARK: - Type Note Row
struct TypeNoteRow: View {
    @Environment(\.colorScheme) var colorScheme
    let note: CharacterNote
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.xs) {
            HStack {
                Text(note.title)
                    .font(TypeTypography.body)
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                Spacer()
                
                Text(note.type.rawValue)
                    .font(TypeTypography.caption2)
                    .foregroundColor(TypeColors.sceneOrange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(TypeColors.sceneOrange.opacity(0.12))
                    .cornerRadius(TypeRadius.full)
            }
            
            Text(note.content)
                .font(TypeTypography.caption)
                .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                .lineLimit(2)
            
            HStack {
                if let scene = note.scene {
                    Text("Scene: \(scene)")
                        .font(TypeTypography.caption2)
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                }
                
                Spacer()
                
                Text(note.createdAt, style: .date)
                    .font(TypeTypography.caption2)
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            }
        }
        .padding(TypeSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: TypeRadius.sm)
                .fill(isHovered ?
                      (colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.03)) :
                      .clear)
        )
        .onHover { hovering in isHovered = hovering }
    }
}

// MARK: - Type Empty Placeholder
struct TypeEmptyPlaceholder: View {
    @Environment(\.colorScheme) var colorScheme
    let message: String
    
    var body: some View {
        Text(message)
            .font(TypeTypography.caption)
            .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            .italic()
            .padding(.vertical, TypeSpacing.md)
    }
}

// MARK: - Helper Views (keeping existing ones for compatibility)
struct SectionHeader: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: TypeSpacing.sm) {
            Image(systemName: icon)
                .foregroundColor(TypeColors.accent)
            Text(title)
                .font(TypeTypography.subheadline)
                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
        }
    }
}

struct InfoRow: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let value: String
    
    var body: some View {
        TypeInfoRow(title: title, value: value)
    }
}

struct StatusBadge: View {
    let status: ArcStatus
    
    var body: some View {
        TypeStatusBadge(status: status)
    }
}
