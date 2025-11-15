//
//  HotkeyManager.swift
//  InkTop
//
//  Created by Sumit Kumar on 15/11/25.
//

import Cocoa
import Carbon

class HotkeyManager {
    private var hotkeys: [UInt32: EventHotKeyRef] = [:]
    private var eventHandler: EventHandlerRef?
    private weak var overlayController: OverlayWindowController?
    
    enum HotkeyIdentifier: UInt32 {
        case toggleDrawing = 1
        case clearScreen = 2
        case toggleOverlay = 3
        case colorRed = 4
        case colorBlue = 5
        case colorGreen = 6
        case colorYellow = 7
        case quit = 8
    }
    init(overlayController: OverlayWindowController) {
        self.overlayController = overlayController
    }
    
    func setupHotkeys() {
            // Install event handler
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), hotkeyEventHandler, 1, &eventSpec, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), &eventHandler)
        
        // Register hotkeys
        registerHotkey(.toggleDrawing, keyCode: UInt32(2), modifiers: UInt32(cmdKey | shiftKey))
        registerHotkey(.clearScreen, keyCode: UInt32(8), modifiers: UInt32(cmdKey | shiftKey))
        registerHotkey(.toggleOverlay, keyCode: UInt32(31), modifiers: UInt32(cmdKey | shiftKey))
        registerHotkey(.colorRed, keyCode: UInt32(18), modifiers: UInt32(cmdKey | shiftKey))
        registerHotkey(.colorBlue, keyCode: UInt32(19), modifiers: UInt32(cmdKey | shiftKey))
        registerHotkey(.colorGreen, keyCode: UInt32(20), modifiers: UInt32(cmdKey | shiftKey))
        registerHotkey(.colorYellow, keyCode: UInt32(21), modifiers: UInt32(cmdKey | shiftKey))
        registerHotkey(.quit, keyCode: UInt32(53), modifiers: 0)
    }
    
    private func registerHotkey(_ identifier: HotkeyIdentifier, keyCode: UInt32, modifiers: UInt32) {
        var hotkeyID = EventHotKeyID(signature: OSType(0x494E4B54), id: identifier.rawValue) // 'INKT'
        var hotkeyRef: EventHotKeyRef?
        
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotkeyRef
        )
        
        if status == noErr, let ref = hotkeyRef {
            hotkeys[identifier.rawValue] = ref
        }
    }
    
    func handleHotkey(_ identifier: HotkeyIdentifier) {
        switch identifier {
        case .toggleDrawing:
            overlayController?.togglePause()
        case .clearScreen:
            overlayController?.clearAll()
        case .toggleOverlay:
            overlayController?.toggleOverlays()
        case .colorRed:
            overlayController?.setColor(.red)
        case .colorBlue:
            overlayController?.setColor(.blue)
        case .colorGreen:
            overlayController?.setColor(.green)
        case .colorYellow:
            overlayController?.setColor(.yellow)
        case .quit:
            NSApplication.shared.terminate(nil)
        }
    }
    
    func unregisterAllHotkeys() {
        for (_, ref) in hotkeys {
            UnregisterEventHotKey(ref)
        }
        hotkeys.removeAll()
        
        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }
    }
}

// C function for Carbon event handling
private func hotkeyEventHandler(
    nextHandler: EventHandlerCallRef?,
    event: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let event = event, let userData = userData else {
        return OSStatus(eventNotHandledErr)
    }
    
    var hotkeyID = EventHotKeyID()
    let status = GetEventParameter(
        event,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotkeyID
    )
    
    if status == noErr {
        let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
        if let identifier = HotkeyManager.HotkeyIdentifier(rawValue: hotkeyID.id) {
            DispatchQueue.main.async {
                manager.handleHotkey(identifier)
            }
            return noErr
        }
    }
    
    return OSStatus(eventNotHandledErr)
}
