import SwiftUI
import AppKit

class KeyboardShortcutMonitor: ObservableObject {
    private var monitor: Any?
    
    func startMonitoring(handler: @escaping (NSEvent) -> NSEvent?) {
        stopMonitoring()
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: handler)
    }
    
    func stopMonitoring() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
    
    deinit {
        stopMonitoring()
    }
}
