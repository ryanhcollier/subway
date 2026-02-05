import AppKit
import SwiftUI

class DesktopWindow: NSWindow {
    init(manager: SubwayManager) {
        let screen = NSScreen.main?.frame ?? NSRect.zero
        let height: CGFloat = 500
        let width: CGFloat = 240
        
        // Calculate top-left based on screen height
        let xPos: CGFloat = 20
        let yPos: CGFloat = screen.height - height - 60
        
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
}
