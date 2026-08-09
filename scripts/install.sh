#!/usr/bin/env bash
set -euo pipefail

# cosmic-guake-term install script
# See docs/adr/0005-build-system-and-install-script.md

APPID="io.github.cosmic-guake-term"
APPLET_APPID="${APPID}.GuakeApplet"
BIN_NAME="cosmic-guake-term"
APPLET_NAME="cosmic-guake-term-applet"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CARGO_TARGET_DIR="${CARGO_TARGET_DIR:-${REPO_ROOT}/target}"

BIN_SRC="${CARGO_TARGET_DIR}/release/${BIN_NAME}"
APPLET_SRC="${CARGO_TARGET_DIR}/release/${APPLET_NAME}"

DESKTOP_SRC="${REPO_ROOT}/res/${APPID}.desktop"
APPLET_DESKTOP_SRC="${REPO_ROOT}/res/${APPLET_APPID}.desktop"
ICONS_SRC="${REPO_ROOT}/res/icons/hicolor"

# Defaults
SYSTEM_WIDE=false
UNINSTALL=false
YES=false
DRY_RUN=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Install or uninstall cosmic-guake-term binaries, desktop files, and icons.

Options:
  --system-wide    Install to /usr/local instead of ~/.local (requires sudo)
  --uninstall      Remove installed files
  --yes            Skip confirmation prompt (for --uninstall)
  --dry-run        Preview actions without executing
  --help           Show this help message

Examples:
  ./scripts/install.sh                     # User-local install
  sudo ./scripts/install.sh --system-wide  # System-wide install
  ./scripts/install.sh --uninstall         # Remove user-local files
  ./scripts/install.sh --uninstall --yes   # Remove without prompting
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --system-wide) SYSTEM_WIDE=true; shift ;;
            --uninstall) UNINSTALL=true; shift ;;
            --yes) YES=true; shift ;;
            --dry-run) DRY_RUN=true; shift ;;
            --help) usage; exit 0 ;;
            *) echo "Unknown option: $1"; usage; exit 1 ;;
        esac
    done
}

# Resolve install paths based on mode
resolve_paths() {
    if $SYSTEM_WIDE; then
        PREFIX="/usr/local"
        BIN_DIR="${PREFIX}/bin"
        DESKTOP_DIR="${PREFIX}/share/applications"
        ICON_BASE="/usr/share/icons/hicolor"
    else
        BIN_DIR="${HOME}/.local/bin"
        DESKTOP_DIR="${HOME}/.local/share/applications"
        ICON_BASE="${HOME}/.local/share/icons/hicolor"
    fi
}

run_cmd() {
    if $DRY_RUN; then
        echo "  [dry-run] $*"
    else
        "$@"
    fi
}

sudo_cmd() {
    if $SYSTEM_WIDE; then
        if $DRY_RUN; then
            echo "  [dry-run] sudo $*"
        else
            sudo "$@"
        fi
    else
        run_cmd "$@"
    fi
}

