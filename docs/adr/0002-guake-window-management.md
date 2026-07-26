# ADR-0002: Guake Window Management

The Guake mode uses Wayland's `zwlr_layer_surface_v1` protocol via
`cosmic::surface::action::app_layer_shell` to create a surface on
the `Layer::Overlay` layer with `KeyboardInteractivity::OnDemand`.
The surface is created on show and destroyed on hide (not recycled),
avoiding stale state complications.

The main xdg_toplevel window is suppressed entirely via
`settings.no_main_window(true)` + `size(0,0)` + `size_limits(0,0)`.
This is necessary because `set_minimized`/`set_mode(Hidden)` are
no-ops on Wayland — the only way to hide is to destroy the surface.

### Focus Model

Three focus modes coexist:
1. **Toggle** — global shortcut via `--toggle` CLI sends `"toggle\n"`
   through a Unix socket (see ADR-0003)
2. **Auto-hide on focus loss** — listens for
   `Event::PlatformSpecific(Wayland(LayerEvent::Unfocused, ..))`;
   layer surfaces do NOT receive `window::Event::Unfocused`
3. Both can be active simultaneously: the shortcut still works even when
   auto-hide is on

### Settings

A simplified settings page (Theme + Font + Guake) is rendered inline in the
layer surface when `show_settings = true`, toggled via the `"settings"` IPC
command or the panel applet's Settings button. The settings page replaces
the terminal view until the user presses "← Back".

### Window Dimensions

Stored as percentages of screen size (width%, height%) in `GuakeConfig`,
read from cosmic_config. Screen size defaults to 1920×1080 if unavailable
(`MonitorSize` message is never dispatched by the framework).
