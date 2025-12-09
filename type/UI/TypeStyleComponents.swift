//
//  TypeStyleComponents.swift
//  type
//
//  Minimalistic UI components for Type screenwriting app
//  Clean, elegant, distraction-free design
//

import SwiftUI
import AppKit

// MARK: - Type-Style Minimal Toolbar
struct TypeToolbar: View {
    @Environment(\.colorScheme) var colorScheme
    
    // File operations
    let onNewDocument: () -> Void
    let onOpenDocument: () -> Void
    let onSaveDocument: () -> Void
    let canSave: Bool
    let isDocumentModified: Bool
    
    // Edit operations
    let canUndo: Bool
    let canRedo: Bool
    let onUndo: () -> Void
    let onRedo: () -> Void
    
    // View toggles
    @Binding var showPreview: Bool
    @Binding var showOutline: Bool
    @Binding var showCharacters: Bool
    @Binding var isFocusMode: Bool
    @Binding var isDarkMode: Bool
    
    // Search
    let onToggleFindReplace: () -> Void
    let showFindReplace: Bool
    
    var body: some View {
        HStack(spacing: TypeSpacing.toolbarGroupSpacing) {
            // Leading: File operations
            HStack(spacing: TypeSpacing.toolbarItemSpacing) {
                TypeToolbarButton(icon: "doc.badge.plus", tooltip: "New Document") {
                    onNewDocument()
                }
                
                TypeToolbarButton(icon: "folder", tooltip: "Open Document") {
                    onOpenDocument()
                }
                
                TypeToolbarButton(
                    icon: "square.and.arrow.down",
                    tooltip: "Save Document",
                    isActive: isDocumentModified
                ) {
                    onSaveDocument()
                }
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.5)
            }
            
            TypeToolbarDivider()
            
            // Edit operations
            HStack(spacing: TypeSpacing.toolbarItemSpacing) {
                TypeToolbarButton(icon: "arrow.uturn.backward", tooltip: "Undo") {
                    onUndo()
                }
                .disabled(!canUndo)
                .opacity(canUndo ? 1 : 0.5)
                
                TypeToolbarButton(icon: "arrow.uturn.forward", tooltip: "Redo") {
                    onRedo()
                }
                .disabled(!canRedo)
                .opacity(canRedo ? 1 : 0.5)
                
                TypeToolbarButton(
                    icon: "magnifyingglass",
                    tooltip: "Find & Replace",
                    isActive: showFindReplace
                ) {
                    onToggleFindReplace()
                }
            }
            
            Spacer()
            
            // Center: View mode indicators (subtle)
            HStack(spacing: TypeSpacing.md) {
                if isFocusMode {
                    Text("Focus Mode")
                        .font(TypeTypography.caption)
                        .foregroundColor(TypeColors.accent)
                }
            }
            
            Spacer()
            
            // Trailing: View toggles
            HStack(spacing: TypeSpacing.toolbarItemSpacing) {
                TypeToolbarButton(
                    icon: "list.bullet.indent",
                    tooltip: "Outline",
                    isActive: showOutline
                ) {
                    withAnimation(TypeAnimation.standard) {
                        showOutline.toggle()
                    }
                }
                
                TypeToolbarButton(
                    icon: "person.2",
                    tooltip: "Characters",
                    isActive: showCharacters
                ) {
                    withAnimation(TypeAnimation.standard) {
                        showCharacters.toggle()
                    }
                }
                
                TypeToolbarButton(
                    icon: "eye",
                    tooltip: "Preview",
                    isActive: showPreview
                ) {
                    withAnimation(TypeAnimation.standard) {
                        showPreview.toggle()
                    }
                }
                
                TypeToolbarDivider()
                
                TypeToolbarButton(
                    icon: "text.quote",
                    tooltip: "Focus Mode",
                    isActive: isFocusMode
                ) {
                    withAnimation(TypeAnimation.smooth) {
                        isFocusMode.toggle()
                    }
                }
                
                TypeToolbarButton(
                    icon: colorScheme == .dark ? "sun.max" : "moon",
                    tooltip: colorScheme == .dark ? "Light Mode" : "Dark Mode",
                    isActive: false
                ) {
                    withAnimation(TypeAnimation.standard) {
                        isDarkMode.toggle()
                    }
                }
            }
        }
        .padding(.horizontal, TypeSpacing.md)
        .frame(height: TypeSpacing.toolbarHeight)
        .background(backgroundColor)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(dividerColor),
            alignment: .bottom
        )
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? TypeColors.toolbarBackgroundDark : TypeColors.toolbarBackgroundLight
    }
    
    private var dividerColor: Color {
        colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight
    }
}

