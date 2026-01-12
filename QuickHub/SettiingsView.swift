import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showFileCount") private var showFileCount = true
    @AppStorage("cameraAutoStart") private var cameraAutoStart = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "gearshape.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Settings content
            Form {
                Section {
                    Toggle("Launch at Login", isOn: $launchAtLogin)
                        .toggleStyle(.switch)
                    
                    Toggle("Show File Count Badge", isOn: $showFileCount)
                        .toggleStyle(.switch)
                    
                    Toggle("Auto-start Camera", isOn: $cameraAutoStart)
                        .toggleStyle(.switch)
                } header: {
                    Text("General")
                        .font(.headline)
                }
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Storage Location")
                        Spacer()
                        Button("Open Folder") {
                            openStorageFolder()
                        }
                        .buttonStyle(.link)
                    }
                    
                    Button("Clear All Data") {
                        clearAllData()
                    }
                    .foregroundColor(.red)
                } header: {
                    Text("Advanced")
                        .font(.headline)
                }
            }
            .formStyle(.grouped)
            .padding()
            
            Spacer()
            
            // Footer
            HStack {
                Text("Made with ❤️ and a questionable amount of ☕")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Link("GitHub", destination: URL(string: "https://github.com/nihal1306/QuickHub")!)
                    .font(.caption)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 500, height: 400)
    }
    
    // MARK: - Actions
    private func openStorageFolder() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let storageDir = appSupport.appendingPathComponent("QuickHub/Files", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: storageDir, withIntermediateDirectories: true)
        
        NSWorkspace.shared.open(storageDir)
    }
    
    private func clearAllData() {
        let alert = NSAlert()
        alert.messageText = "Clear All Data?"
        alert.informativeText = "This will delete all stored files and reset your notes. This cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Clear All Data")
        
        if alert.runModal() == .alertSecondButtonReturn {
            // Clear files
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let quickHubDir = appSupport.appendingPathComponent("QuickHub", isDirectory: true)
            try? FileManager.default.removeItem(at: quickHubDir)
            
            // Clear UserDefaults
            if let bundleID = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleID)
            }
            
            // Show confirmation
            let confirmation = NSAlert()
            confirmation.messageText = "Data Cleared"
            confirmation.informativeText = "Please restart QuickHub for changes to take effect."
            confirmation.runModal()
        }
    }
}

#Preview {
    SettingsView()
}
