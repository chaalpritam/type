import SwiftUI

// MARK: - Character Database Main View
struct CharacterDatabaseView: View {
    @ObservedObject var characterDatabase: CharacterDatabase
    @Binding var isVisible: Bool
    @State private var showAddCharacter = false
    @State private var showSearchFilters = false
    @State private var showStatistics = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with statistics
                CharacterDatabaseHeader(
                    statistics: characterDatabase.statistics,
                    showStatistics: $showStatistics
                )
                
                // Search and filters
                CharacterSearchBar(
                    searchFilters: $characterDatabase.searchFilters,
                    showFilters: $showSearchFilters
                )
                
                // Character list
                CharacterListView(
                    characters: characterDatabase.filteredCharacters(),
                    selectedCharacter: $characterDatabase.selectedCharacter,
                    onDelete: { character in
                        characterDatabase.deleteCharacter(character)
                    }
                )
            }
            .navigationTitle("Characters")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { isVisible = false }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddCharacter.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddCharacter) {
                CharacterEditView(
                    character: Character(name: ""),
                    characterDatabase: characterDatabase,
                    isNewCharacter: true
                )
            }
            .sheet(isPresented: $showStatistics) {
                CharacterStatisticsView(statistics: characterDatabase.statistics)
            }
        }
        .sheet(item: $characterDatabase.selectedCharacter) { character in
            CharacterDetailView(
                character: character,
                characterDatabase: characterDatabase
            )
        }
    }
}

// MARK: - Character Database Header
struct CharacterDatabaseHeader: View {
    let statistics: CharacterStatistics
    @Binding var showStatistics: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Character Database")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(statistics.totalCharacters) characters • \(statistics.charactersWithDialogue) with dialogue • \(statistics.charactersWithArcs) with arcs")
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
                CharacterStatCard(
                    title: "Total",
                    value: "\(statistics.totalCharacters)",
                    icon: "person.3"
                )
                
                CharacterStatCard(
                    title: "With Dialogue",
                    value: "\(statistics.charactersWithDialogue)",
                    icon: "message"
                )
                
                CharacterStatCard(
                    title: "With Arcs",
                    value: "\(statistics.charactersWithArcs)",
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                CharacterStatCard(
                    title: "Avg Dialogue",
                    value: String(format: "%.1f", statistics.averageDialogueCount),
                    icon: "text.bubble"
                )
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Character Stat Card
struct CharacterStatCard: View {
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
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Character Search Bar
struct CharacterSearchBar: View {
    @Binding var searchFilters: CharacterSearchFilters
    @Binding var showFilters: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search characters...", text: $searchFilters.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
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
                CharacterFilterView(searchFilters: $searchFilters)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.3), value: showFilters)
    }
}

// MARK: - Character Filter View
struct CharacterFilterView: View {
    @Binding var searchFilters: CharacterSearchFilters
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Filters")
                    .font(.headline)
                Spacer()
                Button("Clear All") {
                    searchFilters = CharacterSearchFilters()
                }
                .font(.caption)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                // Gender filter
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gender")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Gender", selection: $searchFilters.gender) {
                        Text("Any").tag(nil as Gender?)
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender as Gender?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Arc status filter
                VStack(alignment: .leading, spacing: 4) {
                    Text("Arc Status")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Arc Status", selection: $searchFilters.arcStatus) {
                        Text("Any").tag(nil as ArcStatus?)
                        ForEach(ArcStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status as ArcStatus?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Has dialogue filter
                VStack(alignment: .leading, spacing: 4) {
                    Text("Has Dialogue")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Has Dialogue", selection: $searchFilters.hasDialogue) {
                        Text("Any").tag(nil as Bool?)
                        Text("Yes").tag(true as Bool?)
                        Text("No").tag(false as Bool?)
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Has arcs filter
                VStack(alignment: .leading, spacing: 4) {
                    Text("Has Arcs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Has Arcs", selection: $searchFilters.hasArcs) {
                        Text("Any").tag(nil as Bool?)
                        Text("Yes").tag(true as Bool?)
                        Text("No").tag(false as Bool?)
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            
            // Sort options
            HStack {
                Text("Sort by")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Sort by", selection: $searchFilters.sortBy) {
                    ForEach(CharacterSortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Spacer()
                
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

// MARK: - Character List View
struct CharacterListView: View {
    let characters: [Character]
    @Binding var selectedCharacter: Character?
    let onDelete: (Character) -> Void
    
    var body: some View {
        List {
            ForEach(characters) { character in
                CharacterRowView(character: character)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedCharacter = character
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", role: .destructive) {
                            onDelete(character)
                        }
                    }
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Character Row View
struct CharacterRowView: View {
    let character: Character
    
    var body: some View {
        HStack(spacing: 12) {
            // Character avatar/icon
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(character.name.prefix(1)).uppercased())
                        .font(.headline)
                        .foregroundColor(.accentColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(character.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if character.dialogueCount > 0 {
                        Text("\(character.dialogueCount)")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
                HStack {
                    if let occupation = character.occupation {
                        Text(occupation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !character.arcs.isEmpty {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("\(character.arcs.count) arc\(character.arcs.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let gender = character.gender {
                        Text(gender.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(3)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
} 