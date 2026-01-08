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
            .frame(height: 240) // Make panel active areas uniform
            .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Camera Panel
struct CameraPanel: View {
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "camera.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                Text("Camera")
                    .font(.headline)
                
                Spacer()
                
                // Privacy indicator
                if cameraManager.isCameraOn {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        Text("Active")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Camera preview or placeholder
            ZStack {
                if let previewLayer = cameraManager.previewLayer, cameraManager.isCameraOn {
                    // Live camera feed
                    CameraView(previewLayer: previewLayer)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.3), lineWidth: 2)
                        )
                } else {
                    // Placeholder when camera is off
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.9))
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: cameraManager.hasCamera ? "video.slash.fill" : "video.slash")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                Text(cameraManager.hasCamera ? "Camera Off" : "No Camera")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                if let error = cameraManager.errorMessage {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.5))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                            }
                        )
                }
            }
            .frame(height: 240)
            .padding(.horizontal)
            
            // Controls
            HStack(spacing: 12) {
                // Camera toggle button
                Button(action: {
                    cameraManager.toggleCamera()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: cameraManager.isCameraOn ? "video.fill" : "video.slash.fill")
                        Text(cameraManager.isCameraOn ? "Turn Off" : "Turn On")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(cameraManager.isCameraOn ? Color.red : Color.green)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(!cameraManager.hasCamera)
                
                // Mirror toggle button
                if cameraManager.isCameraOn {
                    Button(action: {
                        cameraManager.toggleMirror()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.left.and.right")
                            Text(cameraManager.isMirrored ? "Mirrored" : "Normal")
                        }
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
}
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
                    .frame(height: 240)
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
                    .frame(height: 240)
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
