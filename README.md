# Cosmic Guake Term

A Quake-style drop-down terminal for the COSMIC desktop. Fork of [cosmic-term](https://github.com/pop-os/cosmic-term) with a configurable overlay terminal that shows/hides on a global shortcut.

## Features

- **Guake mode**: Terminal overlay at configurable position (top/bottom/center) with configurable width/height
- **Global shortcut**: Toggle from any app via `--toggle` CLI flag
- **Auto-hide**: Optionally hides when clicking outside the terminal
- **Panel applet**: COSMIC panel applet for Toggle + Settings access
- **Multi-tab**: Multiple terminal tabs with split panes
- **All cosmic-term features**: GPU rendering, color schemes, profiles, font settings

## Install

### Prerequisites

- Rust 1.93+ (latest stable)
- `just` command runner: `cargo install just` or via package manager
- libcosmic dev libs: `libfontconfig-dev`, `libfreetype-dev`, `libwayland-dev`

### Build & Install

```bash
# 1. Build and install binaries + desktop files
just install

# 2. Start the terminal (daemonizes to background)
cosmic-guake-term --toggle

# 3. (Optional) Add panel applet:
#    COSMIC Settings → Desktop → Panel → Configure Applets → Add "Cosmic Guake Term Settings"
```

### Set Up Global Shortcut

COSMIC Settings → Keyboard → Keyboard Shortcuts → scroll to bottom → "+" button:

| Field | Value |
|-------|-------|
| Name | Toggle Guake Terminal |
| Command | `cosmic-guake-term --toggle` |
| Shortcut | Ctrl+Space (or any preferred key) |

## Usage

| Action | Method |
|--------|--------|
| Toggle terminal | Global keyboard shortcut → `cosmic-guake-term --toggle` |
| Settings (theme, font, guake) | Panel applet → Settings button, or `cosmic-guake-term --toggle` then click "← Back" |
| Toggle from terminal | `pkill -SIGUSR1 -f "cosmic-guake-term"` |

## Configuration

All settings are in COSMIC Settings → scroll to "Guake Settings":
- **Anchor**: Top / Bottom / Center
- **Width**: 30–100% of screen
- **Height**: 10–100% of screen
- **Auto-hide on focus loss**: On/Off
- **Start mode**: Show window / Start hidden
- **Toggle shortcut**: Custom keybinding

## Building

```bash
just build             # release build (both terminal + applet)
just build-terminal    # terminal only
just build-applet      # applet only
just build-debug       # debug build
just run               # run with debug logs
```

### CPU Usage During Build

The full release build (terminal + applet) is heavy — Cargo will use all available CPU cores by default. To limit parallelism project-wide, create `.cargo/config.toml`:

```toml
[build]
jobs = 4  # limit to 4 parallel compilation units
```

This applies to every `cargo build` invocation (including `just build`). Adjust the value based on your system. For low-memory systems (≤8 GB RAM), start with `jobs = 2`.

### Install Options

```bash
just install                           # user-local (~/.local)
just install -- --system-wide          # system-wide (/usr/local, requires sudo)
just uninstall                         # remove files (with confirmation)
just uninstall -- --yes                # remove without prompting
./scripts/install.sh --dry-run         # preview without executing
./scripts/install.sh --help            # show all options
```

## Syncing with Upstream (cosmic-term)

This repo is a fork of [pop-os/cosmic-term](https://github.com/pop-os/cosmic-term).
Follow these steps to keep it in sync with the original project.

### 1. Clone this repo (one-time)

```bash
git clone https://github.com/YOUR_USER/cosmic-guake-term.git
cd cosmic-guake-term
```

### 2. Add the original cosmic-term as upstream (one-time)

```bash
git remote add upstream https://github.com/pop-os/cosmic-term.git
```

Verify your remotes:

```bash
git remote -v
# origin     https://github.com/example/cosmic-guake-term.git (fetch)
# origin     https://github.com/example/cosmic-guake-term.git (push)
# upstream   https://github.com/pop-os/cosmic-term.git (fetch)
# upstream   https://github.com/pop-os/cosmic-term.git (push)
```

### 3. Fetch the latest from upstream

```bash
git fetch upstream
```

### 4. Rebase on top of upstream master

```bash
git rebase upstream/master
```

If there are no conflicts, skip to step 7.

### 5. Resolve conflicts (if any)

Files that commonly conflict:

| File | Reason |
|------|--------|
| `src/main.rs` | Guake features were added here |
| `src/config.rs` | `GuakeConfig` struct was added |
| `src/key_bind.rs` | `GuakeToggle` action was added |
| `src/shortcuts.rs` | `GuakeToggle` keybind was added |
| `src/menu.rs` | Guake toggle menu item was added |
| `justfile` | APPID was renamed |
| `src/build.rs` | APPID was renamed |
| `Cargo.toml` | Applet binary and dependencies were added |

How to resolve each file:
1. Open the file in your editor
2. Look for `<<<<<<<`, `=======`, `>>>>>>>` markers
3. **Keep both sides**: the upstream change AND your guake addition
4. Save the file
5. Run `git add <file>`

**About translation files (`i18n/`):**
These were renamed from `cosmic_term.ftl` → `cosmic_guake_term.ftl` with
identical content. Git detects the rename automatically during rebase.
If upstream adds a **new locale** (e.g. `i18n/xyz/cosmic_term.ftl`),
manually copy and rename it:

```bash
cp i18n/xyz/cosmic_term.ftl i18n/xyz/cosmic_guake_term.ftl
git add i18n/xyz/cosmic_guake_term.ftl
```

### 6. Continue the rebase

```bash
git rebase --continue
```

Repeat steps 5–6 until the rebase completes.

### 7. Test that everything compiles

```bash
just build
```

### 8. Create a branch and push

```bash
git checkout -b sync-upstream-$(date +%Y-%m-%d)
git push origin sync-upstream-$(date +%Y-%m-%d)
```

### 9. Open a Pull Request

1. Go to https://github.com/YOUR_USER/cosmic-guake-term
2. You'll see a banner: "sync-upstream-2026-07-26 had recent pushes" → click **Compare & pull request**
3. Base: `main` ← Compare: `sync-upstream-2026-07-26`
4. Title: `Sync with upstream (pop-os/cosmic-term)`
5. Add a summary of what changed in upstream (check `git log upstream/master --oneline`)
6. Click **Create pull request**
7. Wait for CI, then merge

## Docs

- [docs/adr/](docs/adr/) — Architecture Decision Records
- [docs/CONTEXT.md](docs/CONTEXT.md) — Domain language glossary
- [docs/architecture.mmd](docs/architecture.mmd) — Mermaid architecture diagram
 