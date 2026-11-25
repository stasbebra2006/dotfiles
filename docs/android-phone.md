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
  - `Termux:API` (`com.termux.api`)
  - Keep Termux and add-ons on F-Droid; do not mix F-Droid, GitHub Releases, and Google Play APKs.
- **Tailscale** installed, signed into the same tailnet (`stasbebra2006@`), VPN enabled.
- **Battery optimization:** `Termux`, `Termux:API`, and `Tailscale` all set to **Unrestricted**.
- **Termux setup completed:**
  - `pkg update && pkg upgrade -y`
  - `pkg install openssh termux-api -y`
  - `termux-setup-storage`
  - `passwd` (for initial key copy)
  - `termux-wake-lock` and `sshd`

## Current capability status

- **Level 1 (Files & Linux via SSH):** Active and verified (`ssh phone`); shared storage is available under `~/storage/shared`.
- **Level 2 (`Termux:API` OS & hardware commands):** Both the Android app and `termux-api` Termux package are installed, not yet tested interactively; first-use Android permission prompts may appear on the phone screen.
- **`sshd` auto-start:** Not yet persisted (`pgrep -x sshd >/dev/null || sshd` is not yet in Termux `~/.bashrc`, and `Termux:Boot` is not installed). After a phone reboot or closing Termux, reopen Termux and run `termux-wake-lock` and `sshd` before SSHing from the Mac.
- **Level 3 (Wireless ADB / UI & screen control):** Not yet configured (`android-tools` is not installed in Termux and local `adb pair` / `adb connect` has not been run).

## Secrets boundary

- No passwords or private keys are stored in chezmoi. Keep `~/.ssh/id_ed25519` and Termux password outside Git.
