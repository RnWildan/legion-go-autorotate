# Legion Go Auto-Rotate (Niri)

Auto-rotation for the **Lenovo Legion Go** handheld on the **Niri** Wayland
compositor. Rotates the built-in display to match physical orientation using
the accelerometer — so the screen follows the device when you flip it into
portrait or landscape.

## How it works

A tiny daemon that pipes `monitor-sensor` (from `iio-sensor-proxy`) into
`niri msg output … transform …`:

- **`monitor-sensor`** reads the accelerometer and emits orientation changes
  (`normal`, `left-up`, `right-up`, `bottom-up`). It has battle-tested
  hysteresis built in, so it handles the "tilted slightly backward" ambiguity
  without fluttering.
- **`niri msg output eDP-1 transform …`** applies the rotation live.

The daemon is a single `while read` loop — no polling, no sysfs math, no
state. `monitor-sensor` does the heavy lifting.

## Files

- `niri-autorotate.sh` — the daemon (monitor-sensor → niri transform)
- `niri-rotate-toggle.sh` — toggle auto-rotation on/off (pgrep/pkill based)

## Requirements

- **Niri** Wayland compositor
- `niri` on `PATH` (for `niri msg`)
- `iio-sensor-proxy` (provides `monitor-sensor`)
- An accelerometer exposed via Linux IIO

## Install

```bash
# Copy the scripts into your PATH
install -m755 niri-autorotate.sh niri-rotate-toggle.sh ~/.local/bin/

# Auto-start the daemon — add to your niri autostart config
# (e.g. ~/.config/niri/config.kdl):
#   spawn-sh-at-startup "~/.local/bin/niri-autorotate.sh"
```

## Toggle

Bind `niri-rotate-toggle.sh` to a keybinding (e.g. `Mod+Shift+R` in niri):

```bash
~/.local/bin/niri-rotate-toggle.sh   # ON ⇄ OFF
```

It checks whether the daemon is running; if so it kills it (and
`monitor-sensor`), otherwise it starts it. Sends a desktop notification either
way.

## Configure

The output name is hardcoded as `eDP-1` at the top of `niri-autorotate.sh`.
Change it if your display uses a different name (check with `niri msg outputs`).

## Troubleshooting

```bash
# Is the daemon running?
pgrep -af "niri-autorotate.sh"

# Test the sensor directly
monitor-sensor

# List outputs (confirm the name is eDP-1)
niri msg outputs
```

## License

MIT
