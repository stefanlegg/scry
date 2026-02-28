import SwiftUI
import Carbon

/// Manages global keyboard shortcuts
class HotkeyManager: ObservableObject {
    static let shared = HotkeyManager()
    
    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    
    private var currentKeyCode: UInt32 = 0x01
    private var currentModifiers: UInt32 = UInt32(optionKey | shiftKey)
    
    /// Callback when hotkey is pressed
    var onHotkeyPressed: (() -> Void)?
    
    private init() {}
    
    /// Registers the global hotkey with saved settings
    func register() {
        // Load from settings
        let settings = SettingsStore.shared
        currentKeyCode = settings.hotkeyCode
        currentModifiers = settings.hotkeyModifiers
        
        registerHotkey(keyCode: currentKeyCode, modifiers: currentModifiers)
    }
    
    /// Update the hotkey with new key combo
    func updateHotkey(keyCode: UInt32, modifiers: UInt32) {
        guard keyCode != 0 else { return }
        
        // Unregister old hotkey
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        
        // Register new hotkey
        currentKeyCode = keyCode
        currentModifiers = modifiers
        registerHotkey(keyCode: keyCode, modifiers: modifiers)
    }
    
    private func registerHotkey(keyCode: UInt32, modifiers: UInt32) {
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType("SCRY".fourCharCode)
        hotKeyID.id = 1
        
        // Install event handler if not already installed
        if eventHandler == nil {
            var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
            
            let status = InstallEventHandler(
                GetApplicationEventTarget(),
                { (_, event, _) -> OSStatus in
                    HotkeyManager.shared.onHotkeyPressed?()
                    return noErr
                },
                1,
                &eventType,
                nil,
                &eventHandler
            )
            
            guard status == noErr else {
                print("Failed to install event handler: \(status)")
                return
            }
        }
        
        // Register the hotkey
        let registerStatus = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if registerStatus != noErr {
            print("Failed to register hotkey: \(registerStatus)")
        } else {
            print("Registered hotkey: code=\(keyCode), modifiers=\(modifiers)")
        }
    }
    
    /// Unregisters the hotkey
    func unregister() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }
    
    deinit {
        unregister()
    }
}

// Helper extension for FourCharCode
extension String {
    var fourCharCode: FourCharCode {
        var result: FourCharCode = 0
        for char in self.utf8.prefix(4) {
            result = (result << 8) + FourCharCode(char)
        }
        return result
    }
}
