import SwiftUI

@main
struct QuickHubApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var eventMonitor: EventMonitor?
    var escapeKeyMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "bolt.fill", accessibilityDescription: "QuickHub")
            button.action = #selector(togglePopover)
        }
        
        // Create the popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 900, height: 400)
        popover?.behavior = .applicationDefined  // ← CHANGE THIS LINE
        popover?.contentViewController = NSHostingController(rootView: ContentView())
        
        // Monitor clicks outside the popover - REMOVE OR COMMENT OUT
        // eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
        //     if let strongSelf = self, strongSelf.popover?.isShown == true {
        //         strongSelf.closePopover()
        //     }
        // }
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                closePopover()
            } else {
                showPopover()
            }
        }
    }
    
    func showPopover() {
        if let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            // eventMonitor?.start()  // ← COMMENT THIS OUT OR REMOVE
            popover?.contentViewController?.view.window?.makeKey()
            
            // Local escape key monitor
            escapeKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                if event.keyCode == 53 { // Escape key
                    self?.closePopover()
                    return nil
                }
                return event
            }
        }
    }
    
    func closePopover() {
        popover?.performClose(nil)
        // eventMonitor?.stop()  // ← COMMENT THIS OUT OR REMOVE
        
        // Remove escape key monitor
        if let monitor = escapeKeyMonitor {
            NSEvent.removeMonitor(monitor)
            escapeKeyMonitor = nil
        }
    }
    
    class EventMonitor {
        private var monitor: Any?
        private let mask: NSEvent.EventTypeMask
        private let handler: (NSEvent?) -> Void
        
        init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
            self.mask = mask
            self.handler = handler
        }
        
        deinit {
            stop()
        }
        
        func start() {
            monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
        }
        
        func stop() {
            if monitor != nil {
                NSEvent.removeMonitor(monitor!)
                monitor = nil
            }
        }
    }
}
