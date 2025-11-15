//
//  OverlayWindow.swift
//  InkTop
//
//  Created by Sumit Kumar on 15/11/25.
//
import Cocoa

class OverlayWindow: NSWindow {
    
    convenience init(screen: NSScreen, drawingManager: DrawingManager) {
        let frame = screen.frame
        
        self.init(
            contentRect: frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false,
            screen: screen
        )

        setupWindow()
        
        let overlayView = OverlayView(frame: frame, drawingManager: drawingManager)
        self.contentView = overlayView
    }
    
    private func setupWindow() {
        isOpaque = false
        backgroundColor = .clear
        level = .floating
        ignoresMouseEvents = false
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary
        ]
        hasShadow = false
        isReleasedWhenClosed = false
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
