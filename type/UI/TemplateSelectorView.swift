//
//  TemplateSelectorView.swift
//  type
//
//  Enhanced template selector view with Type styling
//

import SwiftUI

// MARK: - Template Selector View
struct TemplateSelectorView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedTemplate: TemplateType
    @Binding var isVisible: Bool
    let onTemplateSelected: (TemplateType) -> Void
    
    @State private var selectedCategory: TemplateCategory = .basic
    @State private var hoveredTemplate: TemplateType?
    @State private var previewTemplate: TemplateType?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: TypeSpacing.xxs) {
                    Text("Choose a Template")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    
                    Text("Start your screenplay with a professional structure")
                        .font(TypeTypography.caption)
                        .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                }
                
                Spacer()
                
                Button(action: { isVisible = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                }
                .buttonStyle(.plain)
            }
            .padding(TypeSpacing.lg)
            .background(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight),
                alignment: .bottom
            )
            
            HStack(spacing: 0) {
                // Categories sidebar
                VStack(alignment: .leading, spacing: TypeSpacing.xs) {
                    Text("CATEGORIES")
                        .font(TypeTypography.caption2)
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                        .tracking(0.8)
                        .padding(.horizontal, TypeSpacing.md)
                        .padding(.top, TypeSpacing.md)
                    
                    ForEach(TemplateCategory.allCases, id: \.self) { category in
                        TemplateCategoryRow(
                            category: category,
                            isSelected: selectedCategory == category,
                            count: category.templates.count
                        ) {
                            withAnimation(TypeAnimation.standard) {
                                selectedCategory = category
                            }
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: 180)
                .background(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
                .overlay(
                    Rectangle()
                        .frame(width: 0.5)
                        .foregroundColor(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight),
                    alignment: .trailing
                )
                
                // Templates list
                ScrollView {
                    LazyVStack(spacing: TypeSpacing.sm) {
                        ForEach(selectedCategory.templates, id: \.self) { template in
                            TemplateListRow(
                                template: template,
                                isSelected: selectedTemplate == template,
                                isHovered: hoveredTemplate == template
                            ) {
                                selectedTemplate = template
                            }
                            .onHover { hovering in
                                hoveredTemplate = hovering ? template : nil
                            }
                        }
                    }
                    .padding(TypeSpacing.md)
                }
                .frame(minWidth: 280)
                
                // Preview panel
                VStack(spacing: 0) {
                    if selectedTemplate != .default || hoveredTemplate != nil {
                        let template = hoveredTemplate ?? selectedTemplate
                        TemplatePreviewPanel(template: template)
                    } else {
                        TemplateEmptyPreview()
                    }
                }
                .frame(width: 300)
                .background(colorScheme == .dark ? Color.black.opacity(0.2) : Color.black.opacity(0.03))
            }
            
            // Footer
            HStack {
                Button("Cancel") {
                    isVisible = false
                }
                .font(TypeTypography.body)
                .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                .buttonStyle(.plain)
                
                Spacer()
                
                Button(action: {
                    onTemplateSelected(selectedTemplate)
                    isVisible = false
                }) {
                    Text("Use Template")
                        .font(TypeTypography.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, TypeSpacing.lg)
                        .padding(.vertical, TypeSpacing.sm)
                        .background(TypeColors.accent)
                        .cornerRadius(TypeRadius.sm)
                }
                .buttonStyle(.plain)
            }
            .padding(TypeSpacing.lg)
            .background(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight),
                alignment: .top
            )
        }
        .frame(width: 800, height: 550)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
        .cornerRadius(TypeRadius.lg)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Template Category Row
struct TemplateCategoryRow: View {
    @Environment(\.colorScheme) var colorScheme
    let category: TemplateCategory
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconForCategory(category))
                    .font(.system(size: 13))
                    .foregroundColor(isSelected ? TypeColors.accent : (colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight))
                    .frame(width: 18)
                
                Text(category.rawValue)
                    .font(TypeTypography.body)
                    .foregroundColor(isSelected ? TypeColors.accent : (colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight))
                
                Spacer()
                
                Text("\(count)")
                    .font(TypeTypography.caption2)
                    .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            }
            .padding(.horizontal, TypeSpacing.md)
            .padding(.vertical, TypeSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: TypeRadius.sm)
                    .fill(isSelected ? TypeColors.accent.opacity(0.12) : (isHovered ? (colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.03)) : .clear))
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, TypeSpacing.sm)
        .onHover { hovering in isHovered = hovering }
    }
    
    private func iconForCategory(_ category: TemplateCategory) -> String {
        switch category {
        case .basic: return "doc.text"
        case .tvPilots: return "tv"
        case .featureFilms: return "film"
        case .shortFilms: return "film.stack"
        case .stage: return "curtains.closed"
        case .other: return "doc.richtext"
        }
    }
}

