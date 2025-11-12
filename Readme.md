# type

A modern screenplay writing app for macOS with real-time Fountain format parsing and preview.

![type app image](./cover.png)

## Features

## Documentation

All detailed documentation has been moved to the `docs/` directory:

- [`docs/COMPREHENSIVE_DOCUMENTATION.md`](docs/COMPREHENSIVE_DOCUMENTATION.md) – Full project overview
- [`docs/MODULAR_ARCHITECTURE.md`](docs/MODULAR_ARCHITECTURE.md) & [`docs/MODULAR_IMPLEMENTATION_SUMMARY.md`](docs/MODULAR_IMPLEMENTATION_SUMMARY.md) – Architecture notes
- [`docs/ADVANCED_EDITOR_FEATURES_SUMMARY.md`](docs/ADVANCED_EDITOR_FEATURES_SUMMARY.md) – Editor feature breakdown
- [`docs/BEAT_ANALYSIS_AND_IMPROVEMENTS.md`](docs/BEAT_ANALYSIS_AND_IMPROVEMENTS.md) – Beat-specific research/notes
- [`docs/CHARACTER_DATABASE_README.md`](docs/CHARACTER_DATABASE_README.md) – Character database guide
- [`docs/IMPROVEMENT_TODO.md`](docs/IMPROVEMENT_TODO.md) – Backlog of improvement ideas

Refer to that folder for additional references and guides.

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

#### Advanced UI/UX Improvements
- [x] **Light mode only** - App always stays in light mode for consistent appearance
- [x] **Advanced animations** - Spring animations with configurable speed
- [x] **Customization panel** - Animation speed controls
- [x] **Writing goals** - Daily word count targets with progress visualization
- [x] **Enhanced visual feedback** - Improved button states and interactions
- [x] **Smooth transitions** - Panel animations and state changes
- [x] **Progress indicators** - Visual progress bars for writing goals
- [x] **Light theme styling** - Optimized colors and shadows for light mode
- [x] **Customizable animations** - Slow/Normal/Fast animation speed options
- [x] **Enhanced statistics** - Better organized and more informative displays

#### File Management & Persistence
- [x] **Save/Load files** - Native macOS file dialogs with proper permissions
- [x] **Auto-save** - Automatic backup every 30 seconds with recovery
- [x] **Recent files** - Quick access to recently opened documents
- [x] **Export options** - PDF with proper screenplay formatting
- [x] **Export to Final Draft** (.fdx) format compatibility (basic)
- [x] **Export to plain text** (.fountain) format

#### Keyboard Shortcuts & Accessibility
- [x] **Comprehensive shortcuts** - Cmd+S, Cmd+O, Cmd+N, Cmd+F, etc.

### 🚀 **High Priority - Next Phase**

#### File Management & Cloud
- [ ] **iCloud sync** - Seamless cross-device document access
- [ ] **Export improvements** - Advanced PDF/FDX export, custom templates

#### Advanced Editor Features
- [ ] **Multiple cursors** - Batch editing capabilities for efficiency
- [ ] **Code folding** - Collapse/expand sections and scenes
- [ ] **Bookmarks** - Quick navigation to important sections
- [ ] **Split editor** - Multiple editor panes for comparison
- [ ] **Minimap** - Overview of document structure

#### Collaboration Features
- [x] **Real-time collaboration manager** (user management, online users)
- [x] **Comments & replies** (add, resolve, delete, reply)
- [x] **Version control** (create, restore, compare versions)
- [x] **Sharing & invites** (invite by email, roles, permissions)
- [x] **Apple-style UI panels** for comments, version history, collaborators, sharing
- [x] **Toolbar integration** for collaboration controls

### 📱 **Medium Priority - Enhanced Features**

#### Productivity Features
- [x] **Templates** - Pre-built screenplay templates (TV pilots, features, shorts)
- [x] **Character database** - Track character information and arcs
- [x] **Scene management** - Organize and navigate scenes efficiently
- [x] **Timeline view** - Visual story timeline and structure
- [x] **Outline mode** - Hierarchical document view

#### Advanced Fountain Features
- [ ] **Custom elements** - User-defined Fountain elements
- [ ] **Macros** - Custom formatting shortcuts and automation
- [ ] **Plugins** - Extensible functionality system
- [ ] **Advanced metadata** - Extended title page and production info

