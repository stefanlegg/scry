import SwiftUI
import AppKit
import Carbon

/// A view that captures keyboard shortcuts
struct HotkeyRecorderView: View {
    @Binding var keyCode: UInt32
    @Binding var modifiers: UInt32
    
    @State private var isRecording = false
    @State private var displayString: String = ""
    
    var body: some View {
        HStack {
            Text(displayString.isEmpty ? "Click to record" : displayString)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(isRecording ? .blue : .primary)
                .frame(minWidth: 100)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isRecording ? Color.blue.opacity(0.1) : Color.primary.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(isRecording ? Color.blue : Color.clear, lineWidth: 1)
                        )
                )
                .onTapGesture {
                    isRecording = true
                }
            
            if isRecording {
                Button("Cancel") {
                    isRecording = false
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .font(.caption)
            }
            
            if !displayString.isEmpty && !isRecording {
                Button(action: {
                    // Clear the hotkey
                    keyCode = 0
                    modifiers = 0
                    displayString = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            HotkeyRecorderNSView(
                isRecording: $isRecording,
                keyCode: $keyCode,
                modifiers: $modifiers,
                displayString: $displayString
            )
            .frame(width: 0, height: 0)
        )
        .onAppear {
            updateDisplayString()
        }
        .onChange(of: keyCode) { _ in
            updateDisplayString()
        }
        .onChange(of: modifiers) { _ in
            updateDisplayString()
        }
    }
    
    private func updateDisplayString() {
        displayString = hotkeyToString(keyCode: keyCode, modifiers: modifiers)
    }
}

/// NSView wrapper to capture key events
struct HotkeyRecorderNSView: NSViewRepresentable {
    @Binding var isRecording: Bool
    @Binding var keyCode: UInt32
    @Binding var modifiers: UInt32
    @Binding var displayString: String
    
    func makeNSView(context: Context) -> KeyCaptureView {
        let view = KeyCaptureView()
        view.onKeyCapture = { code, mods in
            DispatchQueue.main.async {
                self.keyCode = code
                self.modifiers = mods
                self.displayString = hotkeyToString(keyCode: code, modifiers: mods)
                self.isRecording = false
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: KeyCaptureView, context: Context) {
        nsView.isRecording = isRecording
        if isRecording {
            nsView.window?.makeFirstResponder(nsView)
        }
    }
}

/// NSView that captures keyboard events
class KeyCaptureView: NSView {
    var isRecording = false
    var onKeyCapture: ((UInt32, UInt32) -> Void)?
    
    override var acceptsFirstResponder: Bool { true }
    
    override func keyDown(with event: NSEvent) {
        guard isRecording else {
            super.keyDown(with: event)
            return
        }
        
        let keyCode = UInt32(event.keyCode)
        var modifiers: UInt32 = 0
        
        if event.modifierFlags.contains(.command) {
            modifiers |= UInt32(cmdKey)
        }
        if event.modifierFlags.contains(.option) {
            modifiers |= UInt32(optionKey)
        }
        if event.modifierFlags.contains(.control) {
            modifiers |= UInt32(controlKey)
        }
        if event.modifierFlags.contains(.shift) {
            modifiers |= UInt32(shiftKey)
        }
        
        // Require at least one modifier
        if modifiers != 0 {
            onKeyCapture?(keyCode, modifiers)
        }
    }
    
    override func flagsChanged(with event: NSEvent) {
        // Don't capture modifier-only presses
    }
}

// MARK: - Helpers

/// Convert keycode + modifiers to display string
func hotkeyToString(keyCode: UInt32, modifiers: UInt32) -> String {
    guard keyCode != 0 else { return "" }
    
    var parts: [String] = []
    
    if modifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
    if modifiers & UInt32(optionKey) != 0 { parts.append("⌥") }
    if modifiers & UInt32(shiftKey) != 0 { parts.append("⇧") }
    if modifiers & UInt32(cmdKey) != 0 { parts.append("⌘") }
    
    // Map keycode to character
    let keyString = keyCodeToString(keyCode)
    parts.append(keyString)
    
    return parts.joined()
}

/// Map keycode to string representation
func keyCodeToString(_ keyCode: UInt32) -> String {
    let keyMap: [UInt32: String] = [
        0x00: "A", 0x01: "S", 0x02: "D", 0x03: "F", 0x04: "H",
        0x05: "G", 0x06: "Z", 0x07: "X", 0x08: "C", 0x09: "V",
        0x0B: "B", 0x0C: "Q", 0x0D: "W", 0x0E: "E", 0x0F: "R",
        0x10: "Y", 0x11: "T", 0x12: "1", 0x13: "2", 0x14: "3",
        0x15: "4", 0x16: "6", 0x17: "5", 0x18: "=", 0x19: "9",
        0x1A: "7", 0x1B: "-", 0x1C: "8", 0x1D: "0", 0x1E: "]",
        0x1F: "O", 0x20: "U", 0x21: "[", 0x22: "I", 0x23: "P",
        0x25: "L", 0x26: "J", 0x27: "'", 0x28: "K", 0x29: ";",
        0x2A: "\\", 0x2B: ",", 0x2C: "/", 0x2D: "N", 0x2E: "M",
        0x2F: ".", 0x32: "`",
        0x24: "↵", 0x30: "⇥", 0x31: "Space", 0x33: "⌫",
        0x35: "⎋", 0x7A: "F1", 0x78: "F2", 0x63: "F3", 0x76: "F4",
        0x60: "F5", 0x61: "F6", 0x62: "F7", 0x64: "F8", 0x65: "F9",
        0x6D: "F10", 0x67: "F11", 0x6F: "F12",
        0x7B: "←", 0x7C: "→", 0x7D: "↓", 0x7E: "↑"
    ]
    
    return keyMap[keyCode] ?? "?"
}
