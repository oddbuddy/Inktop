//
//  StatusBarController.swift
//  InkTop
//
//  Created by Sumit Kumar on 15/11/25.
//

import Cocoa

class StatusBarController {
    private var statusItem: NSStatusItem?
    private var menu: NSMenu?
    private weak var overlayController: OverlayWindowController?
    
    init(overlayController: OverlayWindowController) {
        self.overlayController = overlayController
        setupStatusItem()
        setupMenu()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "pencil.tip", accessibilityDescription: "InkTop")
            button.image?.isTemplate = true
        }
    }
    
    private func setupMenu() {
        menu = NSMenu()
        
        // Toggle Overlay
        let toggleItem = NSMenuItem(
            title: "Toggle Overlay",
            action: #selector(toggleOverlay),
            keyEquivalent: "o"
        )
        toggleItem.keyEquivalentModifierMask = [.command, .shift]
        toggleItem.target = self
        menu?.addItem(toggleItem)
        
        menu?.addItem(NSMenuItem.separator())
        
        // Color submenu
        let colorMenu = NSMenu()
        let colorMenuItem = NSMenuItem(title: "Color", action: nil, keyEquivalent: "")
        colorMenuItem.submenu = colorMenu
        
        let colors: [(String, NSColor, String)] = [
            ("Red", .red, "1"),
            ("Blue", .blue, "2"),
            ("Green", .green, "3"),
            ("Yellow", .yellow, "4"),
            ("Black", .black, ""),
            ("White", .white, ""),
            ("Orange", .orange, ""),
            ("Purple", .purple, "")
        ]
        
        for (name, color, key) in colors {
            let item = NSMenuItem(title: name, action: #selector(changeColor(_:)), keyEquivalent: key)
            if !key.isEmpty {
                item.keyEquivalentModifierMask = [.command, .shift]
            }
            item.target = self
            item.representedObject = color
            colorMenu.addItem(item)
        }
        
        colorMenu.addItem(NSMenuItem.separator())
        let pickerItem = NSMenuItem(title: "Custom Color...", action: #selector(showColorPicker), keyEquivalent: "")
        pickerItem.target = self
        colorMenu.addItem(pickerItem)
        
        menu?.addItem(colorMenuItem)
        
        // Stroke width submenu
        let widthMenu = NSMenu()
        let widthMenuItem = NSMenuItem(title: "Stroke Width", action: nil, keyEquivalent: "")
        widthMenuItem.submenu = widthMenu
        
        for width in [1, 2, 3, 5, 8, 12, 16, 20] {
            let item = NSMenuItem(
                title: "\(width)px",
                action: #selector(changeStrokeWidth(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = CGFloat(width)
            widthMenu.addItem(item)
        }
        
        menu?.addItem(widthMenuItem)
        
        menu?.addItem(NSMenuItem.separator())
        
        // Eraser submenu
        let eraserMenu = NSMenu()
        let eraserMenuItem = NSMenuItem(title: "Eraser", action: nil, keyEquivalent: "")
        eraserMenuItem.submenu = eraserMenu
        
        let toggleEraserItem = NSMenuItem(
            title: "Toggle Eraser",
            action: #selector(toggleEraser),
            keyEquivalent: "e"
        )
        toggleEraserItem.target = self
        eraserMenu.addItem(toggleEraserItem)
        
        eraserMenu.addItem(NSMenuItem.separator())
        
        let strokeEraserItem = NSMenuItem(
            title: "Erase Stroke",
            action: #selector(setStrokeEraserMode),
            keyEquivalent: ""
        )
        strokeEraserItem.target = self
        eraserMenu.addItem(strokeEraserItem)
        
        let pixelEraserItem = NSMenuItem(
            title: "Erase by Pixel",
            action: #selector(setPixelEraserMode),
            keyEquivalent: ""
        )
        pixelEraserItem.target = self
        eraserMenu.addItem(pixelEraserItem)
        
        menu?.addItem(eraserMenuItem)
        
        menu?.addItem(NSMenuItem.separator())
        
        // Drawing controls
        let pauseItem = NSMenuItem(
            title: "Pause Drawing",
            action: #selector(togglePause),
            keyEquivalent: "d"
        )
        pauseItem.keyEquivalentModifierMask = [.command, .shift]
        pauseItem.target = self
        menu?.addItem(pauseItem)
        
        let clearItem = NSMenuItem(
            title: "Clear All",
            action: #selector(clearAll),
            keyEquivalent: "c"
        )
        clearItem.keyEquivalentModifierMask = [.command, .shift]
        clearItem.target = self
        menu?.addItem(clearItem)
        
        menu?.addItem(NSMenuItem.separator())
        
        // Undo/Redo
        let undoItem = NSMenuItem(
            title: "Undo",
            action: #selector(undo),
            keyEquivalent: "z"
        )
        undoItem.target = self
        menu?.addItem(undoItem)
        
        let redoItem = NSMenuItem(
            title: "Redo",
            action: #selector(redo),
            keyEquivalent: "z"
        )
        redoItem.keyEquivalentModifierMask = [.command, .shift]
        redoItem.target = self
        menu?.addItem(redoItem)
        
        menu?.addItem(NSMenuItem.separator())
        
        // Keyboard shortcuts
        let shortcutsItem = NSMenuItem(
            title: "Keyboard Shortcuts",
            action: #selector(showShortcuts),
            keyEquivalent: ""
        )
        shortcutsItem.target = self
        menu?.addItem(shortcutsItem)
        
        menu?.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(
            title: "Quit InkTop",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu?.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    @objc private func toggleOverlay() {
        overlayController?.toggleOverlays()
    }
    
    @objc private func changeColor(_ sender: NSMenuItem) {
        if let color = sender.representedObject as? NSColor {
            overlayController?.setColor(color)
        }
    }
    
    @objc private func showColorPicker() {
        let colorPanel = NSColorPanel.shared
        colorPanel.showsAlpha = true
        colorPanel.isContinuous = true
//        colorPanel.target = self
//        colorPanel.action = #selector(colorPanelChanged(_:))
        colorPanel.makeKeyAndOrderFront(nil)
    }
    
    @objc private func colorPanelChanged(_ sender: NSColorPanel) {
        overlayController?.setColor(sender.color)
    }
    
    @objc private func changeStrokeWidth(_ sender: NSMenuItem) {
        if let width = sender.representedObject as? CGFloat {
            overlayController?.setStrokeWidth(width)
        }
    }
    
    @objc private func toggleEraser() {
        overlayController?.toggleEraser()
    }
    
    @objc private func setStrokeEraserMode() {
        overlayController?.setEraserMode(.stroke)
    }
    
    @objc private func setPixelEraserMode() {
        overlayController?.setEraserMode(.pixel)
    }
    
    @objc private func togglePause() {
        overlayController?.togglePause()
    }
    
    @objc private func clearAll() {
        overlayController?.clearAll()
    }
    
    @objc private func undo() {
        overlayController?.undo()
    }
    
    @objc private func redo() {
        overlayController?.redo()
    }
    
    @objc private func showShortcuts() {
        let alert = NSAlert()
        alert.messageText = "InkTop Keyboard Shortcuts"
        alert.informativeText = """
        ⌘⇧O - Toggle Overlay
        ⌘⇧D - Pause/Play Drawing
        ⌘⇧C - Clear All
        ⌘⇧1-4 - Change Color (Red/Blue/Green/Yellow)
        ⌘Z - Undo
        ⌘⇧Z - Redo
        ESC - Quit Application
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
