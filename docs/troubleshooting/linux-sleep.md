# USB wake and failed suspend

## Evidence on 2026-10-25

Arch Linux, kernel `7.2.11-arch1-1`, MSI B760 GAMING PLUS WIFI;
`/sys/power/mem_sleep` reports `s2idle [deep]`.

At 13:20:45 CET, `usb usb1` returned `-16` (`EBUSY`) from
`usb_dev_suspend`, aborting deep suspend. Systemd then attempted s2idle.
The log identifies the USB root hub, not a particular external hub or peripheral.
This repeats the root-hub failure recorded on kernel `7.2.8-arch1-2`.
SPD5118 resume errors and AMDGPU reset messages also occurred after the abort;
they do not establish which USB device caused the initial failure.

The existing `/etc/udev/rules.d/90-keyboard-wakeup.rules` explicitly enabled
wake for root hub `usb1`, keyboard `320f:5123`, and receiver `046d:c548`.
The USB PCI controller `0000:00:14.0` also had wake enabled.

## Blanket USB wake policy

The requested policy disables `power/wakeup` for all USB devices, root hubs,
and PCI USB controllers. Use
[`linux-sleep/99-disable-usb-wakeup.rules`](linux-sleep/99-disable-usb-wakeup.rules)
as `/etc/udev/rules.d/99-disable-usb-wakeup.rules`, and retire the old
keyboard-wakeup rule after backing it up. The rule covers boot, new devices,
driver binding, and change events. Reload udev rules and set the same sysfs
attributes on currently attached devices to apply without rebooting.

USB keyboard and mouse input will no longer wake the computer. Use the case
power button to wake it. This changes wake permission, not normal USB input
or USB autosuspend settings. Other wake sources retain their existing policy.

This can prevent USB wake events from aborting suspend or waking the machine.
It is a mitigation, not proof that a driver returning `EBUSY` is fixed. There
is no wake setting that forces a malfunctioning device driver to suspend.

## Verification

Installed on 2026-10-25 without rebooting. `udevadm verify` passed for the source
and installed rule. The installed file matches the saved source, is owned by
root, and has mode `0644`. The old enable rule was backed up and retired.
An independent readback confirmed all nine existing USB `power/wakeup`
attributes and the one USB PCI controller attribute are `disabled`.
`/proc/acpi/wakeup` also reports XHCI disabled.

A sleep/wake cycle has not been tested. A subsequent user-initiated sleep/wake
cycle is needed to confirm deep sleep now succeeds; do not suspend an active
desktop merely to verify the policy. After the next attempt, check:

```sh
journalctl -k -b -g 'PM: suspend|failed to suspend|usb_dev_suspend|S3 suspend aborted'
```

## Undo

The pre-change rules, all ten previous wake values, and a restoration script
are saved in `/var/backups/usb-wakeup-20261025T122533Z-y_688ani`.
To restore the pre-change rules and current-device wake values:

```sh
pkexec python3 /var/backups/usb-wakeup-20261025T122533Z-y_688ani/restore.py
```

These files are repository-only documentation under the already ignored
`docs/` directory. Ordinary `chezmoi apply` does not install system rules;
installation into `/etc` requires administrator authentication.

## References

- [Kernel USB power management](https://docs.kernel.org/driver-api/usb/power-management.html):
  `power/wakeup` and the interaction between USB remote wake and system suspend.
- [udev rules](https://www.freedesktop.org/software/systemd/man/latest/udev.html):
  rule matching and sysfs assignments.
