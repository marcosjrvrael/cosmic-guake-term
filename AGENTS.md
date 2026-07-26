# AGENTS.md — Cosmic Guake Term

## Project Overview

Fork of [cosmic-term](https://github.com/pop-os/cosmic-term) that adds a "Guake mode": a Quake-style drop-down terminal that shows/hides with a global keyboard shortcut, with configurable position (top/bottom/center), dimensions, auto-hide on focus loss, and multi-tab support.

## Architecture

```
src/
├── main.rs               # Entrypoint — parses args, loads config, spawns App
├── config.rs              # Config struct + cosmic_config entry (extended with guake settings)
├── guake/
│   └── mod.rs             # GuakeState — visibility toggle logic
├── applet/
│   └── main.rs            # Panel applet binary (Toggle + Settings buttons, IPC)
├── terminal.rs            # Terminal wrapper (unchanged from upstream)
├── terminal_box.rs        # Terminal widget (unchanged from upstream)
├── key_bind.rs            # Keybind definitions (extended with guake toggle)
├── shortcuts.rs           # Shortcut config (extended with guake action)
├── menu.rs                # Menu bar (extended with guake toggle menu item)
└── ...                    # Rest from upstream cosmic-term
```

## Key Design Decisions

1. **Fork with minimal diffs** (ADR-0001): Keep changes layered on top of upstream. Use `git rebase` to track upstream.
2. **Layer shell for overlay** (ADR-0002): Use `surface::action::app_layer_shell` with Wayland `zwlr_layer_surface_v1` on `Layer::Overlay`, not multi-window API. Created/destroyed on each toggle cycle. Suppress main xdg_toplevel via `no_main_window(true)`.
3. **Global shortcut via `--toggle` CLI + Unix socket IPC** (ADR-0003): `--toggle` flag connects to `$XDG_RUNTIME_DIR/cosmic-guake-term.sock`, sends `"toggle\n"`, exits. Running instance listens via `IpcSubscription` (tokio UnixListener in iced stream). SIGUSR1 fallback also supported. IPC commands: `toggle`, `settings`, `quit`.
4. **Inline settings view**: Settings rendered inside the layer surface view (not context drawer). `show_settings` flag switches between terminal and a simplified settings page with Theme + Font + Guake sections. Applet's Settings button sends `"settings\n"` via IPC, which toggles `show_settings` and ensures terminal is visible.
5. **Auto-hide on focus loss**: Layer surfaces do NOT receive `window::Event::Unfocused`. Instead, we subscribe to `LayerEvent::Unfocused` via `Event::PlatformSpecific(PlatformSpecific::Wayland(wayland::Event::Layer(LayerEvent::Unfocused, ..)))` and dispatch `Message::GuakeHide`.
6. **Settings stored in cosmic_config**: Guake settings live in the same `Config` struct.
7. **Corner radius**: Must explicitly set `corners: Some(CornerRadius { 0.. })` in every `LiveSettings` closure, otherwise theme radius (16 px) causes protocol error on first commit.
8. **No main window** on Wayland: `settings.no_main_window(true)` + `size(0,0)` + `size_limits(0,0)` because `set_minimized`/`set_mode(Hidden)` are no-ops on Wayland.
9. **Applet discovery**: COSMIC panel scans `$XDG_DATA_DIRS/applications/` for `.desktop` files with `X-CosmicApplet=true`. `~/.local/share/applications/` is NOT in `$XDG_DATA_DIRS`, so applet `.desktop` must be installed to `/usr/local/share/applications/` (requires pkexec).

## How to Continue Development

### Setup
```bash
cd ~/projetos/cosmic-guake-term
just build-release   # or just run
```

### Upstream Sync
```bash
git fetch upstream
git rebase upstream/master
# Resolve conflicts, test, force-push if needed
```

### Adding a Feature
1. Check docs/CONTEXT.md for terminology
2. Check docs/adr/ for existing decisions
3. Add guake/ module changes
4. Wire into main.rs App::update() and App::view()
5. Add i18n strings to i18n/ files
6. Add settings UI in guake/settings.rs

### Build Dependencies
Same as cosmic-term: Rust 1.93+, libcosmic, cosmic-text, alacritty_terminal, Wayland dev libs.

## Where to Start
- `src/main.rs` — Add `GuakeMode` to `Flags`, initialize in `App::init()`
- `src/config.rs` — Add guake fields (anchor, width_ratio, height_ratio, autohide, shortcut, start_mode)
- `src/guake/mod.rs` — Implement `GuakeState` struct
- `src/guake/settings.rs` — Settings page in context drawer
- `src/guake/shortcut.rs` — Global shortcut registration
- `Makefile` — Build/install targets for main binary + applet + desktop files
