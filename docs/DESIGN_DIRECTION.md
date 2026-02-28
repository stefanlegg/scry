# Scry Design Direction

## Philosophy: "Native with Soul"

95% system native (Raycast-level clean) + 5% magical touches (identity moments).

The base is macOS-native — SF Symbols, system colors, standard spacing. But deliberate "soul moments" give it personality without being over-designed.

**Reference apps:**
- Raycast (minimal, keyboard-first, dark mode excellence)
- Linear (premium feel, subtle purple glow)
- Arc (alive, delightful micro-interactions)
- CleanShot X (beautiful popover, subtle animations)

---

## Where the Magic Lives

| Element | Native Version | "Scry" Version |
|---------|----------------|----------------|
| Status indicator | Plain green circle | Soft pulsing glow, shimmer on state change |
| Running → Stopped | Instant color swap | Gentle fade out, like a flame dimming |
| Menu open | Standard appear | Subtle scale-in with soft shadow bloom |
| Hover state | Background tint | Faint inner glow, warmth |
| Icons | Plain SF Symbols | Hierarchical rendering or curated set |
| Refresh | Rotate icon | Gentle "ripple" like water in scrying bowl |

---

## Color Palette

### System Theme (default)
Follows macOS system colors exactly, with subtle glow (0.3 intensity).

### Scry Classic Theme
For those who want the magic turned up:
- Background: Deep purple-black (#1C1B22)
- Surface: Elevated purple (#2A2930)
- Accent: Soft purple (#9D8CFF)
- Active glow: Warm gold (#FFD666)
- Text: Lavender-white (#E8E6F0)
- Muted: Purple-gray (#6B6879)

### Minimal Theme
Pure system, no glow, no magic. For purists.

---

## Theme Architecture

```swift
protocol ScryTheme {
    // Core colors
    var background: Color { get }
    var surface: Color { get }
    var text: Color { get }
    var textMuted: Color { get }
    
    // Status
    var statusActive: Color { get }
    var statusActiveGlow: Color { get }
    var statusStopped: Color { get }
    
    // Accent
    var accent: Color { get }
    var accentGlow: Color { get }
    
    // Effects
    var glowIntensity: Double { get }  // 0 = off, 1 = full
    var animationsEnabled: Bool { get }
}
```

User settings:
- Theme preset (System / Minimal / Scry Classic / Custom)
- For Custom: accent color picker, glow intensity slider, animations toggle

---

## Icon Direction

### Primary: SF Symbols with Hierarchical Rendering
Use SF Symbols but with `.symbolRenderingMode(.hierarchical)` for subtle depth.

### Alternative: Curated Icon Pack
If we want more personality, consider:
- **Phosphor** (phosphoricons.com) — playful but clean
- **Lucide** (lucide.dev) — refined, consistent
- Custom commissioned set (8-10 icons) with crystal/glass aesthetic

### Icons Needed
- Globe (open in browser)
- Folder (open in Finder)
- Terminal (open in Terminal)
- Code brackets (open in VS Code)
- X / Stop (kill process)
- Arrow rotate (refresh)
- Pin (favorite)
- Bell (notifications)
- Eye (scry logo)
- Gear (settings)

---

## Animation Guidelines

**Principle:** Animations should feel natural, not showy. Like breathing, not fireworks.

| Animation | Duration | Easing | When |
|-----------|----------|--------|------|
| Status pulse | 2s loop | ease-in-out | Running indicator subtle glow |
| State change | 300ms | spring | Running ↔ Stopped |
| Menu open | 200ms | ease-out | Popover appearance |
| Hover glow | 150ms | linear | Mouse enter/leave |
| Refresh ripple | 500ms | ease-out | Manual refresh triggered |

---

## Light Mode Considerations

Most devs use dark mode, but light mode should work:
- Glow effects become subtle shadows
- Status colors adjust for contrast
- Same "soul" feeling, adapted

---

## Implementation Notes

### SwiftUI Glow Effect
```swift
Circle()
    .fill(theme.statusActive)
    .frame(width: 8, height: 8)
    .shadow(color: theme.statusActiveGlow.opacity(theme.glowIntensity), radius: 4)
    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulse)
```

### Glassmorphism Background
```swift
.background(.ultraThinMaterial)
.background(theme.background.opacity(0.8))
```

---

## Image Generation Prompts

### For UI Mockups
```
macOS Sonoma menu bar app UI mockup, dark mode, 
minimal native design like Raycast, SF Pro Text font, 
320px dropdown showing running dev servers with soft 
glowing green status indicators, subtle glassmorphism, 
professional but with hint of warmth, tiny magical 
touches like soft light bloom on active elements, 
Figma-quality, clean and elegant
```

### For Icons
```
minimal line icon set for developer tool app, 
8 icons: globe, folder, terminal, code editor, 
kill/stop, refresh, pin, bell notification, 
subtle crystal/glass inspired aesthetic, 
consistent 24px grid, 1.5px stroke weight, 
rounded caps, elegant and slightly magical feel
```

---

## Next Steps

1. [ ] Create SwiftUI theme protocol + presets
2. [ ] Implement glow effect view modifier
3. [ ] Test SF Symbols hierarchical rendering
4. [ ] Generate mockups with AI tools
5. [ ] Consider custom icon commission if SF Symbols feel too plain
6. [ ] Document final color tokens