// MARK: - Type Toolbar Button
struct TypeToolbarButton: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let tooltip: String
    var isActive: Bool = false
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(foregroundColor)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: TypeRadius.sm)
                        .fill(backgroundColor)
                )
        }
        .buttonStyle(.plain)
        .help(tooltip)
        .onHover { hovering in
            withAnimation(TypeAnimation.quick) {
                isHovered = hovering
            }
        }
    }
    
    private var foregroundColor: Color {
        if isActive {
            return TypeColors.accent
        }
        return colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight
    }
    
    private var backgroundColor: Color {
        if isActive {
            return TypeColors.accent.opacity(0.12)
        }
        if isHovered {
            return colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04)
        }
        return .clear
    }
}

// MARK: - Type Toolbar Divider
struct TypeToolbarDivider: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Rectangle()
            .fill(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight)
            .frame(width: 1, height: 18)
    }
}

// MARK: - Type-Style Sidebar
struct TypeSidebar: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedView: AppView
    @Binding var isCollapsed: Bool
    
    // Statistics
    let wordCount: Int
    let pageCount: Int
    let sceneCount: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation items
            VStack(spacing: TypeSpacing.xxs) {
                ForEach(AppView.allCases, id: \.self) { view in
                    TypeSidebarItem(
                        icon: view.icon,
                        title: view.rawValue,
                        isSelected: selectedView == view,
                        isCollapsed: isCollapsed
                    ) {
                        withAnimation(TypeAnimation.standard) {
                            selectedView = view
                        }
                    }
                }
            }
            .padding(.top, TypeSpacing.md)
            .padding(.horizontal, TypeSpacing.sm)
            
            Spacer()
            
            // Stats section (only when expanded)
            if !isCollapsed {
                VStack(spacing: TypeSpacing.sm) {
                    Divider()
                        .padding(.horizontal, TypeSpacing.md)
                    
                    TypeSidebarStats(
                        wordCount: wordCount,
                        pageCount: pageCount,
                        sceneCount: sceneCount
                    )
                }
                .padding(.bottom, TypeSpacing.md)
            }
            
            // Collapse toggle
            Button(action: {
                withAnimation(TypeAnimation.spring) {
                    isCollapsed.toggle()
                }
            }) {
                Image(systemName: isCollapsed ? "sidebar.right" : "sidebar.left")
                    .font(.system(size: 12))
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .padding(.bottom, TypeSpacing.sm)
        }
        .frame(width: isCollapsed ? 48 : TypeSpacing.sidebarWidth)
        .background(backgroundColor)
        .overlay(
            Rectangle()
                .frame(width: 0.5)
                .foregroundColor(dividerColor),
            alignment: .trailing
        )
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight
    }
    
    private var dividerColor: Color {
        colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight
    }
}

