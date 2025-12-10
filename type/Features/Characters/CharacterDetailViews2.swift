import SwiftUI

// MARK: - Character Arc Detail View
struct CharacterArcDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    let arc: CharacterArc
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @State private var showEditView = false
    @State private var showAddMilestone = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            DetailModalHeader(
                title: arc.name,
                subtitle: arc.arcType.rawValue,
                onDone: { dismiss() },
                onEdit: { showEditView = true }
            )
            
            ScrollView {
                VStack(spacing: TypeSpacing.xl) {
                    // Status card
                    HStack(spacing: TypeSpacing.lg) {
                        DetailStat(label: "Status", value: arc.status.rawValue, color: statusColor)
                        DetailStat(label: "Milestones", value: "\(arc.milestones.count)", color: TypeColors.accent)
                        DetailStat(label: "Type", value: arc.arcType.rawValue, color: TypeColors.scenePurple)
                    }
                    .padding(TypeSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: TypeRadius.md)
                            .fill(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
                    )
                    
                    // Description
                    if !arc.description.isEmpty {
                        DetailSection(title: "Description") {
                            Text(arc.description)
                                .font(TypeTypography.body)
                                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                        }
                    }
                    
                    // Info
                    DetailSection(title: "Information") {
                        VStack(spacing: TypeSpacing.sm) {
                            if let start = arc.startScene {
                                DetailRow(label: "Start Scene", value: start)
                            }
                            if let end = arc.endScene {
                                DetailRow(label: "End Scene", value: end)
                            }
                            DetailRow(label: "Created", value: arc.createdAt.formatted(date: .abbreviated, time: .omitted))
                            DetailRow(label: "Updated", value: arc.updatedAt.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                    
                    // Notes
                    if !arc.notes.isEmpty {
                        DetailSection(title: "Notes") {
                            Text(arc.notes)
                                .font(TypeTypography.body)
                                .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                        }
                    }
                    
                    // Milestones
                    DetailSection(title: "Milestones", action: { showAddMilestone = true }) {
                        if arc.milestones.isEmpty {
                            EmptyDetailPlaceholder(message: "No milestones defined")
                        } else {
                            VStack(spacing: TypeSpacing.xs) {
                                ForEach(arc.milestones) { milestone in
                                    MilestoneListRow(milestone: milestone)
                                }
                            }
                        }
                    }
                }
                .padding(TypeSpacing.xl)
            }
        }
        .frame(minWidth: 480, idealWidth: 520, minHeight: 500, idealHeight: 600)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
        .sheet(isPresented: $showEditView) {
            CharacterArcEditView(arc: arc, character: character, characterDatabase: characterDatabase, isNewArc: false)
        }
        .sheet(isPresented: $showAddMilestone) {
            ArcMilestoneEditView(milestone: ArcMilestone(name: ""), arc: arc, character: character, characterDatabase: characterDatabase, isNewMilestone: true)
        }
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

// MARK: - Detail Modal Header
struct DetailModalHeader: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    var subtitle: String? = nil
    let onDone: () -> Void
    var onEdit: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Button("Done") { onDone() }
                .font(TypeTypography.body)
                .foregroundColor(TypeColors.accent)
                .buttonStyle(.plain)
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(title)
                    .font(TypeTypography.headline)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(TypeTypography.caption)
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                }
            }
            
            Spacer()
            
            if let onEdit = onEdit {
                Button("Edit") { onEdit() }
                    .font(TypeTypography.body)
                    .foregroundColor(TypeColors.accent)
                    .buttonStyle(.plain)
            } else {
                Text("Edit")
                    .font(TypeTypography.body)
                    .foregroundColor(.clear)
            }
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

