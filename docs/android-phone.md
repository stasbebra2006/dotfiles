# Android phone SSH, Termux & ADB setup

Verified on macOS (`stanislavs-macbook-air`, `100.94.89.60`) connecting to OnePlus 8 Pro (`oneplus-8-pro`) on 2026-11-25 and updated on 2026-11-26.

## Network and SSH connection

- **Device:** OnePlus 8 Pro (`IN2023`, `oneplus-8-pro`, Android 13 / OxygenOS `13.1.0.591(EX01)`, security patch `2024-06-05`, `aarch64 Android`, kernel `4.19.157-perf+`)
- **Tailscale IPv4:** `100.81.30.113`
- **Tailscale MagicDNS:** `oneplus-8-pro.swallow-caiman.ts.net`
- **Termux user / SSH port:** `u0_a360` on port `8022`
- **macOS alias (`~/.ssh/config`, not managed by chezmoi):**
  - `Host phone` -> `HostName 100.81.30.113`, `Port 8022`, `User u0_a360`, `IdentityFile ~/.ssh/id_ed25519`
- **Key auth:** `~/.ssh/id_ed25519.pub` installed in Termux `~/.ssh/authorized_keys` via `ssh-copy-id`.
- **Verification:** `ssh -o BatchMode=yes -o ConnectTimeout=8 phone "whoami; uname -a"` succeeded non-interactively and returned `u0_a360` and `Linux localhost 4.19.157-perf+ #1 SMP PREEMPT Sat Oct 11 17:02:28 CST 2025 aarch64 Android`.

## Phone apps and Termux packages

- **F-Droid source (`f-droid.org`, matching signing keys):**
  - `Termux` (`com.termux`, `0.118.3`)
  - `Termux:API` (`com.termux.api`) — installed and verified (`termux-notification` and `termux-battery-status` succeeded)
  - Keep Termux and add-ons on F-Droid; do not mix F-Droid, GitHub Releases, and Google Play APKs. (`Termux:GUI` was removed.)
- **GitHub Releases (rootless IMS unlock):**
  - `Shizuku` (`v13.6.0`, `moe.shizuku.privileged.api`)
  - `Pixel IMS` (`1.4.0`, `dev.bluehouse.enablevolte`)
- **Tailscale** installed, signed into the same tailnet (`stasbebra2006@`), VPN enabled.
- **Battery optimization:** `Termux`, `Termux:API`, and `Tailscale` all set to **Unrestricted**.
- **Developer options:** **Disable permission monitoring** is enabled (required on OxygenOS for `adb shell pm grant` and Shizuku).
- **Termux packages & setup completed:**
  - `pkg update && pkg upgrade -y`
  - `pkg install openssh termux-api android-tools -y` (`adb` `37.0.0p1-android-tools`)
  - `termux-setup-storage`, `passwd`, `termux-wake-lock`, `sshd`
  - `~/.bashrc` auto-starts `termux-wake-lock` and `sshd` when `pgrep -x sshd` is not running (Termux `/etc/profile` sources `~/.bashrc` on interactive login shells).

## Current capability status

- **Level 1 (Files & Linux via SSH):** Active and verified (`ssh phone`); shared storage is available under `~/storage/shared`.
- **Level 2 (`Termux:API` OS & hardware commands):** Active and verified (`termux-notification` delivered on-screen; `termux-battery-status` returned live JSON telemetry).
- **`sshd` auto-start:** Configured in Termux `~/.bashrc` so opening Termux starts `termux-wake-lock` and `sshd` automatically; `Termux:Boot` is not installed, so after a phone reboot tap Termux once to bring `sshd` back up.
- **Level 3 (Wireless ADB / UI & app control):** Active and verified (`android-tools` paired locally, `guid=adb-54a5bca2-b4P6q3`).
  - *Port discovery & reconnect:* Android randomizes the Wireless debugging connect port after a reboot or toggling Wireless debugging off/on; no re-pairing is needed. Termux `adb` (`37.0.0p1-android-tools`) reports `adb: mdns is not supported`, but when macOS and the phone share Wi-Fi you can discover the port automatically from macOS with `dns-sd -L adb-54a5bca2-b4P6q3 _adb-tls-connect._tcp local.` (resolves `Android.local.:<port>`) and then run `ssh phone "adb connect 100.81.30.113:<port>"`.
  - *Security choice:* `adb tcpip 5555` is intentionally avoided so unauthenticated TCP ADB is not exposed on shared or university Wi-Fi.

