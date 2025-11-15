//
//  AppDelegate.swift
//  InkTop
//
//  Created by Sumit Kumar on 15/11/25.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindowController: OverlayWindowController?
    var hotkeyManager: HotkeyManager?
    var statusBarController: StatusBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request screen recording permission
        checkScreenRecordingPermission()
        
        // Initialize overlay window controller
        overlayWindowController = OverlayWindowController()
        
        // Initialize status bar
        statusBarController = StatusBarController(overlayController: overlayWindowController!)
        
        // Initialize hotkey manager
        hotkeyManager = HotkeyManager(overlayController: overlayWindowController!)
        hotkeyManager?.setupHotkeys()
        
        // Hide dock icon (status bar only app)
        NSApp.setActivationPolicy(.accessory)
        
        // Setup notifications for space changes
        setupSpaceChangeNotifications()
        
        // Close any default windows
        NSApplication.shared.windows.forEach { window in
            if window.className.contains("SwiftUI") {
                window.close()
            }
        }
    }
    
    func checkScreenRecordingPermission() {
        // Create a small test window to check permissions
        let testWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1, height: 1),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        testWindow.backgroundColor = .clear
        testWindow.alphaValue = 0
        testWindow.orderFront(nil)
        testWindow.orderOut(nil)
        
        // Check if we can create windows (basic permission check)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Show alert if needed
            let alert = NSAlert()
            alert.messageText = "Screen Recording Permission Required"
            alert.informativeText = "InkTop needs screen recording permission to display overlays. Please grant permission in System Settings > Privacy & Security > Screen Recording."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Later")
            
            if alert.runModal() == .alertFirstButtonReturn {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
    
    func setupSpaceChangeNotifications() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(activeSpaceDidChange),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )
    }
    
    @objc func activeSpaceDidChange() {
        overlayWindowController?.updateForActiveSpace()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager?.unregisterAllHotkeys()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep app running even if no windows
    }
}
