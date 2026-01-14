
import SwiftUI
import AppKit

struct EnhancedTextEditor: NSViewRepresentable {
    @Binding var text: NSAttributedString
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        textView.delegate = context.coordinator
        textView.isRichText = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.usesFontPanel = true
        textView.usesRuler = false
        textView.allowsImageEditing = false
        
        // Text appearance
        textView.font = .systemFont(ofSize: 14)
        textView.textColor = .labelColor
        textView.backgroundColor = .textBackgroundColor
        textView.drawsBackground = true
        textView.insertionPointColor = .labelColor
        
        // Disable smart substitutions
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.isGrammarCheckingEnabled = false
        
        // Enable link clicking for checkboxes
        textView.linkTextAttributes = [
            .cursor: NSCursor.pointingHand,
            .underlineStyle: 0
        ]
        
        // Set default typing attributes
        textView.typingAttributes = [
            .font: NSFont.systemFont(ofSize: 14),
            .foregroundColor: NSColor.labelColor
        ]
        
        // Set initial text
        let mutableText = NSMutableAttributedString(attributedString: text)
        if mutableText.length > 0 {
            mutableText.addAttributes([
                .font: NSFont.systemFont(ofSize: 14),
                .foregroundColor: NSColor.labelColor
            ], range: NSRange(location: 0, length: mutableText.length))
        }
        textView.textStorage?.setAttributedString(mutableText)
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let textView = scrollView.documentView as! NSTextView
        
        if textView.attributedString() != text {
            let selectedRange = textView.selectedRange()
            let mutableText = NSMutableAttributedString(attributedString: text)
            if mutableText.length > 0 {
                mutableText.addAttributes([
                    .font: NSFont.systemFont(ofSize: 14),
                    .foregroundColor: NSColor.labelColor
                ], range: NSRange(location: 0, length: mutableText.length))
            }
            textView.textStorage?.setAttributedString(mutableText)
            if selectedRange.location <= textView.string.count {
                textView.setSelectedRange(selectedRange)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: EnhancedTextEditor
        
        init(_ parent: EnhancedTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            handleAutoFormatting(textView)
            parent.text = textView.attributedString()
        }
        
        // MARK: - Auto-Formatting
        func handleAutoFormatting(_ textView: NSTextView) {
            let text = textView.string
            let cursorPosition = textView.selectedRange().location
            
            guard cursorPosition > 0, cursorPosition <= text.count else { return }
            
            let previousChar = text[text.index(text.startIndex, offsetBy: cursorPosition - 1)]
            guard previousChar == " " else { return }
            
            let lineStart = (text as NSString).lineRange(for: NSRange(location: cursorPosition - 1, length: 0)).location
            let lineText = (text as NSString).substring(with: NSRange(location: lineStart, length: cursorPosition - lineStart))
            
            if lineText == "- " {
                replaceTriggerWithBullet(textView, range: NSRange(location: lineStart, length: 2))
            }
            else if lineText.matches(pattern: "^\\d+\\. $") {
                ensureProperAttributes(textView, range: NSRange(location: lineStart, length: lineText.count))
            }
            else if lineText == "[ ] " {
                replaceTriggerWithCheckbox(textView, range: NSRange(location: lineStart, length: 4), checked: false)
            }
            else if lineText == "[x] " {
                replaceTriggerWithCheckbox(textView, range: NSRange(location: lineStart, length: 4), checked: true)
            }
        }
        
        func replaceTriggerWithBullet(_ textView: NSTextView, range: NSRange) {
            guard let textStorage = textView.textStorage else { return }
            
            let bullet = "• "
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 14),
                .foregroundColor: NSColor.labelColor
            ]
            
            textStorage.replaceCharacters(in: range, with: NSAttributedString(string: bullet, attributes: attributes))
            textView.setSelectedRange(NSRange(location: range.location + bullet.count, length: 0))
        }
        
        func ensureProperAttributes(_ textView: NSTextView, range: NSRange) {
            guard let textStorage = textView.textStorage else { return }
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 14),
                .foregroundColor: NSColor.labelColor
            ]
            
            textStorage.addAttributes(attributes, range: range)
        }
        
        func replaceTriggerWithCheckbox(_ textView: NSTextView, range: NSRange, checked: Bool) {
            guard let textStorage = textView.textStorage else { return }
            
            let checkbox = checked ? "☑ " : "☐ "
            let checkboxID = UUID().uuidString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 14),
                .foregroundColor: NSColor.labelColor,
                .link: "checkbox://\(checkboxID):\(checked ? "checked" : "unchecked")" as NSString
            ]
            
            textStorage.replaceCharacters(in: range, with: NSAttributedString(string: checkbox, attributes: attributes))
            textView.setSelectedRange(NSRange(location: range.location + checkbox.count, length: 0))
        }
        
        // MARK: - Handle Checkbox Clicks
        func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int) -> Bool {
            guard let linkString = link as? String,
                  linkString.starts(with: "checkbox://") else {
                return false
            }
            
            let isChecked = linkString.hasSuffix(":checked")
            toggleCheckbox(textView, at: charIndex, currentlyChecked: isChecked)
            
            return true
        }
        
        func toggleCheckbox(_ textView: NSTextView, at index: Int, currentlyChecked: Bool) {
            guard let textStorage = textView.textStorage else { return }
            guard index >= 0 && index < textStorage.length else { return }
            
            let text = textStorage.string as NSString
            let lineRange = text.lineRange(for: NSRange(location: index, length: 0))
            
            // Find the checkbox in this line
            var checkboxLocation = -1
            for i in lineRange.location..<min(lineRange.location + lineRange.length, textStorage.length) {
                let char = text.substring(with: NSRange(location: i, length: 1))
                if char == "☐" || char == "☑" {
                    checkboxLocation = i
                    break
                }
            }
            
            guard checkboxLocation >= 0 else { return }
            
            let checkboxRange = NSRange(location: checkboxLocation, length: 1)
            
            // Toggle checkbox
            let newCheckbox = currentlyChecked ? "☐" : "☑"
            let checkboxID = UUID().uuidString
            let newLink = "checkbox://\(checkboxID):\(currentlyChecked ? "unchecked" : "checked")"
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 14),
                .foregroundColor: NSColor.labelColor,
                .link: newLink as NSString
            ]
            
            textStorage.replaceCharacters(in: checkboxRange, with: NSAttributedString(string: newCheckbox, attributes: attributes))
            
            // Toggle strikethrough on rest of line
            let startAfterCheckbox = checkboxLocation + 2
            if startAfterCheckbox < lineRange.location + lineRange.length {
                let textAfterCheckbox = NSRange(
                    location: startAfterCheckbox,
                    length: min(lineRange.location + lineRange.length - startAfterCheckbox, textStorage.length - startAfterCheckbox)
                )
                
                if textAfterCheckbox.length > 0 && textAfterCheckbox.location + textAfterCheckbox.length <= textStorage.length {
                    if !currentlyChecked {
                        textStorage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: textAfterCheckbox)
                        textStorage.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: textAfterCheckbox)
                    } else {
                        textStorage.removeAttribute(.strikethroughStyle, range: textAfterCheckbox)
                        textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: textAfterCheckbox)
                    }
                }
            }
            
            parent.text = textView.attributedString()
        }
    }
}

extension String {
    func matches(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, range: range) != nil
    }
}