// MARK: - Type Sidebar Item
struct TypeSidebarItem: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    let isSelected: Bool
    let isCollapsed: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: TypeSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: TypeSpacing.sidebarIconSize, weight: isSelected ? .medium : .regular))
                    .foregroundColor(foregroundColor)
                    .frame(width: 20)
                
                if !isCollapsed {
                    Text(title)
                        .font(TypeTypography.subheadline)
                        .foregroundColor(foregroundColor)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, TypeSpacing.sm)
            .frame(height: TypeSpacing.sidebarItemHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: TypeRadius.sm)
                    .fill(backgroundColor)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(TypeAnimation.quick) {
                isHovered = hovering
            }
        }
    }
    
    private var foregroundColor: Color {
        if isSelected {
            return TypeColors.accent
        }
        return colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return TypeColors.accent.opacity(0.12)
        }
        if isHovered {
            return colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.04)
        }
        return .clear
    }
}

// MARK: - Type Sidebar Stats
struct TypeSidebarStats: View {
    @Environment(\.colorScheme) var colorScheme
    let wordCount: Int
    let pageCount: Int
    let sceneCount: Int
    
    var body: some View {
        VStack(spacing: TypeSpacing.xs) {
            TypeStatRow(label: "Words", value: "\(wordCount)")
            TypeStatRow(label: "Pages", value: "\(pageCount)")
            TypeStatRow(label: "Scenes", value: "\(sceneCount)")
        }
        .padding(.horizontal, TypeSpacing.md)
    }
}

// MARK: - Type Stat Row
struct TypeStatRow: View {
    @Environment(\.colorScheme) var colorScheme
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(TypeTypography.caption)
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            
            Spacer()
            
            Text(value)
                .font(TypeTypography.caption)
                .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
        }
    }
}

// MARK: - Type-Style Status Bar
struct TypeStatusBar: View {
    @Environment(\.colorScheme) var colorScheme
    
    let documentName: String
    let isModified: Bool
    let wordCount: Int
    let pageCount: Int
    let cursorPosition: String
    let isAutoSaveEnabled: Bool
    
    var body: some View {
        HStack(spacing: TypeSpacing.lg) {
            // Left: Document info
            HStack(spacing: TypeSpacing.sm) {
                // Modified indicator
                if isModified {
                    Circle()
                        .fill(TypeColors.warning)
                        .frame(width: 6, height: 6)
                }
                
                Text(documentName)
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Right: Stats
            HStack(spacing: TypeSpacing.md) {
                Text("\(wordCount) words")
                    .font(TypeTypography.caption2)
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                
                Text("Page \(pageCount)")
                    .font(TypeTypography.caption2)
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                
                Text(cursorPosition)
                    .font(TypeTypography.caption2)
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                
                // Auto-save indicator
                if isAutoSaveEnabled {
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 9))
                            .foregroundColor(TypeColors.success)
                        Text("Saved")
                            .font(TypeTypography.caption2)
                            .foregroundColor(TypeColors.success)
                    }
                }
            }
        }
        .padding(.horizontal, TypeSpacing.md)
        .frame(height: TypeSpacing.statusBarHeight)
        .background(backgroundColor)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(dividerColor),
            alignment: .top
        )
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight
    }
    
    private var dividerColor: Color {
        colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight
    }
}

