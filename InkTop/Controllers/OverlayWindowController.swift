//
//  OverlayWindowController.swift
//  InkTop
//
//  Created by Sumit Kumar on 15/11/25.
//

import Cocoa

class OverlayWindowController {
    private var overlayWindows: [NSScreen: OverlayWindow] = [:]
    private var drawingManagers: [NSScreen: DrawingManager] = [:]
    private(set) var isVisible: Bool = false
    
    init() {
        setupOverlayWindows()
        observeScreenChanges()
    }
    
    private func setupOverlayWindows() {
        for screen in NSScreen.screens {
            let drawingManager = DrawingManager()
            let window = OverlayWindow(screen: screen, drawingManager: drawingManager)
            
            overlayWindows[screen] = window
            drawingManagers[screen] = drawingManager
        }
    }
    
    private func observeScreenChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    @objc private func screensDidChange() {
        // Rebuild windows for new screen configuration
        setupOverlayWindows()
        if isVisible {
            showOverlays()
        }
    }
    
    func showOverlays() {
        for window in overlayWindows.values {
            window.makeKeyAndOrderFront(nil)
        }
        isVisible = true
    }
    
    func hideOverlays() {
        for window in overlayWindows.values {
            window.orderOut(nil)
        }
        isVisible = false
    }
    
    func toggleOverlays() {
        if isVisible {
            hideOverlays()
        } else {
            showOverlays()
        }
    }
    
    func clearAll() {
        for (screen, manager) in drawingManagers {
            manager.clearAll()
            if let window = overlayWindows[screen],
               let overlayView = window.contentView as? OverlayView {
                overlayView.refresh()
            }
        }
    }
    
    func undo() {
        // Undo on main screen (or could be current screen)
        if let mainScreen = NSScreen.main,
           let manager = drawingManagers[mainScreen],
           let window = overlayWindows[mainScreen],
           let overlayView = window.contentView as? OverlayView {
            manager.undo()
            overlayView.refresh()
        }
    }
    
    func redo() {
        if let mainScreen = NSScreen.main,
           let manager = drawingManagers[mainScreen],
           let window = overlayWindows[mainScreen],
           let overlayView = window.contentView as? OverlayView {
            manager.redo()
            overlayView.refresh()
        }
    }
    
    func setColor(_ color: NSColor) {
        for manager in drawingManagers.values {
            manager.currentColor = color
        }
    }
    
    func setStrokeWidth(_ width: CGFloat) {
        for manager in drawingManagers.values {
            manager.currentWidth = width
        }
    }
    
    func toggleEraser() {
        for manager in drawingManagers.values {
            manager.isEraserMode.toggle()
        }
    }
    
    func setEraserMode(_ mode: DrawingManager.EraserMode) {
        for manager in drawingManagers.values {
            manager.eraserMode = mode
        }
    }
    
    func togglePause() {
        for manager in drawingManagers.values {
            manager.isPaused.toggle()
        }
    }
    
    func updateForActiveSpace() {
        // Ensure windows are visible on active space
        if isVisible {
            for window in overlayWindows.values {
                window.orderFront(nil)
            }
        }
    }
    
    func getCurrentDrawingManager() -> DrawingManager? {
        return drawingManagers[NSScreen.main ?? NSScreen.screens[0]]
    }
}
