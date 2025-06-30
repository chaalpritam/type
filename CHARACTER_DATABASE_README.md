# Character Database - Fountain Screenplay Editor

## Overview

The Character Database is a comprehensive character management system integrated into the Fountain screenplay editor. It automatically extracts characters from your screenplay and provides tools to track character information, development arcs, relationships, and notes.

## Features

### 🎭 Character Management
- **Automatic Character Extraction**: Characters are automatically detected from Fountain screenplay format
- **Character Profiles**: Store detailed information including name, description, age, gender, occupation, appearance, personality, and background
- **Goals & Conflicts**: Track character motivations and internal/external conflicts
- **Tags**: Organize characters with custom tags for easy categorization

### 📈 Character Arcs
- **Arc Types**: Character development, relationship, plot, emotional, physical, spiritual, professional, and personal arcs
- **Milestones**: Break down arcs into manageable milestones with status tracking
- **Progress Tracking**: Monitor arc completion status (planned, in progress, completed, abandoned)
- **Scene Integration**: Link arcs to specific scenes in your screenplay

### 👥 Character Relationships
- **Relationship Types**: Family, romantic, friendship, professional, antagonistic, mentor, student, neutral
- **Relationship Strength**: Weak, medium, strong, very strong
- **Dynamic Tracking**: Monitor how relationships evolve throughout the story

### 📝 Character Notes
- **Note Types**: General, dialogue, action, development, research, inspiration
- **Scene References**: Link notes to specific scenes and line numbers
- **Contextual Information**: Add research, inspiration, and development notes

### 🔍 Advanced Search & Filtering
- **Text Search**: Search by name, description, occupation, or tags
- **Gender Filtering**: Filter characters by gender
- **Arc Status Filtering**: Find characters with specific arc statuses
- **Dialogue Filtering**: Filter characters with or without dialogue
- **Sorting Options**: Sort by name, dialogue count, scene count, appearance order, creation date

### 📊 Statistics & Analytics
- **Overview Statistics**: Total characters, characters with dialogue, characters with arcs, average dialogue count
- **Gender Distribution**: Visual breakdown of character gender distribution
- **Arc Status Distribution**: Overview of character arc progress
- **Most Active Character**: Identify the character with the most dialogue and scenes

### 💾 Data Persistence
- **Automatic Saving**: All character data is automatically saved to UserDefaults
- **Export/Import**: Export and import character databases for backup and sharing
- **Real-time Updates**: Character information updates automatically as you write

## Usage

### Accessing the Character Database

1. **Toolbar Button**: Click the "Characters" button in the main toolbar
   - The button shows a badge with the total number of characters
   - Located in the toolbar next to collaboration controls

2. **Automatic Detection**: Characters are automatically extracted as you write
   - Fountain character names (ALL CAPS) are detected
   - Dialogue counts are automatically tracked
   - Scene appearances are recorded

### Managing Characters

#### Adding Characters
1. Click the "+" button in the character database view
2. Fill in character information:
   - **Basic Info**: Name, description, age, gender, occupation
   - **Details**: Appearance, personality, background
   - **Goals & Conflicts**: Add character motivations and conflicts
   - **Tags**: Add custom tags for organization

#### Editing Characters
1. Click on any character in the list to open the detail view
2. Click "Edit" to modify character information
3. All changes are automatically saved

#### Character Arcs
1. In the character detail view, click "Add Arc"
2. Define the arc:
   - **Name & Description**: What the arc is about
   - **Arc Type**: Choose from development, relationship, plot, etc.
   - **Status**: Set initial status (planned, in progress, etc.)
   - **Scenes**: Link to start and end scenes
3. Add milestones to break down the arc into manageable steps

#### Character Relationships
1. In the character detail view, click "Add Relationship"
2. Define the relationship:
   - **Target Character**: Who the relationship is with
   - **Type**: Family, romantic, friendship, etc.
   - **Strength**: How strong the relationship is
   - **Description**: Details about the relationship

#### Character Notes
1. In the character detail view, click "Add Note"
2. Create notes with:
   - **Title & Content**: Note details
   - **Type**: General, dialogue, action, etc.
   - **Scene Reference**: Link to specific scenes

### Search and Filter

1. **Search Bar**: Type to search character names, descriptions, occupations, or tags
2. **Filters**: Click the filter button to access advanced filtering:
   - Gender filter
   - Arc status filter
   - Dialogue presence filter
   - Arc presence filter
3. **Sorting**: Choose sort order and direction

### Statistics

1. Click "Statistics" in the character database view
2. View comprehensive analytics:
   - Overview statistics
   - Gender distribution
   - Arc status distribution
   - Most active character details

## Technical Implementation

### File Structure

