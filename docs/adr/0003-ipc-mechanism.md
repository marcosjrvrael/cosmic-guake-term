# ADR-0003: Global Shortcut via CLI Flag + Unix Socket IPC

On Wayland, applications only receive keyboard events when they have keyboard focus.
When the guake terminal is hidden, it has no focused surfaces, so it cannot listen for
a keybinding directly. This ADR documents how we work around that limitation.

## Decision

We expose a `--toggle` CLI flag. When invoked:

1. The process tries to connect to a Unix socket at
   `$XDG_RUNTIME_DIR/cosmic-guake-term.sock`.
2. If the socket exists, it sends `"toggle\n"` and exits.
3. If the socket does not exist (no running instance), it falls through to start
   the app normally (daemonizing to background).

The running instance listens on this socket via `tokio::net::UnixListener` in an
`IpcSubscription` (iced stream channel), dispatching `Message::GuakeToggle`.

### Supported IPC Commands

| Command | Message | Effect |
|---------|---------|--------|
| `toggle` | `GuakeToggle` | Show/hide the overlay terminal |
| `settings` | `GuakeSettings` | Toggle inline settings view + ensure terminal visible |
| `quit` | `WindowClose` | Terminate the daemon |

### SIGUSR1 Fallback

As a secondary toggle mechanism, the app subscribes to `SIGUSR1` via
`tokio::signal::unix`, dispatched to `Message::GuakeToggle`. This enables
`pkill -SIGUSR1 -f "cosmic-guake-term"` as a terminal-based toggle.

## Rationale

- **No custom IPC protocol**: Plain text over Unix domain sockets; trivially
  testable with `echo "toggle" | nc -U $XDG_RUNTIME_DIR/cosmic-guake-term.sock`.
- **No D-Bus dependency**: COSMIC desktop does not require D-Bus; Unix sockets
  work on all Linux configurations.
- **No polling**: The IPC subscription is event-driven (async `accept` loop),
  consuming no CPU while idle.

## User Facing

Users bind `cosmic-guake-term --toggle` to a keyboard shortcut in
COSMIC Settings → Keyboard → Keyboard Shortcuts. On each shortcut press,
the COSMIC compositor spawns the CLI process, which sends the toggle command
to the running daemon and exits.