## O2.CZ VoLTE and VoWiFi (Shizuku + Pixel IMS)

OnePlus firmware disables VoLTE/VoWiFi (`carrier_volte_available_bool=false`) for `O2.CZ` on `IN2023` even though the O2 LTE tower advertises VoPS support (`mVopsSupport=2`).

- **Start Shizuku server over ADB:**
  - `pm_path=$(pm path moe.shizuku.privileged.api) && apk_path=${pm_path#package:} && $(dirname "$apk_path")/lib/*/libshizuku.so`
- **Grant Shizuku permission to Pixel IMS:**
  - `pm grant dev.bluehouse.enablevolte moe.shizuku.manager.permission.API_V23` (requires **Disable permission monitoring** enabled in Developer options)
- **Applied config (2026-11-26):** Enabled **Enable VoLTE**, **Enable VoWiFi**, and **Persist settings across reboots** for **SIM 1 (`O2.CZ`, `Phone Id = 0`)**. SIM 2 (`Vodafone UA` roaming on `Vodafone CZ`, `Phone Id = 1`, `mVopsSupport=3`, DSDS) was left disabled.
- **Verification:** `dumpsys carrier_config` confirmed `carrier_volte_available_bool = true` and `carrier_wfc_ims_available_bool = true` on `Phone Id = 0`; Pixel IMS UI confirmed `IMS Status for SIM1 (SIM 1): Registered` (in-call 4G retention during a live voice call is still pending a live call check).

## Applied system settings & device baseline (2026-11-26)

- **Applied global settings:** `private_dns_mode=opportunistic` (`private_dns_specifier` cleared), `wifi_scan_always_enabled=0`, `ble_scan_always_enabled=0`, and `0.5` for `window_animation_scale`, `transition_animation_scale`, and `animator_duration_scale`.
- **Storage & apps:** `34 GiB` free (`67%` used) and `76` third-party apps after cache trim, Telegram cache clear, and removing 98 unused apps.
- **Battery health snapshot:** ~69% (`3,109 mAh` at `100% status=full` vs `4,510 mAh` design capacity).

## Troubleshooting and verified fixes

- **Tailscale + Android strict Private DNS breaks internet:** Setting `private_dns_mode=hostname` (e.g. `dns.adguard-dns.com`) causes `PrivateDnsBroken` on Tailscale `tun1` (`100.100.100.100`) and breaks DNS resolution. Fix: keep `private_dns_mode=opportunistic` and delete `private_dns_specifier`; configure custom DNS (such as AdGuard) in Tailscale Admin Console instead. Verified `NO_PRIVATE_DNS_ERROR` and `curl -sI https://example.com` -> `HTTP/2 200`.
- **`adb install -r` hangs on large APKs while dozing:** Streamed `adb install -r` stalled on 32 MB `pixelims.apk` over local Wireless ADB. Fix: push first and install locally (`adb push <apk> /data/local/tmp/app.apk && adb shell pm install -r /data/local/tmp/app.apk`). Verified `Success` at `169.5 MB/s`.
- **`adb shell pm grant` fails with `SecurityException` (`GRANT_RUNTIME_PERMISSIONS`):** OxygenOS blocks shell UID 2000 from granting runtime permissions until **Disable permission monitoring** is turned on in Developer options. Verified `granted=true` afterward.
- **`adb shell pm trim-caches 999G` hangs after freeing space:** Reclaimed ~3.8 GiB immediately (`3.5 GiB -> 7.3 GiB` free), then hung waiting on the binder completion callback. Check live `df -h /data` and cancel if it does not return promptly.
- **Storage symlink & toybox `sort` quirks:** `/sdcard` and `~/storage/shared` are symlinks (`du`/`find` return `0`/empty without a trailing slash; use `/storage/emulated/0/`), and Android toybox `sort` rejects `-h` (use `du -k | sort -nr`).

## Secrets boundary

- No passwords or private keys are stored in chezmoi. Keep `~/.ssh/id_ed25519` and Termux password outside Git.
