import SwiftUI
import Carbon

/// Manages global keyboard shortcuts
class HotkeyManager: ObservableObject {
    static let shared = HotkeyManager()
    
    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    
    /// Callback when hotkey is pressed
    var onHotkeyPressed: (() -> Void)?
    
    private init() {}
    
    /// Registers the global hotkey (⌥⇧S by default)
    func register() {
        // Define the hotkey: ⌥⇧S (Option + Shift + S)
        let modifiers: UInt32 = UInt32(optionKey | shiftKey)
        let keyCode: UInt32 = 0x01  // 'S' key
        
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType("SCRY".fourCharCode)
        hotKeyID.id = 1
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        // Install event handler
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