```
type/
├── CharacterModels.swift          # Data models and enums
├── CharacterDatabase.swift        # Core database manager
├── CharacterViews.swift           # Main character list and search views
├── CharacterDetailViews.swift     # Character detail and info views
├── CharacterDetailViews2.swift    # Arc, relationship, note detail views
├── CharacterEditViews.swift       # Edit forms for all character data
└── ContentView.swift              # Main app integration
```

### Key Components

#### CharacterModels.swift
- `Character`: Main character data model
- `CharacterArc`: Character development arc model
- `CharacterRelationship`: Character relationship model
- `CharacterNote`: Character note model
- Supporting enums for types, statuses, and categories

#### CharacterDatabase.swift
- `CharacterDatabase`: Main database manager class
- CRUD operations for all character data
- Fountain parser integration
- Search and filtering logic
- Statistics calculation
- Data persistence

#### CharacterViews.swift
- `CharacterDatabaseView`: Main character database interface
- `CharacterListView`: Character list with search and filtering
- `CharacterSearchBar`: Advanced search interface
- `CharacterDatabaseHeader`: Statistics overview

#### CharacterDetailViews.swift
- `CharacterDetailView`: Comprehensive character detail view
- `CharacterHeaderView`: Character avatar and basic info
- `CharacterInfoSection`: Detailed character information
- `CharacterArcsSection`: Character arc management
- `CharacterRelationshipsSection`: Relationship management
- `CharacterNotesSection`: Note management

#### CharacterEditViews.swift
- `CharacterEditView`: Character creation and editing form
- `CharacterArcEditView`: Arc creation and editing form
- `CharacterRelationshipEditView`: Relationship editing form
- `CharacterNoteEditView`: Note editing form

### Integration Points

#### Fountain Parser Integration
- Automatic character detection from screenplay
- Dialogue counting and scene tracking
- Real-time updates as you write

#### UI Integration
- Toolbar button with character count badge
- Sheet presentation for character database
- Consistent Apple-style design language

#### Data Persistence
- UserDefaults storage for character data
- Automatic saving on all changes
- Export/import functionality

## Fountain Format Integration

The character database automatically works with Fountain screenplay format:

```fountain
Title: My Screenplay
Author: John Doe

# Act 1

## Scene 1

INT. COFFEE SHOP - DAY

JOHN sits at a table, reading a newspaper.

JOHN
(anxious)
I can't believe this is happening.

MARY enters, looking around nervously.

MARY
John? Is that you?

JOHN
Mary! I thought you'd never come.
```

In this example, the system would automatically detect:
- **JOHN**: Character with dialogue and action
- **MARY**: Character with dialogue
- Track dialogue counts, scene appearances, and character interactions

## Best Practices

### Character Organization
1. **Use Consistent Names**: Keep character names consistent throughout your screenplay
2. **Add Descriptions**: Fill in character descriptions for better tracking
3. **Set Goals & Conflicts**: Define clear character motivations
4. **Use Tags**: Tag characters for easy filtering (e.g., "protagonist", "antagonist", "supporting")

### Arc Management
1. **Plan Arcs Early**: Set up character arcs at the beginning of your project
2. **Break Down Milestones**: Create specific milestones for each arc
3. **Update Progress**: Regularly update arc and milestone status
4. **Link to Scenes**: Connect arcs to specific scenes for better tracking

### Relationship Tracking
1. **Map Relationships**: Create relationship entries for all character interactions
2. **Track Evolution**: Update relationship strength as the story progresses
3. **Add Context**: Include descriptions of how relationships develop

### Note Taking
1. **Research Notes**: Add research notes for character development
2. **Inspiration Notes**: Document character inspiration sources
3. **Development Notes**: Track character evolution throughout the story
4. **Scene Notes**: Link notes to specific scenes for context

## Troubleshooting

### Characters Not Detected
- Ensure character names are in ALL CAPS in Fountain format
- Check that character names are on separate lines from dialogue
- Verify Fountain syntax is correct

### Data Not Saving
- Character data saves automatically to UserDefaults
- Check that you have write permissions
- Restart the app if data appears to be lost

### Performance Issues
- Large character databases may slow down with many characters
- Consider using tags to organize characters
- Use search and filtering to manage large character lists

## Future Enhancements

Potential future features for the character database:

- **Character Timeline**: Visual timeline of character appearances
- **Relationship Network**: Visual graph of character relationships
- **Dialogue Analysis**: Analyze character speech patterns
- **Character Templates**: Pre-built character templates
- **Collaboration**: Share character databases with collaborators
- **Export Options**: Export character data to various formats
- **Advanced Analytics**: More detailed character statistics
- **Character Images**: Add character portraits and images

## Support

For issues or questions about the character database:

1. Check this documentation
2. Verify Fountain format syntax
3. Test with a simple screenplay first
4. Check that all files are properly included in the project

The character database is designed to work seamlessly with the Fountain screenplay editor, providing comprehensive character management tools to enhance your writing workflow. 