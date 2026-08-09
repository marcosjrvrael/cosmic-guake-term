name := 'cosmic-guake-term'
applet-name := name + '-applet'
export APPID := 'io.github.cosmic-guake-term'
APPLET_APPID := APPID + '.GuakeApplet'

cargo-target-dir := env('CARGO_TARGET_DIR', 'target')
bin-src := cargo-target-dir / 'release' / name
applet-bin-src := cargo-target-dir / 'release' / applet-name

# Default recipe which runs `just build`
default: build

# Runs `cargo clean`
clean:
    cargo clean

# Removes vendored dependencies
clean-vendor:
    rm -rf .cargo vendor vendor.tar

# `cargo clean` and removes vendored dependencies
clean-dist: clean clean-vendor

# Compiles both terminal and applet with release profile
build:
    cargo build --release --bin {{name}}
    cargo build --release --bin {{applet-name}}

# Compiles terminal only with release profile
build-terminal:
    cargo build --release --bin {{name}}

# Compiles applet only with release profile
build-applet:
    cargo build --release --bin {{applet-name}}

# Compiles both with debug profile
build-debug:
    cargo build --bin {{name}}
    cargo build --bin {{applet-name}}

# Compiles release profile with vendored dependencies
build-vendored: vendor-extract
    cargo build --release --frozen --offline --bin {{name}}
    cargo build --release --frozen --offline --bin {{applet-name}}

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

# Installs files via install script (builds first)
install *args: build
    ./scripts/install.sh {{args}}

# Uninstalls installed files
uninstall *args:
    ./scripts/install.sh --uninstall {{args}}

# Clears saved COSMIC config (use if terminal doesn't show up after config changes)
reset-config:
    rm -f $HOME/.config/cosmic/{{APPID}}/v1/config.ron
    rm -f $HOME/.config/cosmic/{{APPID}}/v1/guake_config
    @echo "Config cleared. Start the app to generate fresh defaults."

# Kills the running cosmic-guake-term process
stop:
    pkill -SIGUSR1 -f "cosmic-guake-term" 2>/dev/null; sleep 0.5; pkill -9 -f "cosmic-guake-term" 2>/dev/null || echo "app not running"

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
