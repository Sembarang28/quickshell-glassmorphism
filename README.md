# Quickshell config

A [Quickshell](https://quickshell.org) bar, app launcher, and settings panel for [niri](../niri/README.md). It ships two themes that share the same logic and layout:

- **glassmorphism** (default): translucent, blurred pills and popups with pastel accents.
- **neobrutalism**: thick borders, hard offset shadows, and bold colours.

## Related repositories

This config is designed to run under niri, but it can also be used on its own on any Wayland compositor that supports layer-shell:

- **Quickshell config (this repo):** https://github.com/Sembarang28/quickshell-glassmorphism.git
- **niri config (compositor setup, keybinds, themes):** https://github.com/Sembarang28/niri-glassmorphism.git

Without niri, the workspace and focused-app widgets will be empty, and the glassmorphism blur will not appear. Everything else works.

## Launcher (Spotlight-style)

Open it with `Alt+Space` or `Mod+D`. Start typing and the list shows:

- **Apps:** matching desktop applications, as before.
- **Links:** type a URL or a bare domain (`github.com`) and press Enter to open it in Firefox.
- **Calculator:** type an expression such as `12*7+3` or `sqrt(144)` to see the result; press Enter to copy it.
- **Web search:** `Search DuckDuckGo for "…"` is always the last row; Enter opens it in Firefox.

Queries are passed to programs as arguments and URL-encoded, never through a shell.

## Features

- **Top bar**
  - Left: app launcher, niri workspaces, and the focused app (icon and name).
  - Right: audio visualizer, CPU / GPU / RAM / disk usage with temperatures, Wi-Fi, Bluetooth, volume, settings, and the date and time.
- **Launcher:** searchable list of desktop applications.
- **Settings panel:** profile picture, clock, weather, brightness and volume sliders, system specs, media player (MPRIS), CPU/GPU/RAM/disk usage, and power profiles with log out, restart, shut down, and hibernate. Session actions require a second click to confirm.
- **Popups:** Wi-Fi (scan, connect, password prompt), Bluetooth (scan, pair, connect), and Sound (volume and output device).
- **Wallpaper:** `niri/assets/wallpaper.jpg`, drawn on the background layer for every screen.
- **Themes:** the same components and modules are reused by both themes. Only the colours and shapes change.

## Layout

```
~/.config/quickshell/
├── shell.qml              # loads glassmorphism (default)
├── shared/                # logic and resources common to both themes
│   ├── services/
│   │   ├── Sys.qml        # system state: stats, audio, network, niri, cava, specs, weather
│   │   └── Net.qml        # Wi-Fi scanning and connecting (nmcli)
│   ├── components/
│   │   ├── Icon.qml       # SVG icon loader
│   │   └── Wallpaper.qml  # background-layer wallpaper
│   ├── assets/
│   │   ├── icons/         # Lucide SVG icons
│   │   ├── profile.jpeg   # profile picture
│   │   └── wallpaper.jpg  # symlink to niri/assets/wallpaper.jpg
│   ├── config/cava.conf   # cava settings
│   └── scripts/
│       ├── stats.sh       # CPU, GPU, RAM, disk, temperatures, audio, network
│       └── specs.sh       # OS, kernel, CPU, GPU, RAM, uptime, packages
├── glassmorphism/         # theme
│   ├── shell.qml
│   ├── services/Theme.qml # colours and sizes
│   ├── components/        # BrutButton, Card, RowButton, PopupFrame, ...
│   ├── modules/           # Bar, Overlay, Launcher, SettingsPanel, popups
│   └── shared -> ../shared
└── neobrutalism/          # same layout, different look
```

Each theme folder contains a `shared` symlink to the root `shared/` directory. Quickshell refuses to import QML from outside a configuration directory, so the symlink is required. Keep it when you copy or move the folders.

## Requirements

- niri 26.04 or newer, with its `background-effect` protocol (needed for the blur)
- Quickshell 0.3 or newer (`qs`)
- `wpctl` (Pipewire), `nmcli` (NetworkManager), `bluetoothctl` (BlueZ)
- `powerprofilesctl` / `busctl` with power-profiles-daemon running
- `cava` for the visualizer
- `ddcutil` for brightness on external monitors (your user must be in the `i2c` group)
- `nvidia-smi` (optional, for GPU stats)
- `curl` (optional, for the weather widget via wttr.in)
- `libqalculate` (`qalc`) for calculations in the launcher
- `wl-clipboard` (`wl-copy`) to copy calculator results
- `firefox` for opening links and web searches from the launcher
- `systemd` for reboot, poweroff, and hibernate
- Quicksand font installed system-wide

## Install

```sh
git clone <your-repo-url> ~/.config/quickshell
chmod +x ~/.config/quickshell/shared/scripts/*.sh
```

Make sure `~/.config/quickshell/shared` is a directory and that `glassmorphism/shared` and `neobrutalism/shared` are symlinks pointing to `../shared`. Recreate them if your copy dropped the symlinks:

```sh
ln -sfn ../shared ~/.config/quickshell/glassmorphism/shared
ln -sfn ../shared ~/.config/quickshell/neobrutalism/shared
ln -sfn ~/.config/niri/assets/wallpaper.jpg ~/.config/quickshell/shared/assets/wallpaper.jpg
```

## Usage

Run Quickshell with a theme folder. Do not use `qs -c <name>`; it looks for a config named in the standard config directory and will not find these folders.

```sh
qs -p ~/.config/quickshell/glassmorphism -d   # glassmorphism, detached
qs -p ~/.config/quickshell/neobrutalism -d    # neobrutalism, detached
```

With niri, you normally do not run these by hand; `~/.config/niri/scripts/start-shell.sh` starts the theme named in `~/.config/niri/theme`. See the niri README for autostart and theme switching.

### Stopping and restarting

```sh
pkill -x qs            # stop
qs log                 # show the log; look for errors
```

### Panels from the command line

These use Quickshell's IPC handler (`panel`):

```sh
qs ipc call panel toggle launcher
qs ipc call panel toggle settings
qs ipc call panel toggle wifi
qs ipc call panel toggle bluetooth
qs ipc call panel toggle sound
qs ipc call panel close
```

Use `-p <theme-folder>` with the same command if more than one theme is running.

### Customising

- **Colours and sizes:** `<theme>/services/Theme.qml`. Changing a value here affects the whole theme.
- **Bar layout:** `<theme>/modules/Bar.qml`. The left and right item order is the same in both themes; keep them in sync if you change one.
- **Stats and polling:** `shared/services/Sys.qml`. Polling runs every 2 seconds, and weather every 15 minutes.
- **Visualizer:** `shared/config/cava.conf`.
- **Profile picture:** replace `shared/assets/profile.jpeg`.

## Notes

- Brightness uses `ddcutil setvcp 10`. It only controls the first DDC-capable monitor.
- Bluetooth needs the `bluetooth` service to be running (`sudo systemctl enable --now bluetooth`). The panel shows instructions otherwise.
- Hibernate requires a swap file or partition at least as large as your RAM and a `resume=` kernel parameter.
- The Wi-Fi password prompt sends the password to NetworkManager through `nmcli`; it is not stored by Quickshell.
- Quickshell cannot blur the content behind its own windows by itself. The glassmorphism blur is requested through the `BackgroundEffect` protocol, which niri supports.
