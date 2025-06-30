# type

A modern screenplay writing app for macOS with real-time Fountain format parsing and preview.

## Features

### ✨ Real-time Fountain Parsing
- **Live Preview**: See your screenplay formatted in real-time as you type
- **Syntax Highlighting**: Fountain elements are color-coded in the editor
- **Professional Formatting**: Proper screenplay layout with correct typography and spacing

### 🎬 Fountain Format Support
- **Scene Headings**: `INT. LOCATION - TIME`
- **Character Names**: `CHARACTER NAME` (in ALL CAPS)
- **Dialogue**: Automatic formatting after character names
- **Parentheticals**: `(character direction)`
- **Transitions**: `FADE OUT`, `CUT TO:`, etc.
- **Sections**: `# ACT ONE`, `## Scene 1`
- **Title Page**: Metadata at the top of your screenplay
- **Notes**: `[[private notes]]` (not shown in final output)
- **Synopsis**: `= synopsis text` (not shown in final output)
- **Centered Text**: `> centered text <`
- **Page Breaks**: `===`

### 🎨 Beautiful Interface
- **Split View**: Editor and preview side by side
- **A4 Paper Style**: Professional screenplay appearance
- **Toggle Preview**: Hide/show the formatted preview
- **Help System**: Built-in Fountain syntax guide

## Getting Started

1. **Write in Fountain**: Use standard Fountain syntax in the editor
2. **See Live Preview**: Watch your screenplay format in real-time
3. **Toggle Views**: Use the eye icon to show/hide the preview
4. **Get Help**: Click the question mark for Fountain syntax guide

## Example Fountain Script

```
Title: My First Screenplay
Author: Your Name
Draft: First Draft
:

# ACT ONE

= This is the beginning of our story

INT. COFFEE SHOP - DAY

Sarah sits at a corner table, typing furiously on her laptop.

SARAH
(without looking up)
I can't believe I'm finally writing this screenplay.

MIKE
(approaching)
Hey, Sarah! How's the writing going?

SARAH
(looking up, surprised)
Mike! I didn't expect to see you here.

> THE END <
```

## Fountain Syntax Reference

| Element | Syntax | Example |
|---------|--------|---------|
| Scene Heading | `INT./EXT. LOCATION - TIME` | `INT. COFFEE SHOP - DAY` |
| Character | `ALL CAPS NAME` | `SARAH` |
| Dialogue | Text after character name | `Hello, world!` |
| Parenthetical | `(direction)` | `(without looking up)` |
| Transition | `TRANSITION TYPE` | `FADE OUT` |
| Section | `# Section Name` | `# ACT ONE` |
| Note | `[[note]]` | `[[private note]]` |
| Synopsis | `= synopsis` | `= This is the beginning` |
| Centered | `> text <` | `> THE END <` |

## TODO: Building Better

### 🚀 **High Priority - Core Features**

#### File Management & Persistence
- [ ] **Save/Load functionality** with native macOS file dialogs
- [ ] **Auto-save** with configurable intervals (every 30 seconds)
- [ ] **Recent files** menu in app menu
- [ ] **Export to PDF** with proper screenplay formatting
- [ ] **Export to Final Draft** (.fdx) format
- [ ] **Export to plain text** (.fountain) format
- [ ] **iCloud sync** for seamless cross-device access

#### Enhanced Editor Features
- [ ] **Spell check and grammar** with screenplay-specific dictionaries
- [ ] **Auto-completion** for character names, scene headings, transitions
- [ ] **Smart formatting** (auto-capitalize character names, proper spacing)
- [ ] **Undo/redo** with better state management
- [ ] **Find and replace** functionality with regex support
- [ ] **Multiple cursors** for batch editing
- [ ] **Line numbers** in editor
- [ ] **Word count** and **page count** display

