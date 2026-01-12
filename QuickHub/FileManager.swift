import Foundation
import AppKit

// MARK: - Stored File Model
struct StoredFile: Identifiable, Codable {
    let id: UUID
    let name: String
    let path: String
    let size: Int64
    let dateAdded: Date
    
    var sizeString: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    var fileIcon: String {
        let ext = (name as NSString).pathExtension.lowercased()
        
        switch ext {
        case "pdf":
            return "doc.fill"
        case "jpg", "jpeg", "png", "gif", "heic", "webp":
            return "photo.fill"
        case "doc", "docx", "txt", "rtf":
            return "doc.text.fill"
        case "xls", "xlsx", "csv":
            return "tablecells.fill"
        case "zip", "rar", "7z":
            return "archivebox.fill"
        case "mp4", "mov", "avi":
            return "video.fill"
        case "mp3", "wav", "m4a":
            return "music.note"
        default:
            return "doc.fill"
        }
    }
}

// MARK: - File Dock Manager
class FileDockManager: ObservableObject {
    @Published var files: [StoredFile] = []
    
    private let storageDirectory: URL
    private let metadataFile: URL
    
    init() {
        // Create storage directory in Application Support
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        storageDirectory = appSupport.appendingPathComponent("QuickHub/Files", isDirectory: true)
        metadataFile = appSupport.appendingPathComponent("QuickHub/files_metadata.json")
        
        // Create directory if needed
        try? FileManager.default.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
        
        // Load saved files
        loadFiles()
    }
    
    // MARK: - Add Files
    func addFiles(from urls: [URL]) {
        for url in urls {
            // Copy file to storage
            let filename = url.lastPathComponent
            let destination = storageDirectory.appendingPathComponent(filename)
            
            do {
                // If file already exists, add number to filename
                var finalDestination = destination
                var counter = 1
                while FileManager.default.fileExists(atPath: finalDestination.path) {
                    let nameWithoutExt = (filename as NSString).deletingPathExtension
                    let ext = (filename as NSString).pathExtension
                    let newName = "\(nameWithoutExt)_\(counter).\(ext)"
                    finalDestination = storageDirectory.appendingPathComponent(newName)
                    counter += 1
                }
                
                try FileManager.default.copyItem(at: url, to: finalDestination)
                
                // Get file size
                let attributes = try FileManager.default.attributesOfItem(atPath: finalDestination.path)
                let fileSize = attributes[.size] as? Int64 ?? 0
                
                // Create stored file entry
                let storedFile = StoredFile(
                    id: UUID(),
                    name: finalDestination.lastPathComponent,
                    path: finalDestination.path,
                    size: fileSize,
                    dateAdded: Date()
                )
                
                files.append(storedFile)
                saveFiles()
                
            } catch {
                print("Error copying file: \(error)")
            }
        }
    }
    
    // MARK: - Remove File
    func removeFile(_ file: StoredFile) {
        // Delete physical file
        try? FileManager.default.removeItem(atPath: file.path)
        
        // Remove from array
        files.removeAll { $0.id == file.id }
        saveFiles()
    }
    
    // MARK: - Clear All
    func clearAll() {
        // Delete all files
        for file in files {
            try? FileManager.default.removeItem(atPath: file.path)
        }
        
        files.removeAll()
        saveFiles()
    }
    
    // MARK: - Open File
    func openFile(_ file: StoredFile) {
        let url = URL(fileURLWithPath: file.path)
        NSWorkspace.shared.open(url)
    }
    
    // MARK: - Persistence
    private func saveFiles() {
        do {
            let data = try JSONEncoder().encode(files)
            try data.write(to: metadataFile)
        } catch {
            print("Error saving files metadata: \(error)")
        }
    }
    
    private func loadFiles() {
        guard let data = try? Data(contentsOf: metadataFile) else { return }
        
        do {
            let loadedFiles = try JSONDecoder().decode([StoredFile].self, from: data)
            
            // Only keep files that still exist
            files = loadedFiles.filter { file in
                FileManager.default.fileExists(atPath: file.path)
            }
            
            // Save cleaned list
            if files.count != loadedFiles.count {
                saveFiles()
            }
        } catch {
            print("Error loading files metadata: \(error)")
        }
    }
}
