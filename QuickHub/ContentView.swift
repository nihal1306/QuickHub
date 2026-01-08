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
struct NotepadPanel: View {
    @State private var noteText = "Start typing your notes here..."
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("Scratchpad")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Text editor
            TextEditor(text: $noteText)
                .font(.system(size: 14))
                .padding(8)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
            
            // Footer
            HStack {
                Text("\(noteText.count) characters")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("Clear") {
                    noteText = ""
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundColor(.orange)
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
