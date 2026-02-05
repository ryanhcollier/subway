import AppKit
import SwiftUI

class DesktopWindow: NSWindow {
    init(manager: SubwayManager) {
        // Use detected screen or fallback to primary
        let screen = NSScreen.main ?? NSScreen.screens.first ?? NSScreen()
        let frame = screen.frame
        
        let height = frame.height - 50 // Full height minus menu bar padding
        let width: CGFloat = 240
        
        // Calculate top-left based on screen height
        // Use frame.minX/minY to handle external monitors correctly
        let xPos: CGFloat = frame.minX + 20
        let yPos: CGFloat = frame.minY // Bottom left relative to THIS screen
        
        super.init(
            contentRect: NSRect(x: xPos, y: yPos, width: width, height: height),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        
        // Place window behind all other windows (Desktop level)
        self.level = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)))
        
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        self.contentView = NSHostingView(rootView: DesktopContentView(subway: manager, height: height))
        self.orderFront(nil)
    }
    func moveToNextScreen() {
        print("DEBUG: moveToNextScreen called")
        let screens = NSScreen.screens
        print("DEBUG: Detected \(screens.count) screens")
        guard !screens.isEmpty else { return }
        
        // Find current screen index, default to 0
        let currentScreen = self.screen ?? screens[0]
        let currentIndex = screens.firstIndex(of: currentScreen) ?? 0
        print("DEBUG: Current screen index: \(currentIndex)")
        
        // Calculate next index
        let nextIndex = (currentIndex + 1) % screens.count
        print("DEBUG: Next screen index: \(nextIndex)")
        
        let nextScreen = screens[nextIndex]
        let frame = nextScreen.frame
        
        // Apply positioning logic
        let height = frame.height - 50
        let width: CGFloat = 240
        let xPos = frame.minX + 20
        let yPos = frame.minY
        
        self.setFrame(NSRect(x: xPos, y: yPos, width: width, height: height), display: true)
    }
}
