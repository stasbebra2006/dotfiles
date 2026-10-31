# Steam gaming on Arch Linux

## Setup on 2026-10-24

Machine: KDE Plasma Wayland, Intel Core i5-14600KF, AMD Radeon RX 9060 XT,
32 GB RAM. The Linux filesystem is ext4.

Steam was absent, `multilib` was disabled, and only the 64-bit Mesa/RADV
graphics libraries were installed. Steam needs the corresponding 32-bit
libraries as well.

Enabled only the stable `multilib` block in `/etc/pacman.conf`:

```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

Original configuration backup:
`/etc/pacman.conf.before-steam-20261024T222707`.

Installed using a full update to avoid a partial Arch upgrade:

```sh
sudo pacman -Syu --needed lib32-mesa lib32-vulkan-radeon steam ntsync-autoload
```

The transaction completed successfully, including initramfs generation and
Secure Boot signing. Installed versions include Steam `1.0.0.87-3`, Mesa/RADV
`26.2.5-1` in both architectures, and Linux `7.2.11.arch1-1`. Steam's
dependencies include controller udev rules (`steam-devices`) and the 32-bit
Vulkan loader. Steam supplies Proton; a separate Wine installation is not
required for this setup.

## Verification and reboot

- `pacman -Qk steam steam-devices lib32-mesa lib32-vulkan-radeon ntsync-autoload`
  reported no missing files.
- `ldd /usr/lib32/libvulkan_radeon.so` resolved every dependency.
- `vulkaninfo --summary` detected the RX 9060 XT using Mesa RADV 26.2.5.
  The pre-existing RADV "not a conformant Vulkan implementation" warning was
  still printed; this check establishes device discovery, not game rendering.
- Kernel and initramfs files were present and non-empty after the update.
- No official repository updates remained immediately after the transaction.

Reboot before playing: the session was still running `7.2.9-arch1-1`, and
`/dev/ntsync` was not yet present. `ntsync-autoload` is installed for subsequent
boots. Do not infer that the new kernel or NTSync has been tested until reboot.

Steam was launched detached from the agent using:

```sh
systemd-run --user --collect --unit=steam-setup-20261024 /usr/bin/steam
```

Its initial client download and update completed. Steam reported that its
requirements were satisfied, the user service remained active, and both Steam
and `steamwebhelper` were running. `xprop` confirmed a Steam window titled
`Sign in to Steam`. Account sign-in was left to the user.

## Games

- Valheim has a native Linux build. Start with Steam's default installation.
- Deadlock uses Proton. Start with Steam's selected compatibility tool; use the
  game's Properties > Compatibility to try Proton Experimental if needed.
- Valheim's native Linux/Vulkan build was confirmed running on 2026-10-26.
  Deadlock gameplay has not been verified in these notes.

## Valheim FPS drop with Night Light (2026-10-26)

On Plasma/KWin 6.8.1, Linux 7.2.11, Mesa 26.2.5, and Valheim 1.0.20,
gameplay dropped to roughly 47–60 FPS while opening any game UI, including
a chest, restored approximately 165 FPS. DP-2 remained at 164.83 Hz;
VSync was disabled and the saved FPS limit was unlimited. GPU utilization
during a ten-second gameplay sample was mostly 36–49%, at 57°C.

The user confirmed that turning off Night Light removed the FPS drop.
This resembles [KDE bug 527766](https://bugs.kde.org/show_bug.cgi?id=527766),
which reports a fullscreen performance regression with Night Light and
the display's efficiency preference. Its internal cause has not been
independently established on this machine.

With permission, changed only the main display's preference:

```sh
kscreen-doctor output.DP-2.colorPowerTradeoff.preferAccuracy
```

Verified the live preference and the single-field persisted configuration
diff. Both monitors retained their modes, positions, scale, rotation,
priority, and brightness. The secondary HDMI-A-1 display still uses
`PreferEfficiency`. The user subsequently confirmed gameplay was good.
At the follow-up check, Night Light was still inhibited (`running: false`);
the preference change with Night Light actively running remains unverified.

The unmanaged `~/.config/kwinoutputconfig.json` was backed up to
`~/.local/state/kde-display-backups/kwinoutputconfig-20261026-150604.json`.
To restore just the previous preference, use
`kscreen-doctor output.DP-2.colorPowerTradeoff.preferEfficiency`.

References: [Arch Steam setup](https://wiki.archlinux.org/title/Steam),
[Arch AMDGPU setup](https://wiki.archlinux.org/title/AMDGPU),
[Valve Proton](https://github.com/ValveSoftware/Proton).
