# Android phone SSH & Termux setup

Verified on macOS (`stanislavs-macbook-air`, `100.94.89.60`) connecting to OnePlus 8 Pro (`oneplus-8-pro`) on 2026-11-25.

## Network and SSH connection

- **Device:** OnePlus 8 Pro (`oneplus-8-pro`, `aarch64 Android`, kernel `4.19.157-perf+`)
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
  - `Termux:GUI` (`com.termux.gui`) — also installed (not used by SSH/ADB workflow)
  - Keep Termux and add-ons on F-Droid; do not mix F-Droid, GitHub Releases, and Google Play APKs.
- **Tailscale** installed, signed into the same tailnet (`stasbebra2006@`), VPN enabled.
- **Battery optimization:** `Termux`, `Termux:API`, and `Tailscale` all set to **Unrestricted**.
- **Termux packages & setup completed:**
  - `pkg update && pkg upgrade -y`
  - `pkg install openssh termux-api android-tools -y` (`adb` `37.0.0p1-android-tools`)
  - `termux-setup-storage`, `passwd`, `termux-wake-lock`, `sshd`
  - `~/.bashrc` auto-starts `termux-wake-lock` and `sshd` when `pgrep -x sshd` is not running (Termux `/etc/profile` sources `~/.bashrc` on interactive login shells).

## Current capability status

- **Level 1 (Files & Linux via SSH):** Active and verified (`ssh phone`); shared storage is available under `~/storage/shared`.
- **Level 2 (`Termux:API` OS & hardware commands):** Active and verified (`termux-notification` delivered on-screen; `termux-battery-status` returned live JSON telemetry).
- **`sshd` auto-start:** Configured in Termux `~/.bashrc` so opening Termux starts `termux-wake-lock` and `sshd` automatically; `Termux:Boot` is not installed, so after a phone reboot tap Termux once to bring `sshd` back up.
- **Level 3 (Wireless ADB / UI & app control):** Active and verified (`android-tools` paired locally via `adb pair 100.81.30.113:39611`, `guid=adb-54a5bca2-b4P6q3`, connected via `adb connect 100.81.30.113:43135`; verified `adb shell dumpsys diskstats`, `adb shell du` on `/sdcard/Android/data`, and `adb shell pm trim-caches`).
  - *Reconnect note:* Android randomizes the Wireless debugging connect port after a reboot or toggling Wireless debugging off/on; no re-pairing is needed, just run `adb connect <ip>:<new-port>` from Termux/SSH.
  - *`pm trim-caches` note:* `adb shell pm trim-caches 999G` reclaimed ~3.8 GiB immediately on this device (`3.5 GiB -> 7.3 GiB` free), but the CLI command hung waiting on the binder completion callback instead of returning — check live `df -h /data` and cancel if it does not return promptly.

## Secrets boundary

- No passwords or private keys are stored in chezmoi. Keep `~/.ssh/id_ed25519` and Termux password outside Git.
