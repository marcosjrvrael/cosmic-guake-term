# Cosmic Guake Term

A drop-down terminal emulator for the COSMIC desktop, wrapping cosmic-term in a Quake-style
window that shows/hides with a global keyboard shortcut. Inspired by Guake for GNOME.

## Language

**Guake Mode**:
A window management mode where the terminal appears at a configurable screen position (top, bottom, or center) with configurable dimensions, toggled via a global hotkey.
_Avoid_: Drop-down mode, Quake mode

**Global Shortcut**:
A keyboard shortcut that works regardless of which window has focus, registered with the compositor (Wayland) or window manager.
_Avoid_: Hotkey, keybinding (use "shortcut" for consistency with cosmic-term codebase)

**Toggle**:
The action of showing the hidden terminal or hiding the visible terminal via the global shortcut.
_Avoid_: Show/hide (use as description, not term)

**Auto-Hide (Focus Loss)**:
An optional behavior where the terminal automatically hides when the user clicks outside its window.
_Avoid_: Click-outside-hide, defocus

**Anchor**:
The screen edge or region where the terminal window attaches: `Top`, `Bottom`, or `Center`.
_Avoid_: Position, alignment

**Window Ratio**:
The width (percentage of screen width) and height (percentage of screen height) of the terminal when in Guake mode.
_Avoid_: Dimension, size

**Daemon**:
The long-lived background process that maintains the terminal state and responds to the global shortcut.
_Avoid_: Service, background process

**Pane**:
A terminal area within a tab. cosmic-term supports split panes within tabs.
_Avoid_: Terminal view, split

**Tab**:
A named terminal session within the main window, visually separated by a tab bar.
_Avoid_: Session

**Profile**:
A named set of terminal configuration (font, colors, shell command, working directory) that can be assigned to tabs.
_Avoid_: Preset, config

**Applet**:
A COSMIC panel applet that provides quick access to toggle and settings. Sits in the panel's applet area.
_Avoid_: Plugin, widget

**IPC Socket**:
A Unix domain socket at `$XDG_RUNTIME_DIR/cosmic-guake-term.sock` used to send commands (toggle, settings, quit) to the running daemon from CLI or applet.
_Avoid_: Pipe, channel

**Inline Settings**:
Settings page rendered directly inside the terminal overlay (instead of a context drawer), toggled on/off via `Message::GuakeSettings`. Only Theme, Font, and Guake sections are shown.
_Avoid_: Overlay settings, settings page

**Layer Surface**:
A Wayland `zwlr_layer_surface_v1` used to display the terminal on the `Overlay` layer, independent of normal window management. Created/destroyed on each show/hide cycle.
_Avoid_: Overlay window, floating window
