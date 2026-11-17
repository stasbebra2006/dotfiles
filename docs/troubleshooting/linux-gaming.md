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

## Steam download stalls over HTTP/2 (2026-11-05)

On Steam client `1792618285` over wired Ethernet (`enp6s0`, IPv4-only), game
updates such as Deadlock (`AppID 1422450`) initially burst to 433–985 Mbps in
`~/.local/share/Steam/logs/content_log.txt` and then collapsed to
0.004–0.017 Mbps after roughly 60 seconds.

Logs and `ss -tinp` showed two contributing behaviors:

- Steam enabled `HTTP/2 available` against `cache1`–`cache12-vie1.steamcontent.com`.
  Eight of the nine CDN connections went idle and closed while the single
  remaining TCP socket (`146.66.155.8:443`) stalled with `rto:8196`,
  `rtt:1725.11` (versus a 15 ms ICMP ping), `cwnd:4`, and `rcv_ooopack:349`.
  By contrast, sessions that used `cache*-fra1.steamcontent.com` sustained
  1,404–1,497 Mbps.
- `~/.local/share/Steam/logs/connection_log.txt` attempted an IPv6 HTTP probe
  on startup (`ipv6check-http.steamserver.net`, likely triggered by
  `tailscale0`'s ULA address while `enp6s0` has no global IPv6), timed out
  after ~65 seconds, and logged `IPv6 Connectivity state has changed,
  downgrading to ipv4-only` mid-download.

Created the unmanaged `~/.local/share/Steam/steam_dev.cfg`:

```ini
@nClientDownloadEnableHTTP2PlatformLinux 0
@fDownloadRateImprovementToAddAnotherConnection 1.0
@nClientEnableIPv6ForHTTPPlatformLinux 0
```

Verified the ConVar names and defaults (`1.2` for
`@fDownloadRateImprovementToAddAnotherConnection`) against
`~/.local/share/Steam/ubuntu12_32/steamclient.so`. Steam was not running when
the file was written; confirming that `HTTP/2 available` and the IPv6 HTTP
timeout no longer occur in `content_log.txt` and `connection_log.txt` requires
the next Steam launch and download. To revert, remove
`~/.local/share/Steam/steam_dev.cfg` and restart Steam.

## Sunshine streaming to an M4 Mac over LAN (2026-11-10)

Installed the official native Arch package `sunshine 2026.914.233613-1`
from [LizardByte's stable repository](https://github.com/LizardByte/pacman-repo).
Verified its SHA-256 against both the repository database and GitHub asset
metadata before installation. Only the missing dependencies `libmfx` and
`miniupnpc` were installed; the existing Arch repositories were not refreshed
or upgraded. Added the stable `lizardbyte` repository to `/etc/pacman.conf`
for future regular `pacman -Syu` updates. Configuration backup:
`/etc/pacman.conf.before-sunshine-20261110`.

The live, currently unmanaged `~/.config/sunshine/sunshine.conf` selects:

```ini
capture = kwin
encoder = vaapi
adapter_name = /dev/dri/renderD128
output_name = DP-2
upnp = disabled
```

The user service `app-dev.lizardbyte.app.Sunshine.service` is enabled for
desktop login. Startup probes successfully captured DP-2 through KWin and
PipeWire DMA-BUF buffers and detected H.264, HEVC, and AV1 VA-API encoders on
the RX 9060 XT with Mesa 26.2.6 and Linux 7.2.14. `pacman -Qk sunshine`
reported 127 files with none missing. The desktop's existing display layout
was retained: DP-2 is 1920x1080 at 164.83 Hz. Selecting a larger Moonlight
resolution alone cannot create a native Retina-resolution source; a virtual
display or another source-display arrangement is a subsequent setup step.

Initial automatic discovery failed with `Failed to create client: Daemon
not running` because Avahi was installed but stopped. Enabled and started
`avahi-daemon.service`, then restarted Sunshine. Verified the log message
`Avahi service stasbebra2006 successfully established` and resolved
`_nvstream._tcp` on `enp6s0` to `192.168.1.39:47989`. The Ethernet link reports
2500 Mbps; the M4 Mac will use Wi-Fi. This does not measure Wi-Fi throughput
or latency.

The setup page returned HTTP 200 at `https://192.168.1.39:47990/`; it uses
Sunshine's self-signed certificate. Creating the web account, pairing the
Mac, and testing actual gameplay, audio, controls, latency, and quality
remain pending. Keep the `Desktop` and `Steam Big Picture` entries. Removed
the supplied `Low Res Desktop` X11/xrandr example because its hard-coded
HDMI-1 modes do not describe this Wayland session; original app list:
`~/.config/sunshine/apps.json.initial-20261110`.

To stop automatic streaming-host startup, run
`systemctl --user disable --now app-dev.lizardbyte.app.Sunshine.service`.
If removing Sunshine later, its live configuration and the added repository
are separate state; preserve credentials and pairing data unless deletion
is intended. Avahi is shared system infrastructure, so check other uses
before disabling it.

## DualSense wireless features over Bluetooth via vDS (updated 2026-11-17)

**Current state (2026-11-17):** **Active (`vds 0.4.0_rc1.dirty-4` installed, awaiting DualSense reconnect after `vdsd` restart)** (`vds_hcd` DKMS module built/signed for `7.2.14-arch1-1`):
- `vdsd.service` is `enabled` and `active`; `vds_hcd` is loaded (`/dev/vds0`–`/dev/vds3` connected).
- `/etc/systemd/system/bluetooth.service.d/override.conf` is in place (`ExecStart=/usr/lib/bluetooth/bluetoothd --noplugin=input`), and `bluetooth.service` is running with `--noplugin=input`.
- WirePlumber config remains in place at `~/.config/wireplumber/wireplumber.conf.d/99-vds-dualsense-wireplumber.conf`: `HyperX Cloud III S Wireless Analog Stereo` / `Mono` remain default sink/source (`*`), and prior to the `dirty-4` upgrade restart `Wireless Controller` (`Direct: Direct: sink`) was verified at `[vol: 1.00]` with 4 channels (`FL, FR, RL, RR`, `channelmix.upmix=false`, `channelmix.mix-lfe=false`).
- Controller `a0:fa:9c:62:2d:fa` disconnected during `systemctl restart vdsd.service` and awaits a **PS button** wake/reconnect to verify the `dirty-4` fixes in live gameplay.

**GE-Proton for Death Stranding Director's Cut (`AppID 1850570`):**
- Valve `Proton - Experimental` (`11.0`) lacks the `proton-ds5-haptic` audio/speaker patch stack (`winepulse.so`/`mmdevapi.dll`), so audio haptics do not work there (confirmed upstream in `ge-proton#778`).
- Installed `GE-Proton11-12-x86_64` (verified via `GE-Proton11-12-x86_64.sha512sum`) to `~/.local/share/Steam/compatibilitytools.d/GE-Proton11-12-x86_64`. For AppID `1850570`, `GE-Proton11-12` automatically sets `PROTON_DEATH_STRANDING_CONTROLLER_EFFECTS=1` and `PROTON_DEATH_STRANDING_FORCE_ENVIRONMENT_EFFECTS=1` and handles PipeWire UCM `Direct` / `HiFi` split sinks cleanly. Set **Force compatibility tool -> `GE-Proton11-12-x86_64`** and **Controller -> `Disable Steam Input`** after restarting Steam.

**Symptom (initial Bluetooth setup):** In games like *Sifu* (using PlayStation PC SDK / `libScePad.dll`), native DualSense features (adaptive triggers, HD haptics, and PlayStation button glyphs) only work over USB; over standard Bluetooth, the SDK discards them.

**Cause:** `libScePad.dll` enforces USB HID report sizes (`InputReportByteLength == 64`, `OutputReportByteLength == 48`, Feature Report `0x20`), whereas standard Bluetooth uses 78-byte reports and lacks USB audio endpoints (`snd-usb-audio`).

**vDS setup (when active):** `vDS` (`hurryman2212/vds`, built at `~/.local/src/vds`) uses `vds_hcd.ko` to present DualSense `a0:fa:9c:62:2d:fa` (`054c:0ce6`) as a virtual USB controller with a 4-channel (`FL, FR, RL, RR`) audio sink under PipeWire (`99-vds-dualsense-wireplumber.conf`), while keeping desktop audio on `HyperX Cloud III S Wireless`.

**Rumble & Steam Input findings (2026-11-12):**
- **Missing vibration with `libScePad` (`flags0=0x01`):** Across 155 captured Sifu HID output reports in `/var/log/vdsd.log`, Sifu sent `flags0=0x01 flags1=0x40 light_flags=0x00` with `rumble_l=255` (55 reports), `rumble_l=178` (23 reports), or `0` (77 reports) and **`rumble_r=0` on every report** (`0` non-zero `rumble_r` reports). DualSense firmware `0x0110002a` ignored `flags0=0x01` (both over vDS Bluetooth and on wired USB `/dev/hidraw13`) unless bit 1 (`use_rumble_not_haptics`, `flags0=0x03`) or `COMPATIBLE_VIBRATION2` (`flags0=0x02 light_flags=0x04`, used by Linux `hid-playstation` `EV_FF`) was set.
- **Local vDS patch:** Initially patched `src/vds_protocol.cc` (`vds 0.4.0_rc1.dirty-2`) to force bit 1 whenever compatible rumble had a nonzero motor value (`dist/ArchLinux/vds-0.4.0_rc1.dirty-2-x86_64.pkg.tar.zst` vs. upstream `vds-0.4.0_rc1-1-x86_64.pkg.tar.zst`). See below for the `0.4.0_rc1.dirty-3` audio-haptics gate.
- **Death Stranding faint haptics & legacy-rumble regression (2026-11-13..2026-11-14):**
  - *Symptom:* *DEATH STRANDING DIRECTOR'S CUT* (`1850570`) audio haptics over Bluetooth initially felt faint, and after manually raising the sink volume to `1.00`, gameplay still reverted to deep/left-heavy, shallow/right DS4-style rumble.
  - *Cause:* (1) WirePlumber defaulted the virtual DualSense sink to `0.40` (`0.064` linear gain / `-24 dB`). (2) A 6-second live capture (`vdsctl trace on --scope output` + `pw-record`) showed game stream `188` and the `1.00` sink delivering balanced `RL`/`RR` haptics (`rms` `10386.51` / `10540.45`, peak `32768`, `0` BT `0x36` drops), while `ds.exe` simultaneously sent `353/357` HID `0x02` reports with `flags0=0x01` (`enable_rumble_emulation=1`, `use_rumble_not_haptics=0`) and equal `rumble_r == rumble_l > 0` (`335` reports up to `178`). `dirty-2` forced `use_rumble_not_haptics=1` in both `0x31` and `0x36` packets whenever `rumble_l/r != 0`, overriding HD `0x36` audio haptics with asymmetric DS4 rumble emulation.
  - *Solution:* Added `"device.routes.default-sink-volume": 1.0`, `"channelmix.upmix": false`, and `"channelmix.mix-lfe": false` to `~/.config/wireplumber/wireplumber.conf.d/99-vds-dualsense-wireplumber.conf`, and updated `src/vds_protocol.hh`, `src/vds_protocol.cc`, and `src/platform/linux/vdsd.cc` (`~/.local/src/vds-bt-rumble-fix.patch`, packaged as `vds 0.4.0_rc1.dirty-3`) to suppress the forced `use_rumble_not_haptics` bit while non-zero `ch2`/`ch3` audio haptics are active (`kAudioHapticsActiveHold = 30 s`, cleared on `AUDIO_OUT` interface off, port reset/disconnect, and clearing latched rumble on expiry).
  - *Verification:* Installed `vds 0.4.0_rc1.dirty-3` via `pkexec pacman -U`, rebuilt/signed `vds_hcd` DKMS for `7.2.14-arch1-1`, restarted `vdsd` (`active`) and `wireplumber`, and passed compiled C++ state-machine and `PcmAudioExtractor` unit tests (`test_vds_protocol`); live in-game feel and `80 Hz` symmetry check at `1.00` await Bluetooth reconnect.
- **Wired DualSense baseline & `vds` DSP comparison (2026-11-14):**
  - *Observed wired pipeline (`ds.exe` + `GE-Proton11-12` + USB DualSense `054c:0ce6`, `bcdDevice=0100`, `289`-byte HID report descriptor):* `mmdevapi.dll` (`force_death_stranding_environment_effects`) enables environmental controller effects while `ds.exe` opens two 4-ch `S16LE 48000 Hz` streams into PipeWire sink `182` (`period_size=128`, `buffer_size=32768`, `QUANT=256`, `0` XRUNs across 20s): stream `169` (`480/48000`, `ch1` independent controller speaker at `rms=451.0`, `ch0` zeroed by `winepulse.so` `pulse_haptic_write`, `ch2`/`ch3` subtle `250–500 Hz` surface textures at `rms=238.8`/`141.1`) and stream `140` (`256/48000`, `0–120 Hz` heavy actuators up to `±32768`). First non-zero `ch1` triggers 63-byte `report.68` (`02 a0 80 00 00 00 64 00 30 ... [38]=0x02`) over `/dev/hidraw`. Across `960,768` frames, PipeWire sink `182` matched `clamp(169 + 140, -32768, 32767)` bit-for-bit after startup alignment; passive `/dev/hidraw13` IN capture ran at `250.5 Hz` (`64` B, `p50=4.00 ms`, `max=4.99 ms`).
  - *Verified `vds` gaps (benchmarked in C++ against `vds_protocol.cc` + the 20s wired WAVs; `std::lround` applied in `dirty-4` below, noise shaping and Opus speaker changes unapplied since speaker output is muted in `dirty-4`):*
    1. `s16_to_s8_haptic` (`sample / 256` integer truncation toward zero) zeroes `100.0%` (`31,579/31,579`) of `1 <= |avg| < 256` subtle blocks and `77.4%` (`41,856/54,063`) of active 16-sample blocks on `169` (`51.8%` = `40,765/78,697` on mixed `sink`). `std::lround` raises `0–500 Hz` SNR by `+8.08 dB` on `169` (`10.31 -> 18.39 dB`) and `+6.20 dB` on `sink` (`36.91 -> 43.11 dB`), recovering `12,971` subtle `sink` blocks with zero idle buzz; 1st-order noise shaping reaches `21.35` / `49.12 dB` (`0–500 Hz`) but needs live controller listening for `500–1500 Hz` coil hum.
    2. `SpeakerEncoder` uses `OPUS_APPLICATION_AUDIO` (`312`-sample / `6.50 ms` lookahead, `20.40 dB` SNR) despite emitting CELT-only `TOC=0xf4` (`10 ms` stereo, avg `199.8/200` B); `OPUS_APPLICATION_RESTRICTED_LOWDELAY` reduces lookahead to `120` samples (`-4.00 ms`), and mirroring `ch0=ch1` avoids stereo-side bit waste from `winepulse` zeroing `ch0` (`+3.87 dB` SNR in offline test), both pending live BT hardware verification.
    3. `DsOutputState::apply_usb_output_report` preserves speaker volume (`0x64`) and path (`0x39`) across 63-byte `report.68` + 48-byte `0x02` rumble/trigger sequences in either order; `vds_usb_core.c` mic volume range is `-100..0 dB` vs wired `card 3`'s `0..+48 dB`.
- **One-sided (left-heavy) feel under XInput / Steam Input:** Isolated raw `/dev/hidraw` tests (`flags0=0x03`) showed `rumble_l=255, rumble_r=0` shakes the shell heavily with low frequency while `rumble_l=0, rumble_r=255` gives a subtle, fast high-frequency buzz. Running Sifu (`AppID 2138710`) wired with Steam Input **ON** (`controller_ps5_gamepad_fps.vdf`, `uses xinput : true` in `~/.local/share/Steam/logs/controller.txt`) still felt left-heavy/one-sided: Steam uses SDL3 (`SDL-release-3.4.0-1576-gab5541ec5` in `~/.local/share/Steam/ubuntu12_32/libSDL3.so.0`), whose upstream `SDL_hidapi_ps5.c` maps `low_frequency_rumble >> 8` straight to `ucRumbleLeft` and `high_frequency_rumble >> 8` straight to `ucRumbleRight` (setting `ucEnableBits3 |= 0x04` and `ucEnableBits1 |= 0x02`) without blending left and right in SDL. By contrast, *Marvel's Spider-Man: Miles Morales* (`AppID 1817190`) ran with Steam Input **OFF** (`empty.vdf`, `uses xinput : false`), allowing native DualSense haptics instead of asymmetric XInput low/high rumble emulation.
- **Native Bluetooth without `vdsd` (`hid-playstation`, *DEATH STRANDING DIRECTOR'S CUT* `1850570`, Steam Input OFF, 2026-11-16):**
  - *Symptom:* With `vdsd` stopped and `bluetoothd` running without `--noplugin=input`, the DualSense (`HID_ID=0005:0000054C:00000CE6`, `/dev/hidraw13` while connected) was detected natively by `ds.exe` under `GE-Proton11-12-x86_64`, but produced **zero vibration**.
  - *Cause (verified statically in `winebus.sys`, `winebus.so`, and `ds.exe`, combined with earlier `0x0110002a` tests; no live `hidraw13` write capture taken during the BT run):*
    1. `GE-Proton11-12` `winebus.sys` (`is_hidraw_enabled`) exposes `/dev/hidraw13` directly, but checks `bus_type == 2` (Bluetooth) and explicitly skips DualSense patches: `hidraw_disable_report_fixups` (`0x180007f30`) clears BT fixups, `bus_main_thread` (`0x180002a92`) skips `0x0302` USB haptics and `0xa002` speaker selection, and `hid_internal_dispatch` (`0x180006b81`, `0x180006cb8`) skips both BT `0x31 -> 0x02` (`flags0 |= 0x03` at `0x180006c33`) conversion and the Death Stranding `0x02` patch (`0x180006cf6`). Meanwhile `winebus.so` (`hidraw_device_set_output_report` at `0x88b0` -> `0x89d8`) writes non-zero report IDs (`0x31`) directly to `hidraw`, and native `hid-playstation` BT provides no DualSense audio-haptics sink.
    2. In `ds.exe`, `0x143905f40` (called at `0x1419b7bd2`) only enables the audio-haptics endpoint (`0x1439055c0`) when `0x60(%rcx) == 0` (wired USB). Standard `scePadSetVibration` (`0x1419b91d0` -> `0x143905e70` -> `0x1439060f0` -> `0x14390a860` -> `0x14390a490`) initializes reports with `flags0=0x01` (`enable_rumble_emulation=1`, `use_rumble_not_haptics=0` at `0x1439061f1`) and wraps them into 78-byte BT `0x31` reports (CRC-32 seed `0xa2`) without ever setting bit 1 (`flags0=0x03` in `0x14390a8b7` requires slot `+0x6` in `{2, 3}` or `0x147e77d93 != 0`; `ds.exe` `libScePad` only writes `1` to slot `+0x6` at `0x14390864f`/`0x1439089f6`, and `.text` has zero writes to `0x147e77d93`). DualSense firmware `0x0110002a` ignores `flags0=0x01` without bit 1 (`flags0=0x03`), `COMPATIBLE_VIBRATION2` (`flags0=0x02`), or active audio haptics.
    3. *Comparison with Windows Bluetooth (*Spider-Man*):* Windows likewise has no native BT DualSense HD audio-haptics transport; games that still vibrate weakly over Windows Bluetooth rely on legacy compatible rumble fallback (Steam Input / XInput translation, or per-game `COMPATIBLE` mode; *Spider-Man* binary itself not inspected here), whereas *Death Stranding DC* with Steam Input off leaves `flags0=0x01` over Bluetooth.
  - *Next options on resume:* (1) Test native BT (`vdsd` stopped) with **Steam Input ON** in `1850570` (`EV_FF` / `COMPATIBLE_VIBRATION2` weak standard rumble sanity check), or (2) re-enable `vdsd` (`vds 0.4.0_rc1.dirty-3`) and test live BT audio-haptics + `80 Hz` symmetry at WirePlumber `1.00`.
- **R1 Odradek left-bias, unwanted controller speaker footsteps, & subtle haptics truncation (`vds 0.4.0_rc1.dirty-4`, 2026-11-17):**
  - *Symptom & live wireless capture (`dirty-3`, 2026-11-16):* A 14-second live wireless capture of *DEATH STRANDING DIRECTOR'S CUT* (`1850570`, `GE-Proton11-12`) matched wired routing (`sink 123` `[vol: 1.00]`, stream `145` `480/48000` `ch1 rms=276–308` speaker + `ch2/3 rms=4.6–32.2` environmental textures, stream `176` `256/48000` `ch2/3 rms=3022–6309` actuators, `0` XRUNs; `/dev/hidraw13` IN at `233.9 Hz`, `p50=4.07 ms`). However: (1) pressing R1 (Odradek scanner) still felt biased to the left despite symmetric `80 Hz` `RL`/`RR` PCM waves (`L/R=0.99`), (2) footsteps played audibly from the DualSense speaker, and (3) `14–20%` of mixed 16-sample blocks (`100%` of quiet `|avg| < 256` environmental texture blocks on `145`) were zeroed by integer truncation (`avg / 256`).
  - *Causes:*
    1. While pressing R1, `ds.exe` simultaneously emits symmetric `80 Hz` PCM haptics and a 60 Hz USB HID `0x02` ramp (`02 01 40 01 01` -> `02 01 40 b2 b2`, `enable_rumble_emulation=1`, `use_rumble_not_haptics=0`) starting `31 ms` before PCM arrives. `dirty-3` only cleared bit 1 (`use_rumble_not_haptics`), leaving bit 0 (`enable_rumble_emulation=1`) and non-zero `rumble_r`/`rumble_l` in `state_`, which caused DualSense firmware `0x0110002a` to mix left-heavy legacy rumble emulation on top of `0x36` audio haptics and sent ~60 redundant `0x31` state packets/sec over L2CAP (plus a `30 s` hold expiry could expose pre-audio `0x02` packets to bit 1 forcing after idle pauses).
    2. `GE-Proton11-12` (`proton` line 2056) sets `PROTON_DEATH_STRANDING_FORCE_ENVIRONMENT_EFFECTS=1`, routing footsteps/environmental sound to `ch1` (`FR`) of `stream 145` alongside `ch2/ch3` environmental haptics, and `vDS` defaulted `speaker_volume` to `0x64` and `kOutputPathSpeaker` (`0x30`) whenever `AUDIO_OUT` was open.
    3. `resample_haptics_pcm` and `s16_to_s8_haptic` in `src/vds_protocol.cc` truncated toward zero (`sum / count` and `sample / 256`).
  - *Solution (`~/.local/src/vds-bt-rumble-fix.patch`, packaged as `vds 0.4.0_rc1.dirty-4`):*
    1. Updated `DsOutputState` (`src/vds_protocol.hh`, `src/vds_protocol.cc`) to suppress `enable_rumble_emulation` (`bit 0`), `use_rumble_not_haptics` (`bit 1`), `enable_improved_rumble_emulation`, and `state_[2..3]` (`rumble_r/l`) whenever `audio_haptics_active_` is true (unless `use_rumble_not_haptics` is explicitly requested, while preserving the `dirty-2` `bit 1` fallback for non-audio-haptics titles like *Sifu*), and increased `kAudioHapticsActiveHold` in `src/platform/linux/vdsd.cc` from `30 s` to `24 h` (cleared on `AUDIO_OUT` `alt=0` or disconnect).
    2. Muted internal DualSense speaker output in `DsOutputState` (`kInitialSetStateData[5] = 0x00`, `speaker_volume_ = 0`, `kOutputPathHeadphones`) and zeroed `speaker_pcm_` in `PcmAudioExtractor::push_usb_audio` while preserving `ch2/ch3` environmental + actuator haptics (`has_haptics_signal`).
    3. Switched `resample_haptics_pcm` and `s16_to_s8_haptic` to `std::lround` (`<cmath>`).
  - *Verification:* Compiled and passed all updated C++ unit assertions (`test_vds_protocol`: *Sifu* bit-1 fallback, *Death Stranding* `01..b2` ramp zero-mutation & bit-0/1 suppression, speaker mute across `report.68`/`audio_out`, `std::lround` `±180 -> ±1` rounding, and speaker-only silence gating), built `dist/ArchLinux/vds-0.4.0_rc1.dirty-4-x86_64.pkg.tar.zst`, installed via `pkexec pacman -U` (rebuilt/signed `vds_hcd` DKMS for `7.2.14-arch1-1`), and restarted `vdsd.service` (`active`); live in-game feel awaits controller reconnect.

**Audio recovery & rollback:**
- After disabling `vDS`, PipeWire audio broke until `systemctl --user restart pipewire pipewire-pulse wireplumber`; `wpctl status` confirmed `HyperX Cloud III S Wireless Analog Stereo` active as default sink (`*`) and `pw-play` succeeded.
- To fully uninstall `vDS` later: `pkexec pacman -R vds`, `rm -f ~/.config/wireplumber/wireplumber.conf.d/99-vds-dualsense-wireplumber.conf*`, and `systemctl --user restart pipewire pipewire-pulse wireplumber`. To keep `vDS` off across reboots without uninstalling, run `pkexec systemctl disable --now vdsd`. To finish re-enabling `vDS` (when `vds_hcd` and `99-vds-dualsense-wireplumber.conf` are already present), run `pkexec /usr/share/vds/override-bluetoothd.sh disable-input --restart` and `pkexec systemctl enable --now vdsd` (add `pkexec modprobe vds_hcd` if `vds_hcd` is unloaded).

## Deadlock Mod Manager library discovery and FOV override (2026-11-12)

**Symptom:** Flatpak Deadlock Mod Manager (`dev.stormix.deadlock-mod-manager`) failed to locate the game (`Game not found in any Steam library`), preventing mod management. After initial setup, the in-game FOV reset to default narrow FOV.

**Cause:**
1. Deadlock is installed in a separate Steam library mounted at `/mnt/games/SteamLibrary`. Flatpak's default sandbox profile did not grant access to `/mnt/games`.
2. When the mod manager installed mod search paths into `game/citadel/gameinfo.gi`, it replaced the file and created `gameinfo.gi.bak`, which stripped the custom `"r_aspectratio" "2.2"` convar under `ConVars`.

**Solution:**
1. Granted filesystem access to the games mount via user override:
   ```sh
   flatpak override --user --filesystem=/mnt/games dev.stormix.deadlock-mod-manager
   ```
2. Re-added `"r_aspectratio" "2.2"` under `ConVars` in `/mnt/games/SteamLibrary/steamapps/common/Deadlock/game/citadel/gameinfo.gi`.

**Verification:**
- Verified Flatpak sandbox read access to `/mnt/games/SteamLibrary/steamapps/common/Deadlock/game`.
- Confirmed `gameinfo.gi` retains mod manager search path markers (`citadel/addons`) and the restored `r_aspectratio 2.2` convar.

## DEATH STRANDING DIRECTOR'S CUT DX12 `DeviceRemoved` / Access Violation (2026-11-14)

**Status:** Unresolved (observed once during wired gameplay; unrelated to DualSense / `vds` / PipeWire).

**Symptom:** Game crashed with an `ERROR` dialog (`Build : dsq 179/4027081`) and `error.txt` in `/mnt/games/SteamLibrary/steamapps/common/DEATH STRANDING DIRECTORS CUT/error.txt`:
- `Access Violation (C0000005h)` in thread `'Main'` at `00006FFFF6F07D85h` (`RDX = 0`)
- `Dx12-ErrorCode : 0x8007000e` (`E_OUTOFMEMORY`)
- `DeviceRemovedReason: 0x887a0005` (`DXGI_ERROR_DEVICE_REMOVED`)
- `VMEM: Used 26359.90 MB / Budget 16304.00 MB` (`Video 16304.00 MB / Shared 15924.98 MB`)
- `MEM: Used 29022.88 MB / Total 31849.95 MB`

**Cause:**
- Kernel log (`journalctl -b`) at `14:35:20` on Linux `7.2.14-arch1-1`, Mesa/RADV `1:26.2.6-1`, `GE-Proton11-12` (AMD Radeon RX 9060 XT) recorded a GPU ring hang on `ds.exe` (`pid 1544127`, thread `vkd3d_queue` `pid 1544220`):
  - `amdgpu 0000:03:00.0: ring gfx_0.0.0 timeout, signaled seq=151642590, emitted seq=151642593`
  - `Starting gfx_0.0.0 ring reset` -> `Ring gfx_0.0.0 reset succeeded` -> `[drm] device wedged, but no recovery needed` -> `radv/amdgpu: The CS has been cancelled because the context is lost. This context is guilty of a hard recovery.`
- Combined with `VMEM` committed well over the `16304 MB` VRAM budget (`26359.90 MB` spilling into GTT/shared RAM) and `29022.88 MB` of `31849.95 MB` host RAM used (`/dev/zram0` swap at `7.8 GiB / 15.6 GiB` afterward), D3D12/`vkd3d-proton` returned `E_OUTOFMEMORY` + `DXGI_ERROR_DEVICE_REMOVED` and `ds.exe` dereferenced `NULL` (`RDX=0`).
- Ruled out controller / audio stack involvement: `journalctl -b --since 14:26:00 --until 14:39:00` had zero USB, `hidraw13`, Bluetooth, or `vdsd` disconnects or errors. Active `settings.cfg` at the time had `1920x1080`, `streaming_memory_mb="3072"`, and `intel_xess="1"` (`intel_xess_mode="0"`).

**Unverified candidate workarounds (if it recurs):**
- Test disabling Intel XeSS (`intel_xess="0"`, native or `amd_fsr2`) and/or trimming background host RAM usage (`MEM` headroom) or `streaming_memory_mb`.
- If reproducible, capture `PROTON_LOG=1 VKD3D_DEBUG=warn` and check whether Mesa/RADV or kernel `amdgpu` updates address `gfx_0.0.0` ring timeouts on RDNA 4 (`0x03:00.0`).

References: [Arch Steam setup](https://wiki.archlinux.org/title/Steam),
[Arch AMDGPU setup](https://wiki.archlinux.org/title/AMDGPU),
[Valve Proton](https://github.com/ValveSoftware/Proton),
[vDS GitHub Repository](https://github.com/hurryman2212/vds).
