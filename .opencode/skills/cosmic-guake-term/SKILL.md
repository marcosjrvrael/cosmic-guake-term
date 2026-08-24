# Skill: cosmic-guake-term

This skill loads the AGENTS.md context for the Cosmic Guake Term project — a fork of cosmic-term with Guake-style dropdown terminal.

## Usage

```
/skill cosmic-guake-term
```

Or reference the AGENTS.md directly in your prompt.

## Project Context

**Fork of [cosmic-term](https://github.com/pop-os/cosmic-term)** adding a "Guake mode": a Quake-style drop-down terminal that shows/hides with a global keyboard shortcut, with configurable position (top/bottom/center), dimensions, auto-hide on focus loss, and multi-tab support.

**This is a `just` project** — use `just` commands for all build/install operations. Do not run `cargo build` directly; the justfile handles binary names, flags, and install script coordination.

## Key Files

| File | Purpose |
|------|---------|
| `justfile` | Build/install recipes (build, build-terminal, build-applet, build-debug, install, uninstall) |
| `src/main.rs` | Entrypoint — parses args, loads config, spawns App |
| `src/config.rs` | Config struct + cosmic_config entry (extended with guake settings) |
| `src/guake/mod.rs` | GuakeState — visibility toggle logic |
| `src/applet/main.rs` | Panel applet binary (Toggle + Settings buttons, IPC) |
| `src/build.rs` | Build script — must use absolute path for i18n dir |
| `scripts/install.sh` | Install script for binaries, .desktop files, icons |

## Upstream Sync Workflow

```bash
git fetch upstream
git rebase upstream/master
# Resolve conflicts (see patterns below)
just build
git checkout -b sync-upstream-$(date +%Y-%m-%d)
git push origin sync-upstream-$(date +%Y-%m-%d)
```

## Conflict Resolution Patterns

### Files that commonly conflict:
- **Cargo.toml**: Keep fork's `name = "cosmic-guake-term"`, take upstream's `version`
- **Cargo.lock**: Take upstream's (`git checkout --theirs Cargo.lock && git add Cargo.lock`)
- **src/main.rs**, **src/config.rs**, **src/key_bind.rs**, **src/shortcuts.rs**, **src/menu.rs**: Keep both upstream changes + guake additions
- **justfile**: Keep fork's APPID rename (`io.github.cosmic-guake-term`)
- **src/build.rs**: Keep fork's absolute i18n path fix
- **i18n/*/cosmic_term.ftl**: Rename to `cosmic_guake_term.ftl`

### i18n file handling:
```bash
# New locale added upstream
git mv i18n/NEW_LOCALE/cosmic_term.ftl i18n/NEW_LOCALE/cosmic_guake_term.ftl
git add i18n/NEW_LOCALE/

# Upstream modified a renamed locale
git show HEAD:i18n/LOCALE/cosmic_term.ftl > i18n/LOCALE/cosmic_guake_term.ftl
git add i18n/LOCALE/cosmic_guake_term.ftl
git rm i18n/LOCALE/cosmic_term.ftl 2>/dev/null || true
```

### build.rs fix (always needed after rebase):
```rust
let manifest_dir = env::var("CARGO_MANIFEST_DIR").unwrap();
let i18n_dir = PathBuf::from(&manifest_dir).join("i18n");
let ctx = Context::new(&i18n_dir, ...).unwrap();
let output = PathBuf::from(&manifest_dir).join("target/xdgen");
```

## Build Commands

```bash
just build             # release build (both terminal + applet)
just build-terminal    # terminal only
just build-applet      # applet only
just build-debug       # debug build
just install           # install via scripts/install.sh
just uninstall         # uninstall
```

## Architecture Decisions (ADRs)

- ADR-0001: Fork Strategy
- ADR-0002: Guake Window Management (layer shell overlay)
- ADR-0003: Global Shortcut via CLI + Unix Socket IPC
- ADR-0004: i18n File Rename (cosmic_term.ftl → cosmic_guake_term.ftl)
- ADR-0005: Build System and Install Script