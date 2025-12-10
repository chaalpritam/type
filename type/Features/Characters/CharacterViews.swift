import SwiftUI

// MARK: - Character Database Main View
struct CharacterDatabaseView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var characterDatabase: CharacterDatabase
    @Binding var isVisible: Bool
    @State private var showAddCharacter = false
    @State private var showSearchFilters = false
    @State private var hoveredCharacterId: UUID?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            TypeCharacterHeader(
                statistics: characterDatabase.statistics,
                onAddCharacter: { showAddCharacter = true }
            )
            
            // Search bar
            TypeCharacterSearchBar(
                searchFilters: $characterDatabase.searchFilters,
                showFilters: $showSearchFilters
            )
            
            // Character list
            if characterDatabase.filteredCharacters().isEmpty {
                TypeEmptyState(
                    icon: "person.2",
                    title: "No Characters",
                    message: "Characters will appear here as you write, or you can add them manually."
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: TypeSpacing.xs) {
                        ForEach(characterDatabase.filteredCharacters()) { character in
                            TypeCharacterRow(
                                character: character,
                                isHovered: hoveredCharacterId == character.id,
                                onTap: {
                                    characterDatabase.selectedCharacter = character
                                },
                                onDelete: {
                                    characterDatabase.deleteCharacter(character)
                                }
                            )
                            .onHover { hovering in
                                hoveredCharacterId = hovering ? character.id : nil
                            }
                        }
                    }
                    .padding(TypeSpacing.md)
                }
            }
        }
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
        .sheet(isPresented: $showAddCharacter) {
            CharacterEditView(
                character: Character(name: ""),
                characterDatabase: characterDatabase,
                isNewCharacter: true
            )
        }
        .sheet(item: $characterDatabase.selectedCharacter) { character in
            CharacterDetailView(
                character: character,
                characterDatabase: characterDatabase
            )
        }
    }
}

// MARK: - Type Character Header
struct TypeCharacterHeader: View {
    @Environment(\.colorScheme) var colorScheme
    let statistics: CharacterStatistics
    let onAddCharacter: () -> Void
    
