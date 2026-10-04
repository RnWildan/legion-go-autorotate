# Legion Go Auto-Rotate

A Wayland auto-rotation daemon for the **Lenovo Legion Go** handheld, built for
`wlr-randr`-compatible compositors (driftWM, niri, sway, Hyprland, …).

Rotates the built-in display to match physical orientation using the
accelerometer — so the screen follows the device when you flip it into
portrait or landscape.

## Why this exists

Handhelds like the Legion Go get held at every angle — flat on a desk, tilted
back in your hands, flipped sideways. Naive "dominant axis" rotation logic
flutters: a single noisy accelerometer reading can push the ratio over the
threshold and flip the screen when you didn't mean to.

This daemon solves that with a **two-stage design**:

1. **Primary — `iio-sensor-proxy`** (`monitor-sensor --accel`). The proxy has
   battle-tested hysteresis built in, designed exactly for the "tilted
   slightly backward" ambiguity. This is the path that runs in practice.
2. **Fallback — direct sysfs** (when `monitor-sensor` isn't available). Reads
   the accelerometer from `/sys/bus/iio/devices/` with:
   - **Median filtering** (5 samples) to smooth jitter
   - **Flat-clamping** — if the Z axis (screen-perpendicular) is >70% of the
     dominant axis, the device is "too flat" to reliably determine
     orientation, so rotation is held
   - **Confirmation gating** — requires 3 consecutive identical readings
     before switching
   - **Axis-ratio threshold** — the dominant axis must be ≥1.4× the runner-up

## Files

- `legion-go-autorotate` — the daemon (primary + fallback)
- `legion-go-autorotate-toggle` — toggle auto-rotation on/off (flag-file based)
- `legion-go-autorotate.service` — systemd user unit

## Requirements

- A Wayland compositor with `wlr-randr` (driftWM, niri, sway, Hyprland, …)
- `wlr-randr` on `PATH`
- `iio-sensor-proxy` (optional — enables the primary path; the daemon falls
  back to sysfs automatically if absent)
- An accelerometer exposed via Linux IIO (`/sys/bus/iio/devices/`)

## Install

```bash
# Copy the scripts into your PATH
install -m755 legion-go-autorotate legion-go-autorotate-toggle ~/.local/bin/

# Install the systemd user service
install -m644 legion-go-autorotate.service \
  ~/.config/systemd/user/legion-go-autorotate.service

# Enable + start
systemctl --user daemon-reload
systemctl --user enable --now legion-go-autorotate.service
```

## Configure

The daemon reads a few constants at the top of `legion-go-autorotate`:

| Variable | Default | Meaning |
|----------|---------|---------|
| `DISPLAY_NAME` | `eDP-1` | Output to rotate |
| `ACCEL_BASE` | `/sys/bus/iio/devices/iio:device1` | IIO device for the fallback path |
| `POLL_INTERVAL` | `0.3` | Fallback poll interval (s) |
| `MEDIAN_WINDOW` | `5` | Fallback median-filter window |
| `CONFIRM_COUNT` | `3` | Consecutive identical readings to switch |
| `FLAG_FILE` | `~/.config/driftwm/autorotate-disabled` | Toggle flag |

> **Note:** the IIO device index (`iio:device1` vs `iio:device2`) can differ
> between kernels. Check `ls /sys/bus/iio/devices/` and confirm which device
> exposes `in_accel_{x,y,z}_raw` before relying on the fallback path.

## Toggle

Bind `legion-go-autorotate-toggle` to a keybinding to lock/unlock rotation:

```bash
~/.local/bin/legion-go-autorotate-toggle   # ON ⇄ OFF
```

It creates/removes the flag file; the daemon checks it each cycle and holds
the current orientation while disabled.

## Troubleshooting

```bash
# Is the service running?
systemctl --user status legion-go-autorotate.service

# Is rotation toggled off?
ls -la ~/.config/driftwm/autorotate-disabled

# Raw accelerometer values (fallback path)
cat /sys/bus/iio/devices/iio:device1/in_accel_{x,y,z}_raw

# Test the primary path
monitor-sensor --accel
```

## License

MIT