// MARK: - Detail Section
struct DetailSection<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    var action: (() -> Void)? = nil
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.sm) {
            HStack {
                Text(title.uppercased())
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                    .tracking(0.8)
                
                Spacer()
                
                if let action = action {
                    Button(action: action) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(TypeColors.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            content
        }
    }
}

// MARK: - Detail Stat
struct DetailStat: View {
    @Environment(\.colorScheme) var colorScheme
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: TypeSpacing.xxs) {
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            
            Text(label)
                .font(TypeTypography.caption2)
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    @Environment(\.colorScheme) var colorScheme
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(TypeTypography.body)
                .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
            
            Spacer()
            
            Text(value)
                .font(TypeTypography.body)
                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
        }
        .padding(.vertical, TypeSpacing.xxs)
    }
}

// MARK: - Milestone List Row
struct MilestoneListRow: View {
    @Environment(\.colorScheme) var colorScheme
    let milestone: ArcMilestone
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: TypeSpacing.sm) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            
            Text(milestone.name)
                .font(TypeTypography.body)
                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
            
            Spacer()
            
            Text(milestone.status.rawValue)
                .font(TypeTypography.caption2)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, TypeSpacing.sm)
        .padding(.vertical, TypeSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: TypeRadius.sm)
                .fill(isHovered ? (colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.03)) : .clear)
        )
        .onHover { hovering in
            withAnimation(TypeAnimation.quick) { isHovered = hovering }
        }
    }
    
    private var statusColor: Color {
        switch milestone.status {
        case .planned: return TypeColors.sceneBlue
        case .inProgress: return TypeColors.sceneOrange
        case .completed: return TypeColors.sceneGreen
        case .skipped: return TypeColors.error
        }
    }
}

// MARK: - Empty Detail Placeholder
struct EmptyDetailPlaceholder: View {
    @Environment(\.colorScheme) var colorScheme
    let message: String
    
    var body: some View {
        Text(message)
            .font(TypeTypography.body)
            .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            .italic()
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, TypeSpacing.lg)
    }
}

