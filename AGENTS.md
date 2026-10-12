# AGENTS.md — Cosmic Guake Term

## Project Overview

Fork of [cosmic-term](https://github.com/pop-os/cosmic-term) that adds a "Guake mode": a Quake-style drop-down terminal that shows/hides with a global keyboard shortcut, with configurable position (top/bottom/center), dimensions, auto-hide on focus loss, and multi-tab support.

**This is a `just` project** — use `just` commands for all build/install operations. Do not run `cargo build` directly; the justfile handles binary names, flags, and install script coordination.

## Skills

Always check for and load skills from both:
- `.claude/skills/` — Claude Code skills
- `.opencode/skills/` — opencode skills

Use the `skill` tool to load relevant skills when a task matches a skill's description.

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
10. **Keep upstream crate name for i18n** (ADR-0006): Crate name is `cosmic-term` (matches upstream), binary name is `cosmic-guake-term`. Eliminates all i18n rebase conflicts — translation files stay as `cosmic_term.ftl` in all locales.

## How to Continue Development

### Setup
```bash
cd ~/projetos/cosmic-guake-term
just build             # builds both terminal + applet (release)
just build-terminal    # terminal only
just build-applet      # applet only
just build-debug       # both in debug mode
```

**Note:** Full release build is heavy on CPU/RAM. On low-spec machines, set `jobs = 2` or `jobs = 4` in `.cargo/config.toml` under `[build]` to limit parallel compilation.

### Upstream Sync (Rebase Workflow)

```bash
# 1. Fetch latest from upstream
git fetch upstream

# 2. Rebase onto upstream/master
git rebase upstream/master

# 3. Resolve conflicts (see Conflict Resolution Patterns below)

# 4. Test build
just build

# 5. Create branch and push
git checkout -b sync-upstream-$(date +%Y-%m-%d)
git push origin sync-upstream-$(date +%Y-%m-%d)

# 6. Open PR against this fork's main branch
```

#### Conflict Resolution Patterns

**Files that commonly conflict:**

| File | Resolution Strategy |
|------|---------------------|
| `Cargo.toml` | Keep crate name `cosmic-term` (matches upstream), take upstream's `version`, keep fork's `[[bin]]` entries (`cosmic-guake-term`, `cosmic-guake-term-applet`) |
| `Cargo.lock` | Take upstream's (`git checkout --theirs Cargo.lock && git add Cargo.lock`) — will be regenerated |
| `src/main.rs` | Keep both: upstream changes + guake additions (Flags, App::init, Guake messages, layer shell logic) |
| `src/config.rs` | Keep both: upstream + GuakeConfig struct |
| `src/key_bind.rs` | Keep both: upstream + GuakeToggle action |
| `src/shortcuts.rs` | Keep both: upstream + GuakeToggle keybind |
| `src/menu.rs` | Keep both: upstream + guake toggle menu item |
| `justfile` | Keep fork's APPID rename (`io.github.cosmic-guake-term`) |
| `src/build.rs` | Use upstream default (no absolute i18n path fix needed — crate name matches upstream) |

**i18n file handling during rebase (simplified with ADR-0006):**
- Upstream uses `cosmic_term.ftl`; fork now **also uses `cosmic_term.ftl`** (crate name matches upstream)
- **No renames needed** — git merges cleanly
- **New locales added upstream** arrive as `cosmic_term.ftl` — no action needed, they just work
- **Upstream modified a locale** — auto-merges cleanly (same filename)

**build.rs (no fix needed after ADR-0006):**
The build script now uses the default i18n domain since crate name matches upstream. No manual fix required after rebase.

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
- `scripts/install.sh` — Install script for binaries, .desktop files, and icons
- `justfile` — Build/install targets for main binary + applet + desktop files