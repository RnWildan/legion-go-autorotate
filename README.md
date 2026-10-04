# Legion Go Auto-Rotate (Niri)

Auto-rotation for the Lenovo Legion Go handheld on the Niri Wayland
compositor. It rotates the built-in display to match physical orientation
using the accelerometer, so the screen follows the device when you flip it
into portrait or landscape.

## How it works

A small daemon that pipes `monitor-sensor` (from `iio-sensor-proxy`) into
`niri msg output ... transform ...`:

- `monitor-sensor` reads the accelerometer and emits orientation changes
  (`normal`, `left-up`, `right-up`, `bottom-up`). It has hysteresis built in,
  so it handles the "tilted slightly backward" ambiguity without fluttering.
- `niri msg output eDP-1 transform ...` applies the rotation live.

The daemon is a single `while read` loop. No polling, no sysfs math, no state.
`monitor-sensor` does the heavy lifting.

## Files

- `niri-autorotate.sh` is the daemon (monitor-sensor to niri transform)
- `niri-rotate-toggle.sh` toggles auto-rotation on and off (pgrep/pkill based)

## Requirements

- Niri Wayland compositor
- `niri` on `PATH` (for `niri msg`)
- `iio-sensor-proxy` (provides `monitor-sensor`)
- An accelerometer exposed via Linux IIO

## Install

```bash
# Copy the scripts into your PATH
install -m755 niri-autorotate.sh niri-rotate-toggle.sh ~/.local/bin/

# Auto-start the daemon. Add to your niri autostart config
# (e.g. ~/.config/niri/config.kdl):
#   spawn-sh-at-startup "~/.local/bin/niri-autorotate.sh"
```

## Toggle

Bind `niri-rotate-toggle.sh` to a keybinding (e.g. `Mod+Shift+R` in niri):

```bash
~/.local/bin/niri-rotate-toggle.sh   # ON or OFF
```

It checks whether the daemon is running. If it is, it kills it (and
`monitor-sensor`). Otherwise it starts it. It sends a desktop notification
either way.

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