// MARK: - Type-Style Find/Replace Bar
struct TypeFindReplaceBar: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isVisible: Bool
    @Binding var searchText: String
    @Binding var replaceText: String
    let resultCount: Int
    let currentResult: Int
    let onFindNext: () -> Void
    let onFindPrevious: () -> Void
    let onReplace: () -> Void
    let onReplaceAll: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: TypeSpacing.md) {
                // Find field
                HStack(spacing: TypeSpacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 11))
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                    
                    TextField("Find", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(TypeTypography.body)
                    
                    if !searchText.isEmpty {
                        Text("\(currentResult)/\(resultCount)")
                            .font(TypeTypography.caption2)
                            .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                    }
                }
                .padding(.horizontal, TypeSpacing.sm)
                .frame(height: 26)
                .background(
                    RoundedRectangle(cornerRadius: TypeRadius.sm)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                )
                .frame(maxWidth: 240)
                
                // Replace field
                HStack(spacing: TypeSpacing.sm) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11))
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                    
                    TextField("Replace", text: $replaceText)
                        .textFieldStyle(.plain)
                        .font(TypeTypography.body)
                }
                .padding(.horizontal, TypeSpacing.sm)
                .frame(height: 26)
                .background(
                    RoundedRectangle(cornerRadius: TypeRadius.sm)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                )
                .frame(maxWidth: 200)
                
                // Navigation buttons
                HStack(spacing: TypeSpacing.xs) {
                    TypeToolbarButton(icon: "chevron.up", tooltip: "Previous") {
                        onFindPrevious()
                    }
                    TypeToolbarButton(icon: "chevron.down", tooltip: "Next") {
                        onFindNext()
                    }
                }
                
                // Replace buttons
                HStack(spacing: TypeSpacing.xs) {
                    Button("Replace") {
                        onReplace()
                    }
                    .font(TypeTypography.caption)
                    .typeButton(style: .secondary, size: .small)
                    
                    Button("All") {
                        onReplaceAll()
                    }
                    .font(TypeTypography.caption)
                    .typeButton(style: .secondary, size: .small)
                }
                
                Spacer()
                
                // Close button
                Button(action: { isVisible = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                }
                .buttonStyle(.plain)
                .frame(width: 20, height: 20)
            }
            .padding(.horizontal, TypeSpacing.md)
            .padding(.vertical, TypeSpacing.sm)
            .background(backgroundColor)
        }
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(dividerColor),
            alignment: .bottom
        )
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? TypeColors.toolbarBackgroundDark : TypeColors.toolbarBackgroundLight
    }
    
    private var dividerColor: Color {
        colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight
    }
}

// MARK: - Type-Style Empty State
struct TypeEmptyState: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: TypeSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .thin))
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            
            VStack(spacing: TypeSpacing.xs) {
                Text(title)
                    .font(TypeTypography.headline)
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                Text(message)
                    .font(TypeTypography.body)
                    .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                    .multilineTextAlignment(.center)
            }
            
            if let buttonTitle = buttonTitle, let action = buttonAction {
                Button(buttonTitle) {
                    action()
                }
                .typeButton(style: .primary, size: .medium)
            }
        }
        .frame(maxWidth: 300)
    }
}

// MARK: - Type-Style Progress Indicator
struct TypeProgressIndicator: View {
    @Environment(\.colorScheme) var colorScheme
    var progress: Double? = nil  // nil for indeterminate
    
    var body: some View {
        if let progress = progress {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.08))
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(TypeColors.accent)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 3)
        } else {
            ProgressView()
                .progressViewStyle(.linear)
                .tint(TypeColors.accent)
        }
    }
}

// MARK: - Preview
#Preview("Type Toolbar") {
    VStack(spacing: 0) {
        TypeToolbar(
            onNewDocument: {},
            onOpenDocument: {},
            onSaveDocument: {},
            canSave: true,
            isDocumentModified: true,
            canUndo: true,
            canRedo: false,
            onUndo: {},
            onRedo: {},
            showPreview: .constant(false),
            showOutline: .constant(true),
            showCharacters: .constant(false),
            isFocusMode: .constant(false),
            isDarkMode: .constant(false),
            onToggleFindReplace: {},
            showFindReplace: false
        )
        
        Spacer()
    }
    .frame(width: 800, height: 100)
}

#Preview("Type Sidebar") {
    HStack(spacing: 0) {
        TypeSidebar(
            selectedView: .constant(.editor),
            isCollapsed: .constant(false),
            wordCount: 1234,
            pageCount: 12,
            sceneCount: 8
        )
        
        Spacer()
    }
    .frame(width: 400, height: 500)
}

#Preview("Type Status Bar") {
    VStack {
        Spacer()
        TypeStatusBar(
            documentName: "My Screenplay.fountain",
            isModified: true,
            wordCount: 12543,
            pageCount: 98,
            cursorPosition: "Line 234, Col 12",
            isAutoSaveEnabled: true
        )
    }
    .frame(width: 800, height: 100)
}
