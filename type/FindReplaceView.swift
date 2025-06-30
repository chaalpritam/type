import SwiftUI

struct FindReplaceView: View {
    @Binding var isVisible: Bool
    @Binding var text: String
    @State private var searchText: String = ""
    @State private var replaceText: String = ""
    @State private var useRegex: Bool = false
    @State private var caseSensitive: Bool = false
    @State private var matchCount: Int = 0
    @State private var currentMatchIndex: Int = 0
    @State private var searchResults: [Range<String.Index>] = []
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Find", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: searchText) { _, _ in
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            clearSearch()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(6)
                
                // Replace field
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(.secondary)
                    
                    TextField("Replace", text: $replaceText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(6)
                
                // Options
                HStack(spacing: 8) {
                    Toggle("Regex", isOn: $useRegex)
                        .toggleStyle(.button)
                        .onChange(of: useRegex) { _, _ in
                            performSearch()
                        }
                    
                    Toggle("Case", isOn: $caseSensitive)
                        .toggleStyle(.button)
                        .onChange(of: caseSensitive) { _, _ in
                            performSearch()
                        }
                }
                
                // Navigation buttons
                HStack(spacing: 4) {
                    Button(action: previousMatch) {
                        Image(systemName: "chevron.up")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(searchResults.isEmpty)
                    
                    Text("\(currentMatchIndex + 1)/\(searchResults.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(minWidth: 40)
                    
                    Button(action: nextMatch) {
                        Image(systemName: "chevron.down")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(searchResults.isEmpty)
                }
                
                // Action buttons
                HStack(spacing: 4) {
                    Button("Replace") {
                        replaceCurrent()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(searchResults.isEmpty)
                    
                    Button("Replace All") {
                        replaceAll()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(searchResults.isEmpty)
                }
                
                // Close button
                Button(action: {
                    isVisible = false
                    clearSearch()
                }) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.windowBackgroundColor))
            .border(Color(.separatorColor), width: 0.5)
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else {
            clearSearch()
            return
        }
        
        searchResults.removeAll()
        currentMatchIndex = 0
        
        if useRegex {
            performRegexSearch()
        } else {
            performSimpleSearch()
        }
        
        matchCount = searchResults.count
    }
    
    private func performSimpleSearch() {
        let searchString = caseSensitive ? searchText : searchText.lowercased()
        let textString = caseSensitive ? text : text.lowercased()
        
        var searchRange = textString.startIndex
        while let range = textString.range(of: searchString, range: searchRange) {
            searchResults.append(range)
            searchRange = range.upperBound
        }
    }
    
    private func performRegexSearch() {
        do {
            let options: String.CompareOptions = caseSensitive ? [] : .caseInsensitive
            let regex = try NSRegularExpression(pattern: searchText)
            let range = NSRange(text.startIndex..., in: text)
            
            let matches = regex.matches(in: text, range: range)
            searchResults = matches.compactMap { match in
                guard let range = Range(match.range, in: text) else { return nil }
                return range
            }
        } catch {
            // Invalid regex pattern
            searchResults.removeAll()
        }
    }
    
    private func nextMatch() {
        guard !searchResults.isEmpty else { return }
        currentMatchIndex = (currentMatchIndex + 1) % searchResults.count
    }
    
    private func previousMatch() {
        guard !searchResults.isEmpty else { return }
        currentMatchIndex = currentMatchIndex == 0 ? searchResults.count - 1 : currentMatchIndex - 1
    }
    
    private func replaceCurrent() {
        guard !searchResults.isEmpty && currentMatchIndex < searchResults.count else { return }
        
        let range = searchResults[currentMatchIndex]
        text.replaceSubrange(range, with: replaceText)
        
        // Remove the replaced match and adjust indices
        searchResults.remove(at: currentMatchIndex)
        if currentMatchIndex >= searchResults.count && !searchResults.isEmpty {
            currentMatchIndex = searchResults.count - 1
        }
        
        matchCount = searchResults.count
    }
    
    private func replaceAll() {
        guard !searchResults.isEmpty else { return }
        
        // Sort ranges in reverse order to avoid index shifting issues
        let sortedRanges = searchResults.sorted { $0.lowerBound > $1.lowerBound }
        
        for range in sortedRanges {
            text.replaceSubrange(range, with: replaceText)
        }
        
        clearSearch()
    }
    
    private func clearSearch() {
        searchResults.removeAll()
        currentMatchIndex = 0
        matchCount = 0
    }
} 