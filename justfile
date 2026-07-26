name := 'cosmic-guake-term'
applet-name := name + '-applet'
export APPID := 'io.github.cosmic-guake-term'
APPLET_APPID := APPID + '.GuakeApplet'

rootdir := ''
prefix := '/usr'

base-dir := absolute_path(clean(rootdir / prefix))

export INSTALL_DIR := base-dir / 'share'

cargo-target-dir := env('CARGO_TARGET_DIR', 'target')
bin-src := cargo-target-dir / 'release' / name
bin-dst := base-dir / 'bin' / name

applet-bin-src := cargo-target-dir / 'release' / applet-name
applet-bin-dst := base-dir / 'bin' / applet-name

desktop := APPID + '.desktop'
desktop-src := 'target/xdgen' / desktop
desktop-dst := clean(rootdir / prefix) / 'share' / 'applications' / desktop

applet-desktop := APPLET_APPID + '.desktop'
applet-desktop-src := 'res' / applet-desktop
applet-desktop-dst := clean(rootdir / prefix) / 'share' / 'applications' / applet-desktop

metainfo := APPID + '.metainfo.xml'
metainfo-src := 'target/xdgen' / metainfo
metainfo-dst := clean(rootdir / prefix) / 'share' / 'metainfo' / metainfo

icons-src := 'res' / 'icons' / 'hicolor'
icons-dst := clean(rootdir / prefix) / 'share' / 'icons' / 'hicolor'

# Default recipe which runs `just build-release`
default: build-release

# Runs `cargo clean`
clean:
    cargo clean

# Removes vendored dependencies
clean-vendor:
    rm -rf .cargo vendor vendor.tar

# `cargo clean` and removes vendored dependencies
clean-dist: clean clean-vendor

# Compiles with debug profile
build-debug *args:
    cargo build {{args}}

# Compiles with release profile
build-release *args: (build-debug '--release' args)

# Compiles the applet binary with release profile
build-applet-release *args:
    cargo build --release --bin {{applet-name}} {{args}}

# Compiles release profile with vendored dependencies
build-vendored *args: vendor-extract (build-release '--frozen --offline' args)

# Runs a clippy check
check *args:
    cargo clippy --all-features {{args}} -- -W clippy::pedantic

# Runs a clippy check with JSON message format
check-json: (check '--message-format=json')

dev *args:
    cargo fmt
    just run {{args}}

# Run with debug logs
run *args:
    env RUST_LOG=cosmic_guake_term=debug RUST_BACKTRACE=full cargo run --release {{args}}

# Installs files
install:
    install -Dm0755 {{bin-src}} {{bin-dst}}
    install -Dm0755 {{applet-bin-src}} {{applet-bin-dst}}
    install -Dm0644 {{desktop-src}} {{desktop-dst}}
    install -Dm0644 {{applet-desktop-src}} {{applet-desktop-dst}}
    install -Dm0644 {{metainfo-src}} {{metainfo-dst}}
    for size in `ls {{icons-src}}`; do \
        install -Dm0644 "{{icons-src}}/$size/apps/{{APPID}}.svg" "{{icons-dst}}/$size/apps/{{APPID}}.svg"; \
    done

# Installs binaries to ~/.local for user-local usage
install-local:
    mkdir -p $HOME/.local/bin
    cp {{bin-src}} $HOME/.local/bin/{{name}}
    mkdir -p $HOME/.local/share/applications
    cp {{desktop-src}} $HOME/.local/share/applications/{{desktop}}
    cp {{applet-desktop-src}} $HOME/.local/share/applications/{{applet-desktop}}
    @echo "Installed to ~/.local/bin and ~/.local/share/applications"

# Uninstalls installed files
uninstall:
    rm {{bin-dst}}
    rm {{applet-bin-dst}}
    rm {{applet-desktop-dst}}

# Clears saved COSMIC config (use if terminal doesn't show up after config changes)
reset-config:
    rm -f $HOME/.config/cosmic/{{APPID}}/v1/config.ron
    rm -f $HOME/.config/cosmic/{{APPID}}/v1/guake_config
    @echo "Config cleared. Start the app to generate fresh defaults."

# Vendor dependencies locally
vendor:
    #!/usr/bin/env bash
    mkdir -p .cargo
    cargo vendor --sync Cargo.toml | head -n -1 > .cargo/config.toml
    echo 'directory = "vendor"' >> .cargo/config.toml
    echo >> .cargo/config.toml
    echo '[env]' >> .cargo/config.toml
    if [ -n "${SOURCE_DATE_EPOCH}" ]
    then
        source_date="$(date -d "@${SOURCE_DATE_EPOCH}" "+%Y-%m-%d")"
        echo "VERGEN_GIT_COMMIT_DATE = \"${source_date}\"" >> .cargo/config.toml
    fi
    if [ -n "${SOURCE_GIT_HASH}" ]
    then
        echo "VERGEN_GIT_SHA = \"${SOURCE_GIT_HASH}\"" >> .cargo/config.toml
    fi
    tar pcf vendor.tar .cargo vendor
    rm -rf .cargo vendor

# Extracts vendored dependencies
vendor-extract:
    rm -rf vendor
    tar pxf vendor.tar