do_install() {
    # Check binaries exist
    if [[ ! -f "$BIN_SRC" ]]; then
        if $DRY_RUN; then
            echo "  [dry-run] Warning: Terminal binary not found at ${BIN_SRC}"
        else
            echo "Error: Terminal binary not found at ${BIN_SRC}"
            echo "Run 'just build' first."
            exit 1
        fi
    fi
    if [[ ! -f "$APPLET_SRC" ]]; then
        if $DRY_RUN; then
            echo "  [dry-run] Warning: Applet binary not found at ${APPLET_SRC}"
        else
            echo "Error: Applet binary not found at ${APPLET_SRC}"
            echo "Run 'just build' first."
            exit 1
        fi
    fi

    resolve_paths

    echo "Installing cosmic-guake-term..."
    if $SYSTEM_WIDE; then
        echo "  Mode: system-wide (--system-wide)"
    else
        echo "  Mode: user-local"
    fi
    echo ""

    # Binaries
    echo "Binaries:"
    sudo_cmd mkdir -p "$BIN_DIR"
    sudo_cmd cp "$BIN_SRC" "${BIN_DIR}/${BIN_NAME}"
    echo "  → ${BIN_DIR}/${BIN_NAME}"
    sudo_cmd cp "$APPLET_SRC" "${BIN_DIR}/${APPLET_NAME}"
    echo "  → ${BIN_DIR}/${APPLET_NAME}"
    echo ""

    # Desktop files
    echo "Desktop files:"
    sudo_cmd mkdir -p "$DESKTOP_DIR"
    sudo_cmd cp "$DESKTOP_SRC" "${DESKTOP_DIR}/${APPID}.desktop"
    echo "  → ${DESKTOP_DIR}/${APPID}.desktop"
    sudo_cmd cp "$APPLET_DESKTOP_SRC" "${DESKTOP_DIR}/${APPLET_APPID}.desktop"
    echo "  → ${DESKTOP_DIR}/${APPLET_APPID}.desktop"
    echo ""

    # Icons
    echo "Icons:"
    for size_dir in "${ICONS_SRC}"/*/; do
        size="$(basename "$size_dir")"
        icon_file="${size_dir}apps/${APPID}.svg"
        if [[ -f "$icon_file" ]]; then
            dest_dir="${ICON_BASE}/${size}/apps"
            sudo_cmd mkdir -p "$dest_dir"
            sudo_cmd cp "$icon_file" "${dest_dir}/${APPID}.svg"
            echo "  → ${dest_dir}/${APPID}.svg"
        fi
    done
    # Symbolic icon
    symbolic_src="${ICONS_SRC}/symbolic/apps/${APPID}-symbolic.svg"
    if [[ -f "$symbolic_src" ]]; then
        dest_dir="${ICON_BASE}/symbolic/apps"
        sudo_cmd mkdir -p "$dest_dir"
        sudo_cmd cp "$symbolic_src" "${dest_dir}/${APPID}-symbolic.svg"
        echo "  → ${dest_dir}/${APPID}-symbolic.svg"
    fi
    if ! $DRY_RUN; then
        if command -v gtk-update-icon-cache &>/dev/null; then
            gtk-update-icon-cache "${ICON_BASE}" 2>/dev/null || true
        fi
    fi
    echo ""

    # Post-install message
    echo "✓ Install complete."
    echo ""
    echo "⚠ If a previous version was running, log out/in or restart COSMIC"
    echo "  for changes to take effect."
    echo ""
    echo "Add the applet: COSMIC Settings → Desktop → Panel → Add Applet"
}

do_uninstall() {
    resolve_paths

    # Collect files to remove
    local files=()
    [[ -f "${BIN_DIR}/${BIN_NAME}" ]] && files+=("${BIN_DIR}/${BIN_NAME}")
    [[ -f "${BIN_DIR}/${APPLET_NAME}" ]] && files+=("${BIN_DIR}/${APPLET_NAME}")
    [[ -f "${DESKTOP_DIR}/${APPID}.desktop" ]] && files+=("${DESKTOP_DIR}/${APPID}.desktop")
    [[ -f "${DESKTOP_DIR}/${APPLET_APPID}.desktop" ]] && files+=("${DESKTOP_DIR}/${APPLET_APPID}.desktop")

    # Icons
    for size_dir in "${ICONS_SRC}"/*/; do
        size="$(basename "$size_dir")"
        icon_file="${size_dir}apps/${APPID}.svg"
        local dest="${ICON_BASE}/${size}/apps/${APPID}.svg"
        [[ -f "$dest" ]] && files+=("$dest")
    done
    local symbolic_dest="${ICON_BASE}/symbolic/apps/${APPID}-symbolic.svg"
    [[ -f "$symbolic_dest" ]] && files+=("$symbolic_dest")

    if [[ ${#files[@]} -eq 0 ]]; then
        echo "Nothing to uninstall — no installed files found."
        exit 0
    fi

    echo "Files to remove:"
    for f in "${files[@]}"; do
        echo "  ${f}"
    done
    echo ""

    if ! $YES; then
        read -r -p "Remove these files? [y/N] " answer
        if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
            echo "Aborted."
            exit 0
        fi
    fi

    echo ""
    echo "Uninstalling cosmic-guake-term..."
    for f in "${files[@]}"; do
        sudo_cmd rm -f "$f"
        echo "  ✗ ${f}"
    done
    echo ""

    if ! $DRY_RUN; then
        if command -v gtk-update-icon-cache &>/dev/null; then
            gtk-update-icon-cache "${ICON_BASE}" 2>/dev/null || true
        fi
    fi

    echo "✓ Uninstall complete."
    echo ""
    echo "⚠ If cosmic-guake-term was running, log out/in or restart COSMIC"
    echo "  for changes to take effect."
}

main() {
    parse_args "$@"

    if $UNINSTALL; then
        do_uninstall
    else
        do_install
    fi
}

main "$@"