### 🎨 **Low Priority - Polish & Enhancement**

#### UI/UX Improvements
- [ ] **Custom themes** - User-defined color schemes and styling
- [ ] **Advanced animations** - More sophisticated transitions and effects
- [ ] **Customizable toolbars** - User-configurable button layouts
- [ ] **Advanced statistics** - Detailed writing analytics and insights
- [ ] **Writing goals** - Daily word/page targets with progress tracking

#### Platform Expansion
- [ ] **iOS version** - iPad and iPhone support with iCloud sync
- [ ] **Web version** - Browser-based editor for cross-platform access
- [ ] **Windows/Linux** - Cross-platform support (future consideration)

#### Advanced Features
- [ ] **AI assistance** - Smart writing suggestions and analysis
- [ ] **Voice dictation** - Speech-to-text support for hands-free writing
- [ ] **Screenplay analysis** - Readability scores and structure analysis
- [ ] **Industry integration** - Connect with production software and services
- [ ] **Version control** - Git integration for script versioning

### 🔧 **Technical Improvements**

#### Performance & Architecture
- [ ] **Lazy loading** - Optimize large document performance
- [ ] **Background parsing** - Prevent UI blocking during syntax analysis
- [ ] **Memory management** - Optimize for long writing sessions
- [ ] **Unit tests** - Comprehensive testing for parser and core functionality
- [ ] **Performance profiling** - Identify and fix bottlenecks

#### Code Quality
- [ ] **Modular architecture** - Better separation of concerns
- [ ] **Documentation** - Comprehensive code documentation
- [ ] **Error handling** - Robust error handling and user feedback
- [ ] **Localization** - Multi-language support
- [ ] **Security** - Enhanced file handling and data protection

### 📋 **Quick Wins (1-2 days each)**
- [x] ✅ Apple-style interface redesign
- [x] ✅ Professional toolbar and status bar
- [x] ✅ Advanced Fountain syntax support
- [x] ✅ Enhanced editor features
- [x] ✅ Light mode only - consistent appearance
- [x] ✅ Advanced animations and transitions
- [x] ✅ Writing goals and progress tracking
- [x] ✅ Basic save/load with file picker
- [x] ✅ Keyboard shortcuts (Cmd+S, Cmd+O, Cmd+N)
- [x] ✅ Export to PDF functionality
- [x] ✅ Auto-save implementation
- [x] ✅ Recent files menu

### 🎯 **Development Phases**

#### **Phase 1: Foundation (✅ Complete)**
- Core editor and parsing
- Apple-style interface
- Advanced UI/UX improvements
- Enhanced editor features

#### **Phase 2: File Management (✅ Complete)**
- Save/Load functionality
- Export capabilities
- Auto-save and recovery
- Recent files management
- Keyboard shortcuts

#### **Phase 3: Advanced Features (🚀 Current Priority)**
- iCloud sync
- Advanced export
- Multiple cursors and code folding
- Collaboration features
- Templates and productivity tools
- Advanced Fountain support

#### **Phase 4: Platform Expansion**
- iOS version
- Web version
- Advanced integrations
- AI assistance

### 📊 **Progress Summary**
- **Core Features**: 100% Complete ✅
- **UI/UX**: 100% Complete ✅
- **File Management**: 100% Complete ✅
- **Advanced Features**: 10% Complete 🚀
- **Platform Expansion**: 0% Complete 🎨

**Next Milestone**: Cloud sync, advanced export, and collaboration features.

### 🎯 **Future Roadmap**
- **Version 2.0**: Complete file management and export capabilities
- **Version 2.1**: Collaboration features and real-time editing
- **Version 2.2**: Advanced analysis tools and AI assistance
- **Version 3.0**: Multi-platform support (iOS, web)
- **Version 3.1**: Industry integration and professional features

## Built With

- **SwiftUI**: Modern macOS interface
- **Fountain Format**: Industry-standard screenplay markup
- **Real-time Parsing**: Instant feedback as you write

## License

MIT License - feel free to use and modify as needed.

---

**Happy screenwriting!** 🎬✨

