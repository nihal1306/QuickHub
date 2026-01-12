import SwiftUI
import AppKit

struct LiveMarkdownTextEditor: NSViewRepresentable {
    @Binding var text: String
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: 14)
        textView.textColor = .labelColor
        textView.backgroundColor = .textBackgroundColor
        textView.isRichText = true
        textView.allowsUndo = true
        
        // Set initial text
        updateTextViewWithMarkdown(textView, text: text)
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let textView = scrollView.documentView as! NSTextView
        
        // Only update if text changed from outside
        if textView.string != text {
            updateTextViewWithMarkdown(textView, text: text)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: LiveMarkdownTextEditor
        
        init(_ parent: LiveMarkdownTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            parent.updateTextViewWithMarkdown(textView, text: textView.string)
        }
    }
    
    // MARK: - Render Markdown
    private func updateTextViewWithMarkdown(_ textView: NSTextView, text: String) {
        let currentRange = textView.selectedRange()
        
        // Try to parse as markdown
        do {
            var attributedString = try AttributedString(
                markdown: text,
                options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            )
            
            // Set default font
            attributedString.font = .systemFont(ofSize: 14)
            
            // Convert to NSAttributedString
            let nsAttributedString = NSMutableAttributedString(attributedString)
            
            // Update text view
            textView.textStorage?.setAttributedString(nsAttributedString)
            
            // Restore cursor position
            textView.setSelectedRange(currentRange)
            
        } catch {
            // If markdown parsing fails, just show plain text
            textView.string = text
            textView.setSelectedRange(currentRange)
        }
    }
}
