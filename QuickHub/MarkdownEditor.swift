import SwiftUI
import AppKit

// MARK: - Live Markdown Text Editor with Syntax Highlighting
struct LiveMarkdownEditor: NSViewRepresentable {
    @Binding var text: String
    var font: NSFont = .monospacedSystemFont(ofSize: 14, weight: .regular)
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.font = font
        textView.textColor = .labelColor
        textView.backgroundColor = .textBackgroundColor
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        
        // Set initial text
        textView.string = text
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let textView = scrollView.documentView as! NSTextView
        if textView.string != text {
            textView.string = text
            highlightMarkdownSyntax(in: textView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: LiveMarkdownEditor
        
        init(_ parent: LiveMarkdownEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            parent.highlightMarkdownSyntax(in: textView)
        }
    }
    
    // MARK: - Syntax Highlighting
    func highlightMarkdownSyntax(in textView: NSTextView) {
        let text = textView.string
        let range = NSRange(location: 0, length: (text as NSString).length)
        
        // Get the text storage
        guard let textStorage = textView.textStorage else { return }
        
        // Reset all attributes
        textStorage.removeAttribute(.foregroundColor, range: range)
        textStorage.addAttribute(.font, value: font, range: range)
        textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: range)
        
        // Headers (# ## ###)
        let headerPattern = "^(#{1,6})\\s+(.+)$"
        highlightPattern(headerPattern, in: textStorage, text: text) { match in
            let headerRange = match.range(at: 1)
            let textRange = match.range(at: 2)
            
            textStorage.addAttribute(.foregroundColor, value: NSColor.systemPurple, range: headerRange)
            textStorage.addAttribute(.foregroundColor, value: NSColor.systemPurple, range: textRange)
            textStorage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 16), range: textRange)
        }
        
        // Bold (**text**)
        let boldPattern = "\\*\\*(.+?)\\*\\*"
        highlightPattern(boldPattern, in: textStorage, text: text) { match in
            let fullRange = match.range(at: 0)
            let textRange = match.range(at: 1)
            
            textStorage.addAttribute(.foregroundColor, value: NSColor.systemBlue.withAlphaComponent(0.7), range: fullRange)
            textStorage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 14), range: textRange)
        }
        
        // Italic (*text*)
        let italicPattern = "(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)"
        highlightPattern(italicPattern, in: textStorage, text: text) { match in
            let fullRange = match.range(at: 0)
            let textRange = match.range(at: 1)
            
            textStorage.addAttribute(.foregroundColor, value: NSColor.systemTeal.withAlphaComponent(0.7), range: fullRange)
            let italicFont = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
            textStorage.addAttribute(.font, value: italicFont, range: textRange)
        }
        
        // Inline code (`code`)
        let codePattern = "`(.+?)`"
        highlightPattern(codePattern, in: textStorage, text: text) { match in
            let fullRange = match.range(at: 0)
            
            textStorage.addAttribute(.foregroundColor, value: NSColor.systemOrange, range: fullRange)
            textStorage.addAttribute(.backgroundColor, value: NSColor.systemOrange.withAlphaComponent(0.1), range: fullRange)
            textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 13, weight: .medium), range: fullRange)
        }
        
        // Links ([text](url))
        let linkPattern = "\\[(.+?)\\]\\((.+?)\\)"
        highlightPattern(linkPattern, in: textStorage, text: text) { match in
            let textRange = match.range(at: 1)
            let urlRange = match.range(at: 2)
            
            textStorage.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: textRange)
            textStorage.addAttribute(.foregroundColor, value: NSColor.systemGray, range: urlRange)
            textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: textRange)
        }
        
        // Bullet lists (- or *)
        let bulletPattern = "^[\\s]*[-*]\\s+(.+)$"
        highlightPattern(bulletPattern, in: textStorage, text: text) { match in
            let bulletRange = NSRange(location: match.range.location, length: match.range.length - match.range(at: 1).length)
            
            textStorage.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: bulletRange)
        }
        
        // Numbered lists (1. 2. etc)
        let numberedPattern = "^[\\s]*\\d+\\.\\s+(.+)$"
        highlightPattern(numberedPattern, in: textStorage, text: text) { match in
            let numberRange = NSRange(location: match.range.location, length: match.range.length - match.range(at: 1).length)
            
            textStorage.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: numberRange)
        }
        
        // Blockquotes (> text)
        let quotePattern = "^>\\s+(.+)$"
        highlightPattern(quotePattern, in: textStorage, text: text) { match in
            textStorage.addAttribute(.foregroundColor, value: NSColor.systemIndigo, range: match.range)
            let italicFont = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
            textStorage.addAttribute(.font, value: italicFont, range: match.range)
        }
    }
    
    private func highlightPattern(_ pattern: String, in textStorage: NSTextStorage, text: String, apply: (NSTextCheckingResult) -> Void) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines]) else { return }
        let range = NSRange(location: 0, length: (text as NSString).length)
        regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let match = match else { return }
            apply(match)
        }
    }
}

// MARK: - Live Markdown Preview
struct LiveMarkdownPreview: View {
    let text: String
    
    var body: some View {
        ScrollView {
            Text(renderMarkdown(text))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
    
    private func renderMarkdown(_ markdown: String) -> AttributedString {
        do {
            var attributedString = try AttributedString(
                markdown: markdown,
                options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            )
            
            attributedString.font = .system(size: 14)
            
            return attributedString
        } catch {
            return AttributedString(markdown)
        }
    }
}
