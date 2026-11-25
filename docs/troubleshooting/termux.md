# Termux bootstrap permission error

Observed on OnePlus 8 Pro (Oplus / OxygenOS/ColorOS, `aarch64 Android`, kernel `4.19.157-perf+`) with F-Droid `Termux` `0.118.3` on 2026-11-25.

## Symptom

On first launch after installing `Termux` (`0.118.3`) from F-Droid, bootstrap extraction failed with `Unable to install bootstrap` (`TermuxInstaller` crash report):

- `Termux Bootstrap Second Stage Command`: `Failed` (`Error Code: 2`)
- `java.io.IOException: Cannot run program "/data/data/com.termux/files/usr/etc/termux/bootstrap/termux-bootstrap-second-stage.sh" (in directory "/data/data/com.termux/files/home"): error=13, Permission denied`

Crash-report diagnostics ruled out a `noexec` partition or extraction failure:

- `/data` and `/data/user/0` were mounted `f2fs` with `rw,nosuid,nodev,noatime` (no `noexec`).
- Extracted binaries such as `/data/data/com.termux/files/usr/bin/login` had mode `-rwx------`, owner `u0_a360`, and SELinux context `u:object_r:app_data_file:s0:c104,c257,c512,c768`.

## Cause

Right after a fresh F-Droid install of `targetSdkVersion 28` Termux on Oplus firmware, Android/Oplus package-install and SELinux execution state blocked `forkAndExec` on the newly extracted script inside `app_data_file`.

## Solution

Perform a full cold reboot of the phone (power off/restart) after clearing app data if needed, then reopen `Termux` without switching apps during bootstrap extraction.

## Verification

After rebooting the phone, `Termux` completed bootstrap initialization cleanly; `pkg update && pkg upgrade -y`, `pkg install openssh termux-api -y`, `termux-setup-storage`, `passwd`, `termux-wake-lock`, and `sshd` all completed without permission errors.

## Related rules

- Install `Termux` and companion add-ons (`Termux:API`, `Termux:Boot`) from the same source (`f-droid.org`) so signing keys match.
- Note that `pkg upgrade -y` still stops at `dpkg` conffile prompts (such as `/data/data/com.termux/files/usr/etc/tls/openssl.cnf`) unless `-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"` is passed.
