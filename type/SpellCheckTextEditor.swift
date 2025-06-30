import SwiftUI
import AppKit

struct SpellCheckTextEditor: NSViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let showLineNumbers: Bool
    let onTextChange: (String) -> Void
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        
        // Configure text view
        textView.delegate = context.coordinator
        textView.string = text
        textView.font = NSFont.systemFont(ofSize: 18)
        textView.isRichText = false
        textView.isEditable = true
        textView.isSelectable = true
        
        // Enable spell checking
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.isAutomaticQuoteSubstitutionEnabled = true
        textView.isAutomaticDashSubstitutionEnabled = true
        textView.isAutomaticTextReplacementEnabled = true
        
        // Configure scroll view
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.documentView = textView
        
        // Store reference for coordinator
        context.coordinator.textView = textView
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        // Only update if text actually changed (to avoid cursor jumping)
        if textView.string != text {
            textView.string = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: SpellCheckTextEditor
        var textView: NSTextView?
        
        init(_ parent: SpellCheckTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = textView else { return }
            let newText = textView.string
            parent.text = newText
            parent.onTextChange(newText)
        }
    }
} 