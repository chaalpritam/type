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

## Built With

- **SwiftUI**: Modern macOS interface
- **Fountain Format**: Industry-standard screenplay markup
- **Real-time Parsing**: Instant feedback as you write

## License

MIT License - feel free to use and modify as needed.

---

**Happy screenwriting!** 🎬✨

