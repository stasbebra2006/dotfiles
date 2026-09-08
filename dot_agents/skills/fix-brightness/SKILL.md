---
name: fix-brightness
description: Fixes dim screen and missing/frozen brightness controls on desktop KDE Plasma Wayland sessions.
---

# Fix Brightness Skill

This skill provides automatic and manual restoration of screen brightness and controls when KDE Plasma's Powerdevil service hangs or fails to restore the compositor-side software dimming level after a suspend/sleep cycle. It also ensures Night Light (Night Shift) is suspended and left in a suspended state to prevent unwanted color shifting or dimming.

## How to use

If the user reports that their monitor is dimmed (specifically if monitor settings are bright but the system remains dimmed) or if the brightness controls/slider have disappeared:

1. Locate the recovery script: `scripts/fix_brightness.sh` inside this skill directory.
2. Execute the script to automate the restoration:
   ```bash
   bash "$(dirname "${BASH_SOURCE[0]}")/scripts/fix_brightness.sh"
   ```
3. If executing the script isn't possible, manually run the following recovery sequence:
   - Restart the powerdevil service:
     ```bash
     systemctl --user restart plasma-powerdevil.service
     ```
   - Refresh the Wayland compositor's color/gamma tables and suspend Night Light (Night Shift):
     ```bash
     busctl --user call org.kde.KWin /org/kde/KWin/NightLight org.kde.KWin.NightLight preview u 5000 && sleep 1 && busctl --user call org.kde.KWin /org/kde/KWin/NightLight org.kde.KWin.NightLight stopPreview
     # Suspend and leave Night Light (Night Shift) suspended:
     busctl --user call org.kde.KWin /org/kde/KWin/NightLight org.kde.KWin.NightLight inhibit
     ```
   - Enumerate all display DBus paths under `org.kde.ScreenBrightness`:
     ```bash
     busctl --user tree org.kde.ScreenBrightness
     ```
   - For each display path (e.g. `/org/kde/ScreenBrightness/display0`), set the software brightness/dimming level to 100% (value of `10000`):
     ```bash
     busctl --user call org.kde.ScreenBrightness /org/kde/ScreenBrightness/display0 org.kde.ScreenBrightness.Display SetBrightness iu 10000 0
     ```
   - If DBus display paths are not available, use `kscreen-doctor` to force the brightness to 100%:
     ```bash
     kscreen-doctor output.DP-2.brightness.100
     ```

## Preventative Advice

Recommend the user to either:
1. Open **System Settings > Energy Saving** and disable **"Dim screen"** to stop the system from applying software dimming filters that can get stuck when DDC/CI communications time out.
2. Alternatively, disable DDC/CI checks in Powerdevil if they don't change physical monitor backlight via the OS:
   ```bash
   systemctl --user edit plasma-powerdevil.service
   ```
   Add the environment variable `POWERDEVIL_NO_DDCUTIL=1` under the `[Service]` block:
   ```ini
   [Service]
   Environment=POWERDEVIL_NO_DDCUTIL=1
   ```
