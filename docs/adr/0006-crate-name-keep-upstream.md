# ADR-0006: Keep Upstream Crate Name (`cosmic-term`) for i18n Compatibility

## Decision

Change `Cargo.toml` to keep the crate name as `cosmic-term` (matching upstream), while renaming only the binary to `cosmic-guake-term`:

```toml
[package]
name = "cosmic-term"           # Keep upstream crate name
version = "0.1.0"
edition = "2021"

[[bin]]
name = "cosmic-guake-term"     # Binary gets fork identity
path = "src/main.rs"
```

Revert i18n files from `cosmic_guake_term.ftl` back to `cosmic_term.ftl` in all locales. Update `build.rs` to use the default i18n domain (no absolute path fix needed).

## Rationale

The crate rename to `cosmic-guake-term` (ADR-0001) forced i18n file renames (ADR-0004) because:
- `xdgen` and `i18n-embed` derive the `.ftl` filename from `CARGO_PKG_NAME` (crate name)
- Upstream uses `cosmic_term.ftl`; fork used `cosmic_guake_term.ftl`
- Every upstream translation commit became a modify/delete conflict on rebase (~20 locales)

Keeping the crate name `cosmic-term` eliminates all i18n conflicts. The fork identity is preserved via:
- Binary name: `cosmic-guake-term`
- Desktop file ID: `io.github.cosmic-guake-term`
- App ID in code: `io.github.cosmic-guake-term`
- Install paths: `~/.local/bin/cosmic-guake-term`

## Consequences

**Positive:**
- Zero i18n conflicts on rebase (biggest pain point eliminated)
- `build.rs` reverts to upstream default (no absolute path hack)
- Upstream `Cargo.lock` merges cleanly (same crate name)
- No upstream coordination needed

**Negative:**
- `cargo metadata` shows `cosmic-term` (not `cosmic-guake-term`)
- If published to crates.io, would conflict with upstream (not planned — private fork)
- Dependency graphs show upstream name

**Neutral:**
- Code conflicts in `main.rs`, `config.rs`, `key_bind.rs`, `shortcuts.rs`, `menu.rs`, `justfile` remain — but these are manageable and already resolved each rebase

## Migration Steps

1. Edit `Cargo.toml`: change `name = "cosmic-guake-term"` → `name = "cosmic-term"`, add `[[bin]]` section
2. Rename all `i18n/*/cosmic_guake_term.ftl` → `i18n/*/cosmic_term.ftl` (`git mv`)
3. Revert `build.rs` to upstream (remove absolute i18n path fix)
4. `just build` to verify
5. Next rebase: i18n conflicts gone, only code conflicts remain

## Follow-up (Option B)

File PR to `pop-os/cosmic-term` for an embedding API (`TerminalWidget`, `Config`, `App::run` as library). If accepted, migrate to thin wrapper crate depending on upstream as git dependency — eliminates remaining code conflicts.