// MARK: - Character Relationship Detail View
struct CharacterRelationshipDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    let relationship: CharacterRelationship
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @State private var showEditView = false
    
    var body: some View {
        VStack(spacing: 0) {
            DetailModalHeader(
                title: relationship.targetCharacter,
                subtitle: relationship.relationshipType.rawValue,
                onDone: { dismiss() },
                onEdit: { showEditView = true }
            )
            
            ScrollView {
                VStack(spacing: TypeSpacing.xl) {
                    // Stats
                    HStack(spacing: TypeSpacing.lg) {
                        DetailStat(label: "Type", value: relationship.relationshipType.rawValue, color: TypeColors.sceneCyan)
                        DetailStat(label: "Strength", value: relationship.strength.rawValue, color: TypeColors.sceneGreen)
                    }
                    .padding(TypeSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: TypeRadius.md)
                            .fill(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
                    )
                    
                    // Description
                    if !relationship.description.isEmpty {
                        DetailSection(title: "Description") {
                            Text(relationship.description)
                                .font(TypeTypography.body)
                                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                        }
                    }
                    
                    // Info
                    DetailSection(title: "Information") {
                        VStack(spacing: TypeSpacing.sm) {
                            DetailRow(label: "Created", value: relationship.createdAt.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                    
                    // Notes
                    if !relationship.notes.isEmpty {
                        DetailSection(title: "Notes") {
                            Text(relationship.notes)
                                .font(TypeTypography.body)
                                .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                        }
                    }
                }
                .padding(TypeSpacing.xl)
            }
        }
        .frame(minWidth: 420, idealWidth: 460, minHeight: 380, idealHeight: 420)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
        .sheet(isPresented: $showEditView) {
            CharacterRelationshipEditView(relationship: relationship, character: character, characterDatabase: characterDatabase, isNewRelationship: false)
        }
    }
}

// MARK: - Character Note Detail View
struct CharacterNoteDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    let note: CharacterNote
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @State private var showEditView = false
    
    var body: some View {
        VStack(spacing: 0) {
            DetailModalHeader(
                title: note.title,
                subtitle: note.type.rawValue,
                onDone: { dismiss() },
                onEdit: { showEditView = true }
            )
            
            ScrollView {
                VStack(spacing: TypeSpacing.xl) {
                    // Content
                    DetailSection(title: "Content") {
                        Text(note.content)
                            .font(TypeTypography.body)
                            .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Info
                    DetailSection(title: "Information") {
                        VStack(spacing: TypeSpacing.sm) {
                            if let scene = note.scene {
                                DetailRow(label: "Scene", value: scene)
                            }
                            if let line = note.lineNumber {
                                DetailRow(label: "Line", value: "\(line)")
                            }
                            DetailRow(label: "Created", value: note.createdAt.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                }
                .padding(TypeSpacing.xl)
            }
        }
        .frame(minWidth: 420, idealWidth: 460, minHeight: 350, idealHeight: 400)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
        .sheet(isPresented: $showEditView) {
            CharacterNoteEditView(note: note, character: character, characterDatabase: characterDatabase, isNewNote: false)
        }
    }
}

// MARK: - Character Statistics View
struct CharacterStatisticsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    let statistics: CharacterStatistics
    
    var body: some View {
        VStack(spacing: 0) {
            DetailModalHeader(title: "Statistics", onDone: { dismiss() })
            
            ScrollView {
                VStack(spacing: TypeSpacing.xl) {
                    // Overview stats
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: TypeSpacing.md) {
                        StatCard(label: "Total Characters", value: "\(statistics.totalCharacters)", icon: "person.3", color: TypeColors.accent)
                        StatCard(label: "With Dialogue", value: "\(statistics.charactersWithDialogue)", icon: "text.bubble", color: TypeColors.sceneGreen)
                        StatCard(label: "With Arcs", value: "\(statistics.charactersWithArcs)", icon: "chart.line.uptrend.xyaxis", color: TypeColors.scenePurple)
                        StatCard(label: "Avg Dialogue", value: String(format: "%.1f", statistics.averageDialogueCount), icon: "number", color: TypeColors.sceneOrange)
                    }
                    
                    // Gender breakdown
                    if !statistics.charactersByGender.isEmpty {
                        DetailSection(title: "By Gender") {
                            VStack(spacing: TypeSpacing.sm) {
                                ForEach(Gender.allCases, id: \.self) { gender in
                                    if let count = statistics.charactersByGender[gender], count > 0 {
                                        DistributionRow(label: gender.rawValue, value: count, total: statistics.totalCharacters)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Most active
                    if let mostActive = statistics.mostActiveCharacter {
                        DetailSection(title: "Most Active") {
                            HStack(spacing: TypeSpacing.md) {
                                Circle()
                                    .fill(TypeColors.sceneYellow.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(String(mostActive.name.prefix(1)).uppercased())
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(TypeColors.sceneYellow)
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(mostActive.name)
                                        .font(TypeTypography.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                                    
                                    Text("\(mostActive.dialogueCount) lines · \(mostActive.sceneCount) scenes")
                                        .font(TypeTypography.caption)
                                        .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding(TypeSpacing.xl)
            }
        }
        .frame(minWidth: 460, idealWidth: 500, minHeight: 480, idealHeight: 550)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    @Environment(\.colorScheme) var colorScheme
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
            
            Text(label)
                .font(TypeTypography.caption)
                .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(TypeSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: TypeRadius.md)
                .fill(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
        )
    }
}

// MARK: - Distribution Row
struct DistributionRow: View {
    @Environment(\.colorScheme) var colorScheme
    let label: String
    let value: Int
    let total: Int
    
    private var percentage: Double {
        total > 0 ? Double(value) / Double(total) : 0
    }
    
    var body: some View {
        VStack(spacing: TypeSpacing.xs) {
            HStack {
                Text(label)
                    .font(TypeTypography.body)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                Spacer()
                
                Text("\(value)")
                    .font(TypeTypography.body)
                    .fontWeight(.medium)
                    .foregroundColor(TypeColors.accent)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(TypeColors.accent)
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Helper: Milestone Status Badge (kept for compatibility)
struct MilestoneStatusBadge: View {
    let status: MilestoneStatus
    
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
        case .skipped: return TypeColors.error
        }
    }
}

// MARK: - Arc Milestone Edit View
struct ArcMilestoneEditView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State var milestone: ArcMilestone
    let arc: CharacterArc
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    let isNewMilestone: Bool
    
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
        VStack(spacing: 0) {
            ModalHeader(
                title: isNewMilestone ? "New Milestone" : "Edit Milestone",
                onCancel: { dismiss() },
                onSave: saveMilestone,
                canSave: !name.isEmpty
            )
            
            ScrollView {
                VStack(spacing: TypeSpacing.xl) {
                    ModalSection(title: "Milestone") {
                        VStack(spacing: TypeSpacing.md) {
                            ModalTextField(label: "Name", placeholder: "Milestone name", text: $name)
                            ModalTextArea(label: "Description", placeholder: "What happens", text: $description)
                            ModalEnumDropdown(label: "Status", selection: $status)
                        }
                    }
                    
                    ModalSection(title: "Reference") {
                        HStack(spacing: TypeSpacing.md) {
                            ModalTextField(label: "Scene", placeholder: "Scene name", text: $scene)
                            ModalTextField(label: "Line", placeholder: "#", text: $lineNumber)
                                .frame(width: 70)
                        }
                    }
                    
                    ModalSection(title: "Notes") {
                        ModalTextArea(label: "", placeholder: "Additional notes", text: $notes)
                    }
                }
                .padding(TypeSpacing.xl)
            }
        }
        .frame(minWidth: 420, idealWidth: 460, minHeight: 450, idealHeight: 500)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
    }
    
    private func saveMilestone() {
        var updatedMilestone = milestone
        updatedMilestone.name = name
        updatedMilestone.description = description
        updatedMilestone.scene = scene.isEmpty ? nil : scene
        updatedMilestone.lineNumber = Int(lineNumber)
        updatedMilestone.status = status
        updatedMilestone.notes = notes
        
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
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    let milestone: ArcMilestone
    let arc: CharacterArc
    let character: Character
    @ObservedObject var characterDatabase: CharacterDatabase
    @State private var showEditView = false
    
    var body: some View {
        VStack(spacing: 0) {
            DetailModalHeader(
                title: milestone.name,
                subtitle: milestone.status.rawValue,
                onDone: { dismiss() },
                onEdit: { showEditView = true }
            )
            
            ScrollView {
                VStack(spacing: TypeSpacing.xl) {
                    // Status
                    HStack(spacing: TypeSpacing.lg) {
                        DetailStat(label: "Status", value: milestone.status.rawValue, color: statusColor)
                    }
                    .padding(TypeSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: TypeRadius.md)
                            .fill(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
                    )
                    
                    // Description
                    if !milestone.description.isEmpty {
                        DetailSection(title: "Description") {
                            Text(milestone.description)
                                .font(TypeTypography.body)
                                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                        }
                    }
                    
                    // Info
                    DetailSection(title: "Information") {
                        VStack(spacing: TypeSpacing.sm) {
                            if let scene = milestone.scene {
                                DetailRow(label: "Scene", value: scene)
                            }
                            if let line = milestone.lineNumber {
                                DetailRow(label: "Line", value: "\(line)")
                            }
                            DetailRow(label: "Created", value: milestone.createdAt.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                    
                    // Notes
                    if !milestone.notes.isEmpty {
                        DetailSection(title: "Notes") {
                            Text(milestone.notes)
                                .font(TypeTypography.body)
                                .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                        }
                    }
                }
                .padding(TypeSpacing.xl)
            }
        }
        .frame(minWidth: 400, idealWidth: 440, minHeight: 350, idealHeight: 400)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
        .sheet(isPresented: $showEditView) {
            ArcMilestoneEditView(milestone: milestone, arc: arc, character: character, characterDatabase: characterDatabase, isNewMilestone: false)
        }
    }
    
    private var statusColor: Color {
        switch milestone.status {
        case .planned: return TypeColors.sceneBlue
        case .inProgress: return TypeColors.sceneOrange
        case .completed: return TypeColors.sceneGreen
        case .skipped: return TypeColors.error
        }
    }
}