// MARK: - Template List Row
struct TemplateListRow: View {
    @Environment(\.colorScheme) var colorScheme
    let template: TemplateType
    let isSelected: Bool
    let isHovered: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: TypeSpacing.md) {
                // Icon
                Image(systemName: iconForTemplate(template))
                    .font(.system(size: 18))
                    .foregroundColor(colorForTemplate(template))
                    .frame(width: 32, height: 32)
                    .background(colorForTemplate(template).opacity(0.12))
                    .cornerRadius(TypeRadius.sm)
                
                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(template.rawValue)
                        .font(TypeTypography.body)
                        .fontWeight(.medium)
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                    
                    Text(template.description)
                        .font(TypeTypography.caption)
                        .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(TypeColors.accent)
                }
            }
            .padding(TypeSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: TypeRadius.md)
                    .fill(isSelected ? TypeColors.accent.opacity(0.08) : (isHovered ? (colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.03)) : .clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: TypeRadius.md)
                    .stroke(isSelected ? TypeColors.accent.opacity(0.3) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func iconForTemplate(_ template: TemplateType) -> String {
        switch template {
        case .default, .short: return "doc.text"
        case .tvDramaPilot, .tvComedyPilot: return "tv"
        case .actionFeature: return "bolt.fill"
        case .romanticComedy: return "heart.fill"
        case .sciFiFeature: return "star.fill"
        case .shortDrama: return "theatermasks"
        case .shortComedy: return "face.smiling"
        case .horrorFeature: return "moon.fill"
        case .mysteryFeature: return "magnifyingglass"
        case .stagePlay: return "curtains.closed"
        case .podcast: return "mic.fill"
        case .documentary: return "video.fill"
        }
    }
    
    private func colorForTemplate(_ template: TemplateType) -> Color {
        switch template {
        case .default, .short: return TypeColors.accent
        case .tvDramaPilot: return TypeColors.sceneBlue
        case .tvComedyPilot: return TypeColors.sceneYellow
        case .actionFeature: return TypeColors.sceneRed
        case .romanticComedy: return TypeColors.scenePink
        case .sciFiFeature: return TypeColors.scenePurple
        case .shortDrama: return TypeColors.sceneOrange
        case .shortComedy: return TypeColors.sceneGreen
        case .horrorFeature: return TypeColors.scenePurple
        case .mysteryFeature: return TypeColors.sceneCyan
        case .stagePlay: return TypeColors.sceneRed
        case .podcast: return TypeColors.sceneYellow
        case .documentary: return TypeColors.sceneBlue
        }
    }
}

// MARK: - Template Preview Panel
struct TemplatePreviewPanel: View {
    @Environment(\.colorScheme) var colorScheme
    let template: TemplateType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: TypeSpacing.sm) {
                HStack {
                    Image(systemName: iconForTemplate(template))
                        .font(.system(size: 24))
                        .foregroundColor(colorForTemplate(template))
                    
                    Spacer()
                    
                    Text(template.category.rawValue)
                        .font(TypeTypography.caption2)
                        .foregroundColor(colorForTemplate(template))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(colorForTemplate(template).opacity(0.12))
                        .cornerRadius(TypeRadius.full)
                }
                
                Text(template.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                
                Text(template.description)
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
            }
            .padding(TypeSpacing.md)
            
            Divider()
                .background(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight)
            
            // Preview
            ScrollView {
                Text(previewText(for: template))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(TypeSpacing.md)
            }
        }
    }
    
    private func iconForTemplate(_ template: TemplateType) -> String {
        switch template {
        case .default, .short: return "doc.text"
        case .tvDramaPilot, .tvComedyPilot: return "tv"
        case .actionFeature: return "bolt.fill"
        case .romanticComedy: return "heart.fill"
        case .sciFiFeature: return "star.fill"
        case .shortDrama: return "theatermasks"
        case .shortComedy: return "face.smiling"
        case .horrorFeature: return "moon.fill"
        case .mysteryFeature: return "magnifyingglass"
        case .stagePlay: return "curtains.closed"
        case .podcast: return "mic.fill"
        case .documentary: return "video.fill"
        }
    }
    
    private func colorForTemplate(_ template: TemplateType) -> Color {
        switch template {
        case .default, .short: return TypeColors.accent
        case .tvDramaPilot: return TypeColors.sceneBlue
        case .tvComedyPilot: return TypeColors.sceneYellow
        case .actionFeature: return TypeColors.sceneRed
        case .romanticComedy: return TypeColors.scenePink
        case .sciFiFeature: return TypeColors.scenePurple
        case .shortDrama: return TypeColors.sceneOrange
        case .shortComedy: return TypeColors.sceneGreen
        case .horrorFeature: return TypeColors.scenePurple
        case .mysteryFeature: return TypeColors.sceneCyan
        case .stagePlay: return TypeColors.sceneRed
        case .podcast: return TypeColors.sceneYellow
        case .documentary: return TypeColors.sceneBlue
        }
    }
    
    private func previewText(for template: TemplateType) -> String {
        let fullContent = FountainTemplate.getTemplate(for: template)
        // Return first 1000 characters as preview
        return String(fullContent.prefix(1000)) + "\n\n..."
    }
}

// MARK: - Template Empty Preview
struct TemplateEmptyPreview: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: TypeSpacing.md) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40, weight: .thin))
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
            
            Text("Select a template")
                .font(TypeTypography.body)
                .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
            
            Text("Choose a template from the list to see a preview")
                .font(TypeTypography.caption)
                .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Template Card (Legacy support)
struct TemplateCard: View {
    @Environment(\.colorScheme) var colorScheme
    let template: TemplateType
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: TypeSpacing.sm) {
                HStack {
                    Text(template.rawValue)
                        .font(TypeTypography.headline)
                        .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(TypeColors.accent)
                            .font(.system(size: 18))
                    }
                }
                
                Text(template.description)
                    .font(TypeTypography.caption)
                    .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                Text(template.category.rawValue)
                    .font(TypeTypography.caption2)
                    .foregroundColor(TypeColors.accent)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(TypeColors.accent.opacity(0.1))
                    .cornerRadius(TypeRadius.full)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(TypeSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: TypeRadius.md)
                    .fill(isSelected ? TypeColors.accent.opacity(0.08) : (colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight))
            )
            .overlay(
                RoundedRectangle(cornerRadius: TypeRadius.md)
                    .stroke(isSelected ? TypeColors.accent : (colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight), lineWidth: isSelected ? 2 : 0.5)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovered = hovering }
    }
}
