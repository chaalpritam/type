//
//  TemplateSelectorView.swift
//  type
//
//  Enhanced template selector view migrated from ContentView.swift
//

import SwiftUI

// MARK: - Template Selector View
struct TemplateSelectorView: View {
    @Binding var selectedTemplate: TemplateType
    @Binding var isVisible: Bool
    let onTemplateSelected: (TemplateType) -> Void
    
    @State private var selectedCategory: TemplateCategory = .basic
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isVisible = false
                }
            
            // Template selector card
            VStack(spacing: 20) {
                // Header with close button
                HStack {
                    Text("Choose Template")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: { isVisible = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                // Category selector
                Picker("Category", selection: $selectedCategory) {
                    ForEach(TemplateCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Templates grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(selectedCategory.templates, id: \.self) { template in
                            TemplateCard(
                                template: template,
                                isSelected: selectedTemplate == template,
                                onTap: {
                                    onTemplateSelected(template)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 400)
                
                // Bottom action buttons
                HStack {
                    Button("Cancel") {
                        isVisible = false
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Use Template") {
                        onTemplateSelected(selectedTemplate)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedTemplate == .default)
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 20)
            .frame(maxWidth: 600, maxHeight: 600)
        }
    }
}

struct TemplateCard: View {
    let template: TemplateType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(template.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.title3)
                    }
                }
                
                Text(template.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                // Template category badge
                Text(template.category.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.accentColor.opacity(0.1))
                    )
                    .foregroundColor(.accentColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
} 