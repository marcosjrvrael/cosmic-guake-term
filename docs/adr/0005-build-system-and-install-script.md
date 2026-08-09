# ADR-0005: Build System and Install Script

We consolidate the build system on `just` (dropping the Makefile) and add a dedicated `scripts/install.sh` that handles all installation, uninstallation, and post-install messaging. The justfile stays thin — recipes delegate to the shell script — so upstream justfile changes remain easy to rebase.

## Build targets

| Recipe | Action |
|--------|--------|
| `just build` | Build both terminal + applet (release) |
| `just build-terminal` | Build terminal only (release) |
| `just build-applet` | Build applet only (release) |
| `just build-debug` | Build both (debug) |

`just install` auto-builds release binaries before invoking the script. `--build-debug` is never part of the install flow.

## Install script (`scripts/install.sh`)

### Flags

| Flag | Effect |
|------|--------|
| *(no args)* | User-local install to `~/.local/{bin,share}` |
| `--system-wide` | System-wide install to `/usr/local/{bin,share}` (prompts for sudo) |
| `--uninstall` | Remove installed files |
| `--yes` | Skip confirmation prompt (for `--uninstall`) |
| `--dry-run` | Preview actions without executing |
| `--help` | Show usage |

### Install paths

**User-local (default):**
- Binaries → `~/.local/bin/`
- Desktop files → `~/.local/share/applications/`
- Icons → `~/.local/share/icons/hicolor/{size}/apps/`

**System-wide (`--system-wide`):**
- Binaries → `/usr/local/bin/`
- Desktop files → `/usr/local/share/applications/`
- Icons → `/usr/share/icons/hicolor/{size}/apps/`

### Post-install behavior

The script replaces binaries in-place without killing running processes. After install, it prints a reminder:

```
✓ Installed to ~/.local/bin/
  → cosmic-guake-term
  → cosmic-guake-term-applet
✓ Installed desktop files to ~/.local/share/applications/
✓ Installed icons to ~/.local/share/icons/hicolor/

⚠ If a previous version was running, log out/in or restart COSMIC
  for changes to take effect.

Add the applet: COSMIC Settings → Desktop → Panel → Add Applet
```

### Uninstall

`--uninstall` prompts for confirmation (showing files to remove), skipped with `--yes`. Requires the same `--system-wide` flag to know which paths to target. After removal, prints the same restart reminder.

### Process management

The script does **not** auto-kill running instances. Replacing a binary while the process runs is safe on Linux (the old inode stays in memory). The post-install message tells the user to restart manually. This avoids the complexity and surprise of killing user processes from an install script.

### sudo handling

`--system-wide` runs all file operations through `sudo`, which prompts for the user's password. No early `sudo -n` check — the user sees the standard sudo prompt.

## Justfile changes

The justfile stays as close to upstream as possible. Only these recipes are added or modified:

- `build` — builds both terminal + applet (release)
- `build-terminal` — new, thin wrapper around `cargo build --release --bin cosmic-guake-term`
- `build-applet` — renamed from `build-applet-release`, builds applet only
- `build-debug` — new, builds both in debug mode
- `install` — calls `scripts/install.sh`
- `uninstall` — calls `scripts/install.sh --uninstall`

All install logic lives in `scripts/install.sh`, not in the justfile. This keeps justfile diffs minimal for upstream rebase.

## Consequences

- **Makefile removed.** No more dual build systems.
- **Upstream rebase:** justfile changes are thin recipe wrappers, conflicts are trivial to resolve.
- **Install script is independently runnable:** `./scripts/install.sh --help` works without `just`.

## Build resource usage

The full release build (terminal + applet) compiles a large dependency tree (libcosmic, iced, cosmic-text, etc.). Cargo uses all available CPU cores by default. A `.cargo/config.toml` with `[build] jobs = N` limits parallelism project-wide (e.g. `jobs = 4` or `jobs = 2` for low-memory systems).
