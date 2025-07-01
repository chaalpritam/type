# Modular Architecture Documentation

## Overview

This document describes the modular architecture implemented for the Type screenplay writing app. The new architecture provides better separation of concerns, improved maintainability, and enhanced scalability.

## Architecture Principles

### 1. Separation of Concerns
- **Core**: Central coordination and app-level state management
- **Features**: Individual feature modules with their own coordinators
- **Services**: Shared business logic and data management
- **UI**: Presentation layer components
- **Data**: Shared data models and structures

### 2. Coordinator Pattern
Each feature module has its own coordinator that:
- Manages the module's state
- Handles business logic
- Coordinates with other modules through the app coordinator
- Provides a clean interface for the UI layer

### 3. Service Layer
Centralized services handle:
- Document management
- Settings and preferences
- Data persistence
- Cross-module communication

## Directory Structure

```
type/
├── Core/                          # Core architecture components
│   ├── AppCoordinator.swift       # Main app coordinator
│   └── ModuleCoordinator.swift    # Base coordinator protocol
├── Features/                      # Feature modules
│   ├── Editor/                    # Text editor functionality
│   │   └── EditorCoordinator.swift
│   ├── Characters/                # Character management
│   │   └── CharacterCoordinator.swift
│   ├── Outline/                   # Outline and structure
│   │   └── OutlineCoordinator.swift
│   ├── Collaboration/             # Real-time collaboration
│   │   └── CollaborationCoordinator.swift
│   └── File/                      # File operations
│       └── FileCoordinator.swift
├── Services/                      # Shared services
│   ├── DocumentService.swift      # Document management
│   └── SettingsService.swift      # App settings
├── Data/                          # Shared data models
│   └── ScreenplayDocument.swift   # Document model
├── UI/                            # Presentation layer
│   └── ModularAppView.swift       # Main app view
└── Shared/                        # Shared utilities and components
```

## Module Descriptions

### Core Module
- **AppCoordinator**: Central coordinator that manages app state and coordinates between modules
- **ModuleCoordinator**: Base protocol for all module coordinators

### Editor Module
- **EditorCoordinator**: Manages text editing, Fountain parsing, and editor-specific features
- Features: Text editing, syntax highlighting, auto-completion, smart formatting

### Character Module
- **CharacterCoordinator**: Manages character database and character-related operations
- Features: Character creation, editing, analysis, relationship tracking

### Outline Module
- **OutlineCoordinator**: Manages story structure and outline functionality
- Features: Scene organization, story beats, plot structure

### Collaboration Module
- **CollaborationCoordinator**: Manages real-time collaboration features
- Features: Comments, version control, sharing, multi-user editing

### File Module
- **FileCoordinator**: Manages file operations and document handling
- Features: Save, load, export, import, auto-save

## Service Layer

### DocumentService
- Centralized document management
- Auto-save functionality
- Recent files tracking
- Document state management

### SettingsService
- App-wide settings management
- User preferences
- Configuration persistence
- Settings synchronization

## Data Flow

1. **User Action**: User interacts with UI component
2. **UI Layer**: UI component calls coordinator method
3. **Coordinator**: Coordinator processes business logic
4. **Service Layer**: Coordinator updates services if needed
5. **State Update**: Services update their published properties
6. **UI Update**: UI automatically updates via SwiftUI bindings

## Benefits

### 1. Maintainability
- Clear separation of concerns
- Modular code organization
- Easier to locate and fix issues
- Reduced coupling between components

### 2. Scalability
- Easy to add new features
- Independent module development
- Clear interfaces between modules
- Reusable components

### 3. Testability
- Isolated business logic
- Mockable dependencies
- Clear unit boundaries
- Easier to write unit tests

### 4. Team Development
- Parallel development on different modules
- Clear ownership boundaries
- Reduced merge conflicts
- Consistent architecture patterns

## Migration Guide

### From Monolithic to Modular

1. **Extract Services**: Move business logic to service classes
2. **Create Coordinators**: Implement coordinators for each feature
3. **Update UI**: Replace direct service calls with coordinator calls
4. **Test Integration**: Ensure modules work together correctly

### Best Practices

1. **Single Responsibility**: Each coordinator handles one feature area
2. **Dependency Injection**: Pass dependencies through initializers
3. **Protocol-Oriented**: Use protocols for better testability
4. **Error Handling**: Centralize error handling in services
5. **State Management**: Use published properties for reactive updates

## Future Enhancements

1. **Plugin System**: Allow third-party modules
2. **Cloud Sync**: Centralized data synchronization
3. **Offline Support**: Local-first architecture
4. **Performance Optimization**: Lazy loading and caching
5. **Accessibility**: Enhanced accessibility support

## Conclusion

The modular architecture provides a solid foundation for the Type app's continued development. It enables better code organization, improved maintainability, and enhanced scalability while maintaining a clean and intuitive user experience. 