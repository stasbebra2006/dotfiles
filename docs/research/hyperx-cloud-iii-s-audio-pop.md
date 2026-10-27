# HyperX Cloud III S Wireless: pop after silence

**Unresolved. No verified fix. Experiments have been stopped or rolled back.**

Investigation: 2026-10-26 to 2026-10-27. Checkpoint and read-only state check:
2026-10-27 17:12 CET, Europe/Prague.

## Resume boundary and conversational position

The user explicitly requested explanation and agreement before further tests:

> don't try something, rather tell me what you want to try and what remains to
> try and why it makes sense.

First explain the hypothesis, exact change, impact, duration, success criterion,
and rollback; wait for agreement. Do not interpret a result report or a question
as permission for another experiment. Change one variable at a time. Do not start
sounds, restart audio, reboot, install software, or update firmware while merely
discussing the plan.

The user was frustrated by tests beginning without enough explanation and by
confusion between silent playback and sample-rate changes. The last discussion
established that official NGENUITY is Windows-only and that checking firmware
through it would require Windows. The user then requested these saved notes.
No next experiment was selected. Resume by discussing the read-only Windows and
firmware comparison below, not by applying another Linux tweak.

## Symptom and setup

- An electrical pop/click when sound emerges after silence, resembling insertion
  of a 3.5 mm connector. The user reports that Windows has no pop or a much quieter
  one. Exact Windows settings have not been collected.
- Headset: HyperX Cloud III S Wireless through its 2.4 GHz USB dongle.
- USB ID: `03f0:06be`; kernel driver: `snd_usb_audio`; Arch Linux/KDE Wayland.
- Versions verified at checkpoint: Linux `7.2.11-arch1-1`, PipeWire and
  pipewire-pulse `1:1.6.10-1`, WirePlumber `0.5.18-1`, EasyEffects `8.3.0-1`.
- Stable playback node:
  `alsa_output.usb-HP__Inc_HyperX_Cloud_III_S_Wireless_C1V5410BW4-00.analog-stereo`.
  Resolve by name; numeric PipeWire IDs change after restarts.
- Known working playback baseline: USB alternate setting 2, `S24_3LE`, stereo,
  48 kHz. The device also advertises 16-bit and 96 kHz modes.
- EasyEffects has `FixBalance`, stereo-tools, and `balanceOut=-0.3`. Preserve
  this existing preference unless the user requests a change.

## Current state, verified 2026-10-27 17:12 CET

- WirePlumber and EasyEffects are running. EasyEffects returned through login
  autostart after the earlier session-only shutdown; it is not currently disabled.
- Playback and capture were suspended because no audio was playing. The supported
  format list alone does not establish an active hardware sample rate.
- Original automatic playback settings are restored: `audio.format=UNKNOWN`,
  `audio.rate=0`, no rate override, `dither.noise=0`, and default idle timeout.
- No `hyperx-*` test units or timers are loaded.
- Neither WirePlumber's process nor the user service manager has a
  `WIREPLUMBER_CONFIG_DIR` override.
- No test configuration was installed in
  `~/.config/wireplumber/wireplumber.conf.d/` or
  `~/.config/pipewire/pipewire.conf.d/`; those directories do not exist here.
- Receiver USB power: `control=on`, runtime status `active`, runtime-suspended
  time `0`. USB runtime suspend and audio-node idle suspend are different mechanisms.

No package/driver or headset/dongle firmware update was performed. No permanent
audio configuration change was retained. This documentation task made no audio
changes and started no playback.

## Completed tests

| Test | Actual change | Result and limitation |
| --- | --- | --- |
| Baseline inspection | Routing, hardware format, USB power, logs, and a short `pw-top` sample | No matching recent kernel USB/audio errors; zero reported HyperX errors during the short sample. This does not exclude all intermittent failures. |
| Temporary 16-bit/48 kHz | Runtime parameters and format-renegotiation attempts | Hardware eventually showed `S16_LE`, but the user reported silence. Reverted. Inconclusive as a listening comparison, not proof that 16-bit is unsupported or ineffective. |
| EasyEffects off | `easyeffects --quit`; Firefox routed directly to HyperX | User confirmed the pop remained. Preset and login autostart were retained. |
| Digital-silence keep-alive, repeated | A separate `pw-cat` stream sent zeros directly to HyperX for up to five minutes | User confirmed the pop remained during the repeat. Keeping host playback open alone was insufficient in that comparison. |
| Tiny nonzero keep-alive | A five-minute stream at +/- two 24-bit PCM LSBs, approximately -132 dBFS before mixing/device gain | Direct output links and 24-bit/48 kHz were verified. No clear explicit listening result was captured. This does not conclusively test every internal silence-gating threshold. |
| Temporary 24-bit/96 kHz | Playback-only `audio.rate=96000` and `audio.allowed-rates=[96000]`, loaded before device recreation | Actual `S24_3LE` at 96000 Hz was verified; a quiet faded tone exited successfully. User confirmed the pop remained. Fully rolled back. |

### Failed 16-bit trial and recovery

Changing `Props` alone initially left the old hardware format negotiated. The
runtime SPA format string accepted here was `S16LE`; the attempted `S16_LE` value
did not select it. A live explicit `Format` request failed with
`cannot set Format param: node already started`.

A silent verification process exited with status 1 even though the hardware
format changed. This should not have been treated as successful playback
verification. The user later reported no sound. A device opening or selecting a
format is not equivalent to an audible test.

`systemctl --user restart wireplumber.service` restored normal automatic settings,
routes, and the known 24-bit/48 kHz baseline. The user confirmed sound returned.
This is historical rollback evidence, not a command to run unprompted. Avoid
another live format switch while the device is running.

### Keep-alive terminology

- Digital silence contains zeros. It keeps the host stream open, but the headset
  can still recognize the data as silence.
- A tiny nonzero signal tests a different hypothesis: internal silence detection.
  Its amplitude matters; the test is not equivalent to every SoundKeeper workaround.
- Neither trial changed `dither.noise` or installed a persistent rule.
- Historical services: `hyperx-idle-test`, `hyperx-idle-retest`, and
  `hyperx-nonzero-test`, all bounded by `RuntimeMaxSec=300`; none remain active.

### Bounded 96 kHz trial and recovery

The runtime fragment was under
`/run/user/1000/hyperx-96k-test-hcllflos/wireplumber.conf.d/` and matched only the
stable HyperX playback node. Capture and other devices had no test rule.
`WIREPLUMBER_CONFIG_DIR` prepended the runtime fragment while retaining all normal
configuration search locations. The manager variable was set only long enough
to restart WirePlumber and was then immediately unset.

An automatic rollback timer was scheduled for 13:20:39 CET on 2026-10-27. After
the user reported no improvement, the runtime rollback helper was run immediately
and the timer stopped. The replacement node had `audio.rate=0`,
`audio.format=UNKNOWN`, and no rate override. No test process environment remained.
The headset stayed at the user's 75% volume during this comparison.

Those runtime files and earlier artifacts under
`/tmp/hyperx-16bit-test-hj_sw3ea/` are ephemeral. Do not depend on their survival
when resuming; their relevant evidence is recorded here.

## Research findings and uncertainty

The Windows/Linux difference is a clue, not a diagnosis. Windows can load vendor
audio-processing effects, while Linux uses another processing and driver path.
Format conversion, gain/mute control, and stream transitions may differ. None
has been established as the cause on this machine. Do not state that Linux
simply puts the headset to sleep: the pop persisted during a zero-signal stream.

Similar start/stop pops are reported for this exact model, including on Windows.
An HP support case describes the symptom persisting through firmware, format,
power-setting, and replacement-headset changes. That shows the complaint is not
unique; it does not establish prevalence or a universal cause/fix.

HyperX-Rob announced firmware `x.1.2.4` in May 2026 for quiet-audio dropouts and
DTS functionality. It is a relevant lead, not a promise to fix this pop. Linux
package versions and firmware inside the headset/dongle are different things.
Neither device's actual firmware version was checked in this investigation.

Official NGENUITY and NGENUITY Legacy are Windows-only. HeadsetControl supports
some HyperX devices, but Cloud III S Wireless was absent from its supported-device
table and had an open support request when researched. Do not equate Cloud 3
support with Cloud III S Wireless support or assume a full NGENUITY replacement
or a verified Linux firmware updater for this headset.

## Proposed next steps, awaiting agreement

1. **Read-only Windows reference first.** Record the working bit depth/sample
   rate, enhancements/DTS state, and both headset and dongle firmware versions
   shown in NGENUITY. Check whether an update is offered; do not install it
   automatically. No Windows reboot or boot-entry change has been requested or
   authorized by this checkpoint.
2. **If justified, compare the same faded clip through PipeWire and direct ALSA**
   at identical format and level. Explain the brief interruption needed to release
   the device. This helps locate the triggering layer; it does not prove a hardware
   defect or a PipeWire bug by itself.
3. **Choose one adjustment from those results.** If Windows uses 16-bit, a properly
   recreated 16-bit device may still be worth discussing because the previous
   trial was inconclusive. If PipeWire-specific abrupt silence transitions are
   implicated, a short anti-click fade/zeroramp is a relevant untested candidate.
   Firmware action depends on actual versions and vendor guidance.

Not implemented: direct ALSA comparison, anti-click fade/zeroramp,
`session.suspend-timeout-seconds=0`, or persistent `dither.noise`. The zero-stream
result reduces the priority of simply disabling host idle suspend. The tiny
nonzero trial has no clear result. Do not cycle through arbitrary sample rates,
buffer sizes, or stronger signals without a stated hypothesis and agreement.
Do not apply generic HDA power-saving changes to this USB-audio headset.

## Sources checked on 2026-10-27

- [HP support case: Cloud III S popping sound](https://h30434.www3.hp.com/t5/Gaming-Accessories/HyperX-Cloud-III-S-popping-sound/td-p/9670246)
  — firsthand report and support replies; no universal fix established.
- [HyperX-Rob: x.1.2.4 firmware announcement](https://www.reddit.com/r/HyperX/comments/1td6tj6/cloud_iii_s_wireless_new_x124_firmware_available/)
  — quiet-audio dropout and DTS fixes; no confirmation for this pop.
- [HyperX NGENUITY](https://hyperx.com/pages/ngenuity)
  — official software availability and compatibility.
- [HeadsetControl supported devices](https://github.com/Sapd/HeadsetControl#supported-devices)
  and [Cloud III S support request #486](https://github.com/Sapd/HeadsetControl/issues/486)
  — community support limitations; recheck future versions.
- [Microsoft audio-processing object architecture](https://learn.microsoft.com/en-us/windows-hardware/drivers/audio/audio-processing-object-architecture)
  — vendor processing on Windows; not a diagnosis of this issue.
- [WirePlumber ALSA configuration](https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/alsa.html)
  — audio-node idle timeout semantics.
- [PipeWire audio properties](https://pipewire.pages.freedesktop.org/pipewire/page_man_pipewire-props_7.html)
  — dither, format, and runtime parameter semantics.
- [PipeWire zeroramp](https://pipewire.pages.freedesktop.org/pipewire/page_module_filter_chain.html)
  — untested fades for abrupt digital-silence transitions.
- [WirePlumber configuration locations](https://pipewire.pages.freedesktop.org/wireplumber/daemon/locations.html)
  — runtime overrides and fragment search paths used in the 96 kHz trial.

## Repository checkpoint

Source: `~/.local/share/chezmoi`, branch `main`. Publication base: `d1e384e`.
After saving the checkpoint, the user explicitly requested a commit and push.
The publication scope is exactly this record, its `README.md` index, and
`../linux-audio.md` as a link to the consolidated record.

Other configuration edits and the existing untracked KDE, gaming, sleep, and Zsh
documentation are outside this commit's scope. Publishing these notes applies
no audio settings and does not authorize another experiment.
