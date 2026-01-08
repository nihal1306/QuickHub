import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack(spacing: 0) {
            // Left Panel - File Dock
            FileDockPanel()
                .frame(width: 300)
            
            Divider()
            
            // Center Panel - Camera
            CameraPanel()
                .frame(width: 300)
            
            Divider()
            
            // Right Panel - Notepad
            NotepadPanel()
                .frame(width: 300)
        }
        .frame(width: 900, height: 400)
    }
}

// MARK: - File Dock Panel
struct FileDockPanel: View {
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "folder.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("File Dock")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Drop zone
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [10]))
                    )
                
                VStack(spacing: 12) {
                    Image(systemName: "arrow.down.doc.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue.opacity(0.5))
                    Text("Drop files here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Temporary storage")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Camera Panel
struct CameraPanel: View {
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "camera.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                Text("Camera")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Camera preview placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.9))
                
                VStack(spacing: 12) {
                    Image(systemName: "video.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green.opacity(0.7))
                    Text("Camera Preview")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    Text("Coming soon")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Notepad Panel
// MARK: - Notepad Panel
struct NotepadPanel: View {
    @State private var noteText = """
# Welcome to QuickHub Notes

## Markdown Features
- **Bold text** with double asterisks
- *Italic text* with single asterisks  
- `Inline code` with backticks
- > Blockquotes with >

## Lists
1. Numbered items
2. Work great
3. Try it out!

- Bullet points
- Also supported
- With live highlighting!

## Try It
Type and watch the **live syntax highlighting** ✨

[Links work too](https://github.com)
"""
    @State private var showPreview = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("Scratchpad")
                    .font(.headline)
                Spacer()
                
                // Mode indicator
                HStack(spacing: 8) {
                    // Preview toggle
                    Button(action: { showPreview.toggle() }) {
                        HStack(spacing: 4) {
                            Image(systemName: showPreview ? "eye.slash.fill" : "eye.fill")
                            Text(showPreview ? "Edit" : "Preview")
                        }
                        .font(.caption)
                        .foregroundColor(showPreview ? .secondary : .orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(showPreview ? Color.gray.opacity(0.1) : Color.orange.opacity(0.1))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Content area - LIVE EDITING
            if showPreview {
                // Rendered preview
                LiveMarkdownPreview(text: noteText)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
            } else {
                // Live markdown editor with syntax highlighting
                LiveMarkdownEditor(text: $noteText)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
            }
            
            // Footer with stats
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "character")
                        .font(.caption2)
                    Text("\(noteText.count)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Text("•")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                HStack(spacing: 4) {
                    Image(systemName: "text.alignleft")
                        .font(.caption2)
                    Text("\(noteText.split(separator: "\n").count)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Text("•")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                HStack(spacing: 4) {
                    Image(systemName: "doc.text")
                        .font(.caption2)
                    Text("\(noteText.split(separator: " ").count) words")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: { noteText = "" }) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.caption2)
                        Text("Clear")
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

#Preview {
    ContentView()
}
