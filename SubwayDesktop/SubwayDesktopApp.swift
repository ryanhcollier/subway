import SwiftUI

@main
struct SubwayDesktopApp: App {
    @StateObject private var manager = SubwayManager.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Suppress the startup window
        Settings {
            EmptyView()
        }
        .defaultLaunchBehavior(.suppressed)
        
        MenuBarExtra("Subway", systemImage: "tram.fill") {
            MenuView(subway: manager)
        }
        .menuBarExtraStyle(.window)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var desktopWindow: DesktopWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        desktopWindow = DesktopWindow(manager: SubwayManager.shared)
        desktopWindow?.orderFront(nil)
    }
}

