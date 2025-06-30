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

### ✅ **Completed Features**

#### Core Editor & Parsing
- [x] **Simple editor features** - Basic text editing with Fountain syntax
- [x] **Real-time Fountain parsing** - Instant parsing as you type
- [x] **Live preview** - Real-time formatted screenplay preview
- [x] **Syntax highlighting** - Color-coded Fountain elements
- [x] **Split view** - Editor and preview side by side
- [x] **Toggle preview** - Show/hide formatted preview
- [x] **Help system** - Built-in Fountain syntax guide
- [x] **Professional formatting** - Proper screenplay layout and typography

#### Enhanced Editor Features
- [x] **Spell check and grammar** with screenplay-specific dictionaries
- [x] **Auto-completion** for character names, scene headings, transitions
- [x] **Smart formatting** (auto-capitalize character names, proper spacing)
- [x] **Undo/redo** with better state management
- [x] **Find and replace** functionality with regex support
- [x] **Line numbers** in editor
- [x] **Word count** and **page count** display

#### Advanced Fountain Support
- [x] **Force elements** (use `!` for forced scene headings, `@` for forced action)
- [x] **Lyrics** (`~lyrics~` for song lyrics)
- [x] **Emphasis** (`*bold*`, `_italic_`, `**bold**`, `__italic__`)
- [x] **Dual dialogue** (character names with `^`)
- [x] **Enhanced transitions** (more transition types)
- [x] **Advanced syntax highlighting** for all new elements

#### Apple-Style Professional Interface
- [x] **Apple design philosophy** - Minimal, elegant, and intuitive interface
- [x] **Translucent materials** - `.ultraThinMaterial` backgrounds for modern look
- [x] **Native macOS styling** - Uses system colors and fonts (SF Mono, Menlo)
- [x] **Subtle animations** - Smooth transitions and micro-interactions
- [x] **Apple-style toolbars** - Clean, organized with proper spacing
- [x] **Professional button styles** - Subtle hover effects and press animations
- [x] **Apple-style find/replace** - Integrated search with native styling
- [x] **Status indicators** - Green "Ready" status with dot indicator
- [x] **Full-screen toggle** - Native full-screen support
- [x] **System font integration** - SF Mono, Menlo, Monaco options
- [x] **Apple-style overlays** - Auto-completion with translucent materials
- [x] **Consistent spacing** - 8px grid system and proper margins
- [x] **Subtle shadows** - Light shadows for depth without heaviness

### 🚀 **High Priority - Core Features**

#### File Management
- [ ] **Save/Load files** - Native file operations
- [ ] **Auto-save** - Automatic backup and recovery
- [ ] **Recent files** - Quick access to recent documents
- [ ] **Export options** - PDF, Final Draft, plain text
- [ ] **Import support** - Import from other screenplay formats

#### Collaboration Features
- [ ] **Comments and notes** - Inline commenting system
- [ ] **Track changes** - Version control and change tracking
- [ ] **Collaborative editing** - Real-time multi-user editing
- [ ] **Review mode** - Read-only mode for reviewing

### 📱 **Medium Priority - Enhanced Features**

#### Advanced Editor Features
- [ ] **Multiple cursors** - Batch editing capabilities
- [ ] **Code folding** - Collapse/expand sections
- [ ] **Bookmarks** - Quick navigation to important sections
- [ ] **Split editor** - Multiple editor panes
- [ ] **Minimap** - Overview of document structure

#### Productivity Features
- [ ] **Templates** - Pre-built screenplay templates
- [ ] **Character database** - Track character information
- [ ] **Scene management** - Organize and navigate scenes
- [ ] **Timeline view** - Visual story timeline
- [ ] **Outline mode** - Hierarchical document view

#### Advanced Fountain Features
- [ ] **Custom elements** - User-defined Fountain elements
- [ ] **Macros** - Custom formatting shortcuts
- [ ] **Plugins** - Extensible functionality
- [ ] **Advanced metadata** - Extended title page support

### 🎨 **Low Priority - Polish & Enhancement**

#### UI/UX Improvements
- [ ] **Dark mode** - Complete dark theme support
- [ ] **Custom themes** - User-defined color schemes
- [ ] **Keyboard shortcuts** - Comprehensive shortcut system
- [ ] **Touch bar support** - macOS Touch Bar integration
- [ ] **Accessibility** - VoiceOver and accessibility features

#### Platform Expansion
- [ ] **iOS version** - iPad and iPhone support
- [ ] **Web version** - Browser-based editor
- [ ] **Windows/Linux** - Cross-platform support

#### Advanced Features
- [ ] **AI assistance** - Smart writing suggestions
- [ ] **Voice dictation** - Speech-to-text support
- [ ] **Screenplay analysis** - Readability and structure analysis
- [ ] **Industry integration** - Connect with production software

## Built With

- **SwiftUI**: Modern macOS interface
- **Fountain Format**: Industry-standard screenplay markup
- **Real-time Parsing**: Instant feedback as you write

## License

MIT License - feel free to use and modify as needed.

---

**Happy screenwriting!** 🎬✨

