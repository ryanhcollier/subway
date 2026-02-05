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
        
        WindowGroup(id: "howto") {
            HowToView()
        }
        .defaultSize(width: 400, height: 400)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var desktopWindow: DesktopWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        desktopWindow = DesktopWindow(manager: SubwayManager.shared)
        desktopWindow?.orderFront(nil)
    }
}