#### Advanced Fountain Support
- [ ] **Force elements** (use `!` for forced scene headings, `@` for forced action)
- [ ] **Lyrics** support (`~lyrics~`)
- [ ] **Emphasis** (`*bold*`, `_italic_`)
- [ ] **Line breaks** within dialogue (`\`)
- [ ] **Dual dialogue** support
- [ ] **More transition types** (SMASH CUT, JUMP CUT, etc.)
- [ ] **Better syntax highlighting** with more accurate parsing

### 🎨 **Medium Priority - UI/UX Enhancements**

#### Professional Screenplay Features
- [ ] **Page numbering** with proper screenplay margins
- [ ] **Scene numbering** (automatic or manual toggle)
- [ ] **Character tracking** (who appears in which scenes)
- [ ] **Revision tracking** (highlight changes between drafts)
- [ ] **Production notes** (budget, scheduling info)
- [ ] **Script statistics** (page count, word count, scene count, character count)

#### Better Interface
- [ ] **Customizable themes** (dark mode, different paper styles)
- [ ] **Font options** (Courier Prime, Courier New, etc.)
- [ ] **Zoom controls** for both editor and preview
- [ ] **Full-screen writing mode** (distraction-free)
- [ ] **Split-screen** with multiple documents
- [ ] **Tabbed interface** for multiple scripts
- [ ] **Customizable toolbar** with frequently used actions

#### Writing Tools
- [ ] **Outline view** (collapsible sections and scenes)
- [ ] **Character bible** (character descriptions, arcs, relationships)
- [ ] **Story structure templates** (3-act, 5-act, hero's journey)
- [ ] **Writing prompts** and exercises
- [ ] **Timer/pomodoro** for focused writing sessions
- [ ] **Writing goals** (daily word/page targets)

### 🔧 **Lower Priority - Advanced Features**

#### Performance & Architecture
- [ ] **Lazy loading** for large documents
- [ ] **Background parsing** to prevent UI blocking
- [ ] **Memory management** for long writing sessions
- [ ] **Modular architecture** with better separation of concerns
- [ ] **Unit tests** for the parser and core functionality
- [ ] **Performance profiling** and optimization

#### Collaboration Features
- [ ] **Comments and annotations** system
- [ ] **Track changes** mode with diff view
- [ ] **Version control** (Git integration)
- [ ] **Sharing** via email, AirDrop, or cloud services
- [ ] **Real-time collaboration** (like Google Docs)
- [ ] **Review mode** for feedback

#### Accessibility & Platform Support
- [ ] **VoiceOver** support for screen readers
- [ ] **Keyboard shortcuts** for all actions
- [ ] **High contrast mode** for accessibility
- [ ] **Font scaling** for vision accessibility
- [ ] **iOS version** for iPad writing
- [ ] **Web version** for cross-platform access

#### Advanced Analysis & Integration
- [ ] **Script analysis** (readability scores, pacing analysis)
- [ ] **Industry standards** compliance checking
- [ ] **Template library** (TV pilots, feature films, shorts)
- [ ] **Script comparison** tools
- [ ] **Production scheduling** integration
- [ ] **Watch companion** for quick notes and ideas

### 🎯 **Quick Wins (1-2 days each)**
- [ ] Add word count display in toolbar
- [ ] Implement basic save/load with file picker
- [ ] Add keyboard shortcuts (Cmd+S, Cmd+O, Cmd+N)
- [ ] Improve syntax highlighting accuracy
- [ ] Add "New Document" functionality
- [ ] Implement basic undo/redo
- [ ] Add export to plain text (.fountain)

### 📋 **Future Roadmap**
- [ ] **Version 2.0**: Full file management and export
- [ ] **Version 2.1**: Collaboration features
- [ ] **Version 2.2**: Advanced analysis tools
- [ ] **Version 3.0**: Multi-platform support (iOS, web)

## Built With

- **SwiftUI**: Modern macOS interface
- **Fountain Format**: Industry-standard screenplay markup
- **Real-time Parsing**: Instant feedback as you write

## License

MIT License - feel free to use and modify as needed.

---

**Happy screenwriting!** 🎬✨