    var body: some View {
        VStack(spacing: TypeSpacing.md) {
            // Title row
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
                    Text("Characters")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    
                    Text("\(statistics.totalCharacters) characters in your screenplay")
                        .font(TypeTypography.caption)
                        .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                }
                
                Spacer()
                
                Button(action: onAddCharacter) {
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
                TypeMiniStatCard(
                    value: "\(statistics.totalCharacters)",
                    label: "Total",
                    icon: "person.3",
                    color: TypeColors.accent
                )
                
                TypeMiniStatCard(
                    value: "\(statistics.charactersWithDialogue)",
                    label: "Speaking",
                    icon: "text.bubble",
                    color: TypeColors.sceneGreen
                )
                
                TypeMiniStatCard(
                    value: "\(statistics.charactersWithArcs)",
                    label: "With Arcs",
                    icon: "chart.line.uptrend.xyaxis",
                    color: TypeColors.scenePurple
                )
                
                TypeMiniStatCard(
                    value: String(format: "%.0f", statistics.averageDialogueCount),
                    label: "Avg Lines",
                    icon: "text.alignleft",
                    color: TypeColors.sceneOrange
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

// MARK: - Type Mini Stat Card
struct TypeMiniStatCard: View {
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

// MARK: - Type Character Search Bar
struct TypeCharacterSearchBar: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var searchFilters: CharacterSearchFilters
    @Binding var showFilters: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: TypeSpacing.sm) {
                // Search field
                HStack(spacing: TypeSpacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12))
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                    
                    TextField("Search characters...", text: $searchFilters.searchText)
                        .textFieldStyle(.plain)
                        .font(TypeTypography.body)
                    
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
                TypeCharacterFilterPanel(searchFilters: $searchFilters)
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

// MARK: - Type Character Filter Panel
struct TypeCharacterFilterPanel: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var searchFilters: CharacterSearchFilters
    
    var body: some View {
        VStack(spacing: TypeSpacing.md) {
            // Header
            HStack {
                Text("Filters")
                    .font(TypeTypography.subheadline)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                Spacer()
                
                Button("Clear") {
                    searchFilters = CharacterSearchFilters()
                }
                .font(TypeTypography.caption)
                .foregroundColor(TypeColors.accent)
                .buttonStyle(.plain)
            }
            
            // Filter options
            HStack(spacing: TypeSpacing.md) {
                TypeFilterPicker(
                    title: "Gender",
                    selection: $searchFilters.gender,
                    options: Gender.allCases.map { ($0.rawValue, $0 as Gender?) },
                    anyOption: ("Any", nil as Gender?)
                )
                
                TypeFilterPicker(
                    title: "Arc Status",
                    selection: $searchFilters.arcStatus,
                    options: ArcStatus.allCases.map { ($0.rawValue, $0 as ArcStatus?) },
                    anyOption: ("Any", nil as ArcStatus?)
                )
                
                TypeFilterToggle(
                    title: "Has Dialogue",
                    selection: $searchFilters.hasDialogue
                )
                
                TypeFilterToggle(
                    title: "Has Arcs",
                    selection: $searchFilters.hasArcs
                )
            }
            
            // Sort options
            HStack(spacing: TypeSpacing.md) {
                Text("Sort by")
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                
                Picker("Sort", selection: $searchFilters.sortBy) {
                    ForEach(CharacterSortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 300)
                
                Button(action: {
                    searchFilters.sortOrder = searchFilters.sortOrder == .forward ? .reverse : .forward
                }) {
                    Image(systemName: searchFilters.sortOrder == .forward ? "arrow.up" : "arrow.down")
                        .font(.system(size: 12))
                        .foregroundColor(TypeColors.accent)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
        .padding(TypeSpacing.md)
        .background(colorScheme == .dark ? Color.black.opacity(0.2) : Color.black.opacity(0.03))
    }
}

// MARK: - Type Filter Picker
struct TypeFilterPicker<T: Hashable>: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    @Binding var selection: T?
    let options: [(String, T?)]
    let anyOption: (String, T?)
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
            Text(title)
                .font(TypeTypography.caption2)
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            
            Menu {
                Button(anyOption.0) { selection = anyOption.1 }
                Divider()
                ForEach(options, id: \.0) { option in
                    Button(option.0) { selection = option.1 }
                }
            } label: {
                HStack {
                    Text(currentLabel)
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
    
    private var currentLabel: String {
        if let selection = selection {
            return options.first { $0.1 == selection }?.0 ?? anyOption.0
        }
        return anyOption.0
    }
}

// MARK: - Type Filter Toggle
struct TypeFilterToggle: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    @Binding var selection: Bool?
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
            Text(title)
                .font(TypeTypography.caption2)
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            
            Menu {
                Button("Any") { selection = nil }
                Button("Yes") { selection = true }
                Button("No") { selection = false }
            } label: {
                HStack {
                    Text(selection == nil ? "Any" : (selection == true ? "Yes" : "No"))
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

// MARK: - Type Character Row
struct TypeCharacterRow: View {
    @Environment(\.colorScheme) var colorScheme
    let character: Character
    let isHovered: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: TypeSpacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(avatarColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Text(String(character.name.prefix(1)).uppercased())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(avatarColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
                HStack {
                    Text(character.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    
                    if let gender = character.gender {
                        Text(gender.rawValue)
                            .font(TypeTypography.caption2)
                            .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05))
                            )
                    }
                }
                
                HStack(spacing: TypeSpacing.md) {
                    if let occupation = character.occupation {
                        Text(occupation)
                            .font(TypeTypography.caption)
                            .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                    }
                    
                    if character.dialogueCount > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 10))
                            Text("\(character.dialogueCount)")
                                .font(TypeTypography.caption2)
                        }
                        .foregroundColor(TypeColors.sceneGreen)
                    }
                    
                    if !character.arcs.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 10))
                            Text("\(character.arcs.count)")
                                .font(TypeTypography.caption2)
                        }
                        .foregroundColor(TypeColors.scenePurple)
                    }
                }
            }
            
            Spacer()
            
            // Actions (show on hover)
            if isHovered {
                HStack(spacing: TypeSpacing.xs) {
                    Button(action: onTap) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 14))
                            .foregroundColor(TypeColors.accent)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(TypeColors.error)
                    }
                    .buttonStyle(.plain)
                }
                .transition(.opacity)
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
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
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .animation(TypeAnimation.quick, value: isHovered)
    }
    
    private var avatarColor: Color {
        // Generate consistent color based on character name
        let colors = [TypeColors.sceneRed, TypeColors.sceneOrange, TypeColors.sceneGreen, 
                      TypeColors.sceneCyan, TypeColors.sceneBlue, TypeColors.scenePurple, TypeColors.scenePink]
        let index = abs(character.name.hashValue) % colors.count
        return colors[index]
    }
}

// MARK: - Type Stat Box
struct TypeStatBox: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
            
            Text(title)
                .font(TypeTypography.caption)
                .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
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

// MARK: - Type Info Card
struct TypeInfoCard: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: TypeSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.12))
                .cornerRadius(TypeRadius.sm)
            
            VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
                Text(title)
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
            }
            
            Spacer()
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

// MARK: - Type Breakdown Section
struct TypeBreakdownSection: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let icon: String
    let data: [String: Int]
    
    var body: some View {
        VStack(alignment: .leading, spacing: TypeSpacing.md) {
            HStack(spacing: TypeSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(TypeColors.accent)
                
                Text(title)
                    .font(TypeTypography.subheadline)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
            }
            
            ForEach(Array(data.sorted { $0.value > $1.value }), id: \.key) { key, value in
                TypeBreakdownRow(label: key, value: value, total: data.values.reduce(0, +))
            }
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

// MARK: - Type Breakdown Row
struct TypeBreakdownRow: View {
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
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                Spacer()
                
                Text("\(value)")
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.08))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(TypeColors.accent)
                        .frame(width: geometry.size.width * percentage, height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Dictionary Extension
extension Dictionary {
    func mapKeys<NewKey: Hashable>(_ transform: (Key) -> NewKey) -> [NewKey: Value] {
        var result = [NewKey: Value]()
        for (key, value) in self {
            result[transform(key)] = value
        }
        return result
    }
}
