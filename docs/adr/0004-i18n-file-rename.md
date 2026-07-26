# ADR-0004: i18n File Rename (`cosmic_term.ftl` → `cosmic_guake_term.ftl`)

The crate was renamed from `cosmic-term` to `cosmic-guake-term` (see `Cargo.toml`). The
translation resource files in `i18n/*/` were renamed from `cosmic_term.ftl` to
`cosmic_guake_term.ftl` to match.

## Why the file name must match the crate name

The `.ftl` file name is **not** arbitrary. It is derived from the crate package name by both
the i18n toolchain components:

1. `i18n-embed`'s `fluent_language_loader!()`/`fl!()` resolve the per-locale resource as
   `i18n/{locale}/{domain}.ftl`, where `domain` defaults to the package name with `-`
   replaced by `_` (`find_crate::Manifest::crate_package().name` calls
   `package_key.replace('-', "_")`). So package `cosmic-guake-term` → lookup
   `i18n/en/cosmic_guake_term.ftl`.
2. `xdgen`'s `Context::new("i18n", CARGO_PKG_NAME)` similarly reads
   `i18n/{locale}/{crate_name.replace('-', "_")}.ftl` in `build.rs`.

Because the crate is named `cosmic-guake-term`, every locale file **must** be
`cosmic_guake_term.ftl` or neither the build script nor runtime localization will find it.
Keeping the upstream name (`cosmic_term.ftl`) would require keeping the crate name
`cosmic-term`, which conflicts with the fork identity (ADR-0001).

## Rebase cost

Upstream translations are edited under `i18n/*/cosmic_term.ftl`. Since our fork carries the
files under the renamed `cosmic_guake_term.ftl`, every upstream translation commit becomes a
modify/delete conflict (`{lang}/cosmic_term.ftl` deleted by us, modified upstream). On each
rebase these must be resolved by forwarding the upstream edits into the renamed file.

### Handling new locales added upstream

When upstream adds a brand-new locale (e.g. `i18n/sat/cosmic_term.ftl`), the file arrives
under the old name and must be renamed as part of the rebase, otherwise `build.rs` (xdgen)
fails with `No such file or directory` because no `cosmic_guake_term.ftl` exists there:

```bash
git mv i18n/sat/cosmic_term.ftl i18n/sat/cosmic_guake_term.ftl
git add i18n/
```