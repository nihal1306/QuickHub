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
    @StateObject private var fileManager = FileDockManager()
    @State private var isDragging = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header - Fixed height
            HStack {
                Image(systemName: "folder.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("File Dock")
                    .font(.headline)
                Spacer()
                
                // File count badge
                if !fileManager.files.isEmpty {
                    Text("\(fileManager.files.count)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .frame(height: 44)
            .padding(.horizontal)
            
            // Content area
            if fileManager.files.isEmpty {
                // Drop zone when empty
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isDragging ? Color.blue.opacity(0.2) : Color.blue.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isDragging ? Color.blue : Color.blue.opacity(0.3),
                                    style: StrokeStyle(lineWidth: isDragging ? 3 : 2, dash: [10])
                                )
                        )
                    
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.down.doc.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue.opacity(isDragging ? 0.8 : 0.5))
                        Text("Drop files here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Temporary storage")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 280)
                .padding(.horizontal)
                .padding(.top, 8)
                .onDrop(of: [.fileURL], isTargeted: $isDragging) { providers in
                    handleDrop(providers: providers)
                    return true
                }
            } else {
                // File list when files present
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(fileManager.files) { file in
                            FileRowView(file: file, fileManager: fileManager)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .frame(height: 280)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isDragging ? Color.blue : Color.gray.opacity(0.2), lineWidth: isDragging ? 2 : 1)
                )
                .padding(.horizontal)
                .padding(.top, 8)
                .onDrop(of: [.fileURL], isTargeted: $isDragging) { providers in
                    handleDrop(providers: providers)
                    return true
                }
            }
            
            // Footer with Clear All button
            HStack {
                if !fileManager.files.isEmpty {
                    Button(action: {
                        fileManager.clearAll()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.caption2)
                            Text("Clear All")
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .frame(height: 40)
            .padding(.horizontal)
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Handle Drop
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                DispatchQueue.main.async {
                    if let data = urlData as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil) {
                        fileManager.addFiles(from: [url])
                    }
                }
            }
        }
        return true
    }
}

// MARK: - File Row View
struct FileRowView: View {
    let file: StoredFile
    let fileManager: FileDockManager
    
    var body: some View {
        HStack(spacing: 12) {
            // File icon
            Image(systemName: file.fileIcon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            // File info
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text(file.sizeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 8) {
                // Open button
                Button(action: {
                    fileManager.openFile(file)
                }) {
                    Image(systemName: "arrow.up.forward.square")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .help("Open file")
                
                // Delete button
                Button(action: {
                    fileManager.removeFile(file)
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Delete file")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            fileManager.openFile(file)
        }
    }
}

// MARK: - Camera Panel
struct CameraPanel: View {
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header - Fixed height
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
            .frame(height: 44)
            .padding(.horizontal)
            
            // Camera preview - Larger
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
            .frame(height: 280)
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Controls - Fixed height
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
            .frame(height: 40)
            .padding(.horizontal)
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Notepad Panel
struct NotepadPanel: View {
    @State private var noteText: NSAttributedString = {
        if let data = UserDefaults.standard.data(forKey: "notepadRichText"),
           let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.rtf],
            documentAttributes: nil
           ) {
            return attributedString
        }
        
        let defaultText = "Welcome to QuickHub Notes!\n\nSmart Auto-Formatting:\n- Type \"- \" for bullets\n1. Type \"1. \" for numbers\n\nKeyboard Shortcuts:\nCmd+B for bold\nCmd+I for italic\nCmd+U for underline\n\nTry it below!"
        
        let attributed = NSMutableAttributedString(string: defaultText)
        attributed.addAttribute(.font, value: NSFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: attributed.length))
        return attributed
    }()
    
    var characterCount: Int {
        noteText.string.count
    }
    
    var wordCount: Int {
        noteText.string.split(separator: " ").count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "note.text")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("Notes")
                    .font(.headline)
                Spacer()
                
                Text("\(characterCount)")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .frame(height: 44)
            .padding(.horizontal)
            
            // Text editor
            EnhancedTextEditor(text: $noteText)
                .frame(height: 280)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.top, 8)
                .onChange(of: noteText) { newValue in
                    saveNoteText(newValue)
                }
            
            // Footer
            HStack(spacing: 8) {
                Text("\(wordCount) words")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: { clearNote() }) {
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
            .frame(height: 40)
            .padding(.horizontal)
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private func saveNoteText(_ attributedString: NSAttributedString) {
        if let data = try? attributedString.data(
            from: NSRange(location: 0, length: attributedString.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
        ) {
            UserDefaults.standard.set(data, forKey: "notepadRichText")
        }
    }
    
    private func clearNote() {
        let alert = NSAlert()
        alert.messageText = "Clear Note?"
        alert.informativeText = "This will delete all text in your note."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Clear")
        
        if alert.runModal() == .alertSecondButtonReturn {
            noteText = NSAttributedString(string: "")
        }
    }
}

#Preview {
    ContentView()
}
