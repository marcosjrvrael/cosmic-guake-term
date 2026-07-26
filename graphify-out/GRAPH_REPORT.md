# Graph Report - .  (2026-07-25)

## Corpus Check
- Corpus is ~29,215 words - fits in a single context window. You may not need a graph.

## Summary
- 578 nodes · 1336 edges · 38 communities (28 shown, 10 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 29 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Application Core Architecture
- Config Management
- Key Bindings & Passwords
- Shortcut Configuration
- Terminal Box Widget
- Guake Mode Design
- TerminalBox Rendering
- Terminal Engine
- UI Layout System
- Hint Processing
- Terminal Theme Colors
- Mouse Reporter
- Terminal Flags & Colors
- Drag Auto-Scroll
- Terminal Scroll Input
- Menu System
- Drag & Drop
- TerminalBox Element
- Terminal Size & Scroll
- Terminal Focus State
- Pane Grid Management
- Event Proxy
- Icon Cache
- App Icon Variants
- CI Workflows
- Localization
- OpenCode Plugin Config
- Graphify Plugin
- ANSI Color Script
- Debian Post-Install
- Debian Pre-Remove
- Error Window Icons
- Clear Undo Icons
- Delete Add Icons
- Navigation Icons
- PR Template Checklist
- Context Menu Icon

## God Nodes (most connected - your core abstractions)
1. `Message` - 87 edges
2. `App` - 82 edges
3. `Terminal` - 64 edges
4. `Config` - 31 edges
5. `TerminalBox<'a, Message>` - 29 edges
6. `Action` - 23 edges
7. `TerminalBox` - 20 edges
8. `State` - 20 edges
9. `PasswordManager` - 19 edges
10. `ColorSchemeKind` - 16 edges

## Surprising Connections (you probably didn't know these)
- `Auto-Hide (Focus Loss)` --conceptually_related_to--> `Cosmic Guake Term`  [INFERRED]
  docs/CONTEXT.md → AGENTS.md
- `Daemon` --conceptually_related_to--> `Cosmic Guake Term`  [INFERRED]
  docs/CONTEXT.md → AGENTS.md
- `Global Shortcut` --conceptually_related_to--> `Cosmic Guake Term`  [INFERRED]
  docs/CONTEXT.md → AGENTS.md
- `Flags Struct` --conceptually_related_to--> `Guake Mode`  [INFERRED]
  AGENTS.md → docs/CONTEXT.md
- `Guake Settings UI` --conceptually_related_to--> `Guake Mode`  [INFERRED]
  AGENTS.md → docs/CONTEXT.md

## Import Cycles
- 2-file cycle: `src/key_bind.rs -> src/shortcuts.rs -> src/key_bind.rs`

## Hyperedges (group relationships)
- **CI/CD Pipeline** — _github_workflows_rust_checks_ci_pipeline, _github_workflows_rust_checks_rustfmt, _github_workflows_rust_checks_clippy, _github_workflows_rust_checks_test, _github_workflows_flakehub_publish_rolling_flakehub_publish, _github_workflows_validate_desktop_files_validate_desktop_files [EXTRACTED 0.95]
- **Guake Feature Domain** — docs_context_guake_mode, docs_context_global_shortcut, docs_context_auto_hide_focus_loss, docs_context_anchor, docs_context_window_ratio, agents_guakestate, agents_guake_settings_ui, agents_guake_shortcut_registration, agents_flags_struct, agents_config_struct [INFERRED 0.85]
- **Focus Mode Architecture** — docs_adr_0002_guake_window_management_toggle_mode, docs_adr_0002_guake_window_management_auto_hide_on_focus_loss_mode, docs_adr_0002_guake_window_management_per_monitor_dpi_independence, docs_adr_0002_guake_window_management_guake_window_management [EXTRACTED 1.00]
- **Edit Actions** — res_icons_edit_clear_symbolic_clearaction, res_icons_edit_delete_symbolic_deleteaction, res_icons_edit_undo_symbolic_undoaction, res_icons_list_add_symbolic_addaction [INFERRED 0.85]
- **Navigation Actions** — res_icons_go_down_symbolic_scrolldown, res_icons_go_up_symbolic_scrollup [INFERRED 0.85]
- **Window Management** — res_icons_window_close_symbolic_closeaction, res_icons_view_more_symbolic_contextmenuaction [INFERRED 0.75]
- **App Icon Variants** — res_icons_hicolor_16x16_apps_io_github_cosmic_guake_term_icon, res_icons_hicolor_24x24_apps_io_github_cosmic_guake_term_icon, res_icons_hicolor_32x32_apps_io_github_cosmic_guake_term_icon, res_icons_hicolor_48x48_apps_io_github_cosmic_guake_term_icon, res_icons_hicolor_64x64_apps_io_github_cosmic_guake_term_icon, res_icons_hicolor_128x128_apps_io_github_cosmic_guake_term_icon, res_icons_hicolor_256x256_apps_io_github_cosmic_guake_term_icon [EXTRACTED 1.00]

## Communities (38 total, 10 thin omitted)

### Community 0 - "Application Core Architecture"
Cohesion: 0.05
Nodes (52): About, Application, Axis, ContextDrawer, Dialog, DialogMessage, DialogResult, Direction (+44 more)

### Community 1 - "Config Management"
Cohesion: 0.07
Nodes (29): D, HexColor, Metrics, Ok, S, AppTheme, ColorScheme, ColorSchemeAnsi (+21 more)

### Community 2 - "Key Bindings & Passwords"
Cohesion: 0.13
Nodes (26): FromUtf8Error, MenuAction, key_binds(), HashMap, KeyBind, Action, add_password(), delete_password() (+18 more)

### Community 3 - "Shortcut Configuration"
Cohesion: 0.14
Nodes (27): Modifier, action_label(), Binding, binding_display(), binding_from_key(), BindingSource, fallback_shortcuts(), insert_shortcuts() (+19 more)

### Community 4 - "Terminal Box Widget"
Cohesion: 0.15
Nodes (27): Hyperlink, IndexSet, MutexGuard, accumulate_wheel_lines(), csi(), csi2(), Dragging, edge_scroll_adjustment() (+19 more)

### Community 5 - "Guake Mode Design"
Cohesion: 0.09
Nodes (26): App, Config Struct, cosmic_config Settings, Cosmic Guake Term, Flags Struct, Guake Settings UI, Guake Shortcut Registration, GuakeState (+18 more)

### Community 6 - "TerminalBox Rendering"
Cohesion: 0.16
Nodes (7): B, Fn, P, Self, TerminalBox<'a, Message>, Tag, Widget

### Community 7 - "Terminal Engine"
Cohesion: 0.15
Nodes (11): AppConfig, Arc, Attrs, Buffer, Drop, FairMutex, HashMap, Vec (+3 more)

### Community 8 - "UI Layout System"
Cohesion: 0.14
Nodes (15): Cursor, InputMethod, Interaction, Layout, Length, Limits, Node, Operation (+7 more)

### Community 9 - "Hint Processing"
Cohesion: 0.18
Nodes (14): F, Match, RegexSearch, HintPostProcessor, HintPostProcessor<'a, T>, Item, Iterator, Option (+6 more)

### Community 10 - "Terminal Theme Colors"
Cohesion: 0.24
Nodes (12): ColorScheme, auto_colors(), Colors, ColorScheme, cosmic_dark(), cosmic_light(), export(), From (+4 more)

### Community 11 - "Mouse Reporter"
Cohesion: 0.26
Nodes (9): Button, MouseReporter, Event, Item, Iterator, Modifiers, Option, ScrollDelta (+1 more)

### Community 12 - "Terminal Flags & Colors"
Cohesion: 0.25
Nodes (9): Color, Rgb, Flags, Options, as_bright(), as_dim(), convert_color(), Metadata (+1 more)

### Community 13 - "Drag Auto-Scroll"
Cohesion: 0.26
Nodes (6): Clipboard, Duration, Shell, DragAutoscroll, Event, Point

### Community 14 - "Terminal Scroll Input"
Cohesion: 0.22
Nodes (5): I, Modifiers, ScrollDelta, String, TerminalScroll

### Community 15 - "Menu System"
Cohesion: 0.27
Nodes (12): color_scheme_menu(), context_menu(), menu_bar(), MenuState, Core, Element, Entity, HashMap (+4 more)

### Community 16 - "Drag & Drop"
Cohesion: 0.23
Nodes (9): AllowedMimeTypes, Cow, DndDrop, PathBuf, Result, Self, String, Vec (+1 more)

### Community 17 - "TerminalBox Element"
Cohesion: 0.26
Nodes (10): Border, Mutex, Element<'a, Message, cosmic::Theme, Renderer>, Box, From, HashMap, Id, KeyBind (+2 more)

### Community 18 - "Terminal Size & Scroll"
Cohesion: 0.24
Nodes (4): Dimensions, From, Size, WindowSize

### Community 19 - "Terminal Focus State"
Cohesion: 0.18
Nodes (8): Focusable, Instant, Preedit, calculate_modifier_number(), ClickKind, Cell, Modifiers, State

### Community 20 - "Pane Grid Management"
Cohesion: 0.35
Nodes (3): Pane, TerminalPaneGrid, TabModel

### Community 21 - "Event Proxy"
Cohesion: 0.29
Nodes (8): EventListener, Notifier, EventProxy, Entity, Event, Options, Result, UnboundedSender

### Community 22 - "Icon Cache"
Cohesion: 0.31
Nodes (6): Handle, IconCache, IconCacheKey, HashMap, Icon, Self

### Community 23 - "App Icon Variants"
Cohesion: 0.29
Nodes (7): App Icon 128x128, App Icon 16x16, App Icon 24x24, App Icon 256x256, App Icon 32x32, App Icon 48x48, App Icon 64x64

### Community 24 - "CI Workflows"
Cohesion: 0.33
Nodes (6): FlakeHub Publish, CI Pipeline, Clippy, Rustfmt, Test, Validate Desktop Files

### Community 25 - "Localization"
Cohesion: 0.50
Nodes (4): Localizations, localize(), localizer(), Box

### Community 26 - "OpenCode Plugin Config"
Cohesion: 0.50
Nodes (3): plugin, $schema, .opencode/plugins/graphify.js

## Knowledge Gaps
- **34 isolated node(s):** `$schema`, `.opencode/plugins/graphify.js`, `ansi-colors.sh script`, `Localizations`, `Guake (Inspiration)` (+29 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Message` connect `Application Core Architecture` to `Config Management`, `Key Bindings & Passwords`, `Shortcut Configuration`, `TerminalBox Rendering`, `Drag Auto-Scroll`, `Menu System`, `Drag & Drop`, `TerminalBox Element`?**
  _High betweenness centrality (0.247) - this node is a cross-community bridge._
- **Why does `Terminal` connect `Terminal Engine` to `Application Core Architecture`, `Config Management`, `Terminal Box Widget`, `UI Layout System`, `Hint Processing`, `Terminal Theme Colors`, `Mouse Reporter`, `Terminal Flags & Colors`, `Terminal Scroll Input`, `Menu System`, `TerminalBox Element`, `Terminal Size & Scroll`, `Pane Grid Management`, `Event Proxy`?**
  _High betweenness centrality (0.239) - this node is a cross-community bridge._
- **Why does `App` connect `Application Core Architecture` to `Config Management`, `Key Bindings & Passwords`, `Shortcut Configuration`, `Terminal Flags & Colors`, `Pane Grid Management`?**
  _High betweenness centrality (0.150) - this node is a cross-community bridge._
- **What connects `$schema`, `.opencode/plugins/graphify.js`, `ansi-colors.sh script` to the rest of the system?**
  _34 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Application Core Architecture` be split into smaller, more focused modules?**
  _Cohesion score 0.05153576582148011 - nodes in this community are weakly interconnected._
- **Should `Config Management` be split into smaller, more focused modules?**
  _Cohesion score 0.07077922077922078 - nodes in this community are weakly interconnected._
- **Should `Key Bindings & Passwords` be split into smaller, more focused modules?**
  _Cohesion score 0.13090418353576247 - nodes in this community are weakly interconnected._