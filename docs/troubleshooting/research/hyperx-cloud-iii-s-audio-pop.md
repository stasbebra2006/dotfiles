# HyperX Cloud III S Wireless: pop after silence

**Headset pop unresolved. PipeWire audio was restored on 2026-10-28 at the
user's request. The native PulseAudio trial did not establish a fix; the failed
zeroramp filter remains removed. The user clarified on 2026-10-28 that popping
also occurs on Windows, but is less irritating there.**

## Second research report: source check and corrections, 2026-10-29

The user supplied a second deep-research report and requested saving the
assessment. It adds useful leads, but its proposed two-stage hardware mechanism
and persistent mitigations are not established on this unit. The source check
covered the principal firmware, HID-control, keepalive, and PipeWire claims;
it did not independently verify every cited community thread or kernel claim.
No playback, installation, service restart, firmware action, or audio setting
change was performed during this review.

### Verified sources and useful leads

- [HyperX-Rob's x.1.2.4 announcement](https://www.reddit.com/r/HyperX/comments/1td6tj6/cloud_iii_s_wireless_new_x124_firmware_available/)
  is real and describes fixes for quiet-audio dropouts and DTS. This supersedes
  the first pasted assessment's claim that no relevant public firmware note was
  found. It does not claim a start/stop-pop fix or describe two internal gating
  stages. Its Microsoft Store NGENUITY Legacy 5.37.2.0 distribution instructions
  describe availability at publication, not necessarily the current updater.
  Actual headset and dongle firmware versions remain uncollected.
- [Exact-model microphone-monitoring reports](https://www.reddit.com/r/HyperX/comments/1lvvfsr/hyperx_cloud_iii_s_wireless_cuts_off_audio_power/)
  justify testing capture stopped versus running. They do not establish a
  universal full-duplex hardware wake lock or a verified fix for this unit.
- [The original white-noise workaround](https://www.reddit.com/r/HyperX/comments/1qg83d2/cloud_iii_s_wireless_pop_fix/)
  specifies a file amplitude of 0.0005 (approximately -66 dBFS peak), then sets
  VLC's Windows mixer volume to 1. Endpoint amplitude was not measured; this
  does not establish a calibrated -66 dBFS device threshold. Its microphone
  workaround is described separately for post-idle distortion/latency.
- [The HP support thread](https://h30434.www3.hp.com/t5/Gaming-Accessories/HyperX-Cloud-III-S-popping-sound/td-p/9670246)
  confirms one owner had the same symptom after replacement, including over
  Bluetooth and despite quiet background audio. The support reply supplies
  troubleshooting suggestions, not an engineering confirmation of the cause.
  Replacement is not guaranteed to help; these anecdotes do not justify a
  blanket recommendation against RMA.

### Corrections that constrain the proposed fixes

1. **HyperHeadset's noise-gate command is not implemented for Cloud III S.**
   The inspected [Cloud III S implementation](https://github.com/LennardKittner/HyperHeadset/blob/main/src/devices/cloud_iii_s_wireless.rs)
   supports IDs 03f0:06be and 03f0:02cc but does not override noise-gate methods.
   The [default methods return None](https://github.com/LennardKittner/HyperHeadset/blob/main/src/devices/mod.rs),
   making that capability unsupported. The command is implemented in the
   [Cloud II Core Wireless backend](https://github.com/LennardKittner/HyperHeadset/blob/main/src/devices/cloud_ii_core_wireless.rs).
   Generic CLI help is not evidence of exact-model support. Do not use the
   proposed `--activate-noise-gate false` as a Cloud III S diagnostic.
2. **Two symptoms do not establish two identified hardware stages.** Internal
   silence detection remains plausible, but specific amplifier rails, radio
   sleep timers, and 24-to-16-bit truncation are unconfirmed. Datasheets for
   codecs not identified inside this headset cannot establish its architecture.
3. **The bit-depth argument mixes rounding, truncation, and signed samples.**
   A -132 dBFS peak is approximately two 24-bit integer units, but arithmetic
   shifting gives `2 >> 8 = 0` and `-2 >> 8 = -1`; rounding behaves differently.
   One 16-bit LSB is approximately -90.3 dBFS, half an LSB -96.3 dBFS, and two
   LSBs -84.3 dBFS. Neither conversion behavior inside this device nor sustained
   Windows dither during silence has been measured. The prior tiny nonzero
   trial remains **inconclusive**, not a demonstrated failure.
4. **The proposed PipeWire dither rule needs output verification.**
   [PipeWire's property reference](https://docs.pipewire.org/page_man_pipewire-props_7.html)
   distinguishes `dither.noise` from ordinary dithering, which it documents as
   disabled for output formats of 24 bits or more. Do not assume that
   `dither.method = wannamaker3` with `dither.noise = 8` produces the claimed
   continuous triangular signal or prevents consecutive zeros at S24_3LE.
5. **Experimental outcomes are less conclusive than the report claims.**
   Direct `hw:` ALSA bypasses Firefox and PipeWire but retains ALSA/kernel, USB,
   and device behavior. Clean S16_LE with popping S24_3LE would establish format
   dependence, not specifically a 24-bit unpacking bug. Pops in both formats
   would not prove Windows users benefited from dither. A clean Bluetooth test
   would implicate the 2.4 GHz path without uniquely locating a fault inside
   the dongle. A failed keepalive does not rule out every silence detector.

### Resume point: proposed tests, not yet authorized or executed

Read-only endpoint inspection during this review showed playback RUNNING at
stereo S24_3LE/48 kHz, alternate setting 2, and capture STOP. The card ID was
`Wireless` (card 0 at inspection); resolve it again before a future test.
Both S16_LE and S24_3LE are advertised at 48 and 96 kHz. This state inspection
does not establish audible behavior. `aplay` was absent at the preceding check;
recheck availability when preparing the test.

Recommended order:

1. One continuously open direct-hardware ALSA playback with smoothly faded
   tones and digital-zero gaps, first at S24_3LE/48 kHz and separately at
   S16_LE/48 kHz. Verify actual endpoint format and capture STOP; record pops
   at internal tone boundaries separately from initial open/final close and
   any underruns. This comparison remains unperformed.
2. Compare microphone capture stopped versus running as a separate variable,
   using the same playback stimulus and avoiding microphone loopback into the
   headset. This is a proposed diagnostic, not a background capture fix.
3. Add a calibrated nonzero-amplitude sweep only if those results warrant it.
   Document generated peak/RMS definitions and all gain stages. A few successful
   test levels would bound a threshold, not identify an exact minimum.

Before a test, explain its hypothesis, exact change, duration, audio/microphone
interruption, success criterion, and rollback; wait for agreement. Direct ALSA
requires releasing the device and preventing socket reactivation, with the
existing service/socket/routing state recorded and restored afterward. Do not
copy the report's incomplete service list as a ready-to-run procedure. No new
HID controls, persistent dither rule, keepalive, or firmware update was approved
by the request to save these notes.

## Failed silent-stream test, 2026-10-28 22:03 CET

At the user's explicit request, started the transient user service
`hyperx-silent-keepalive.service`: `pw-cat` plays raw zero samples from
`/dev/zero`, float32 stereo at 48 kHz, directly to the stable HyperX sink.
The stream is running with both channel links active; the HyperX sink reports
RUNNING at its normal 24-bit/48 kHz format. Existing volume levels were retained.
There is no startup enablement or new permanent audio configuration.

Stop with `systemctl --user stop hyperx-silent-keepalive.service`.
This confirmed a continuous host-side silent stream, not a pop fix. The user
reported that it did not improve the popping; the transient service was then
stopped. Previous zero-stream trials also did not remove the pop. The headset
may still detect zero samples as silence, but this remains a hypothesis.

Investigation: 2026-10-26 to 2026-10-27. Checkpoint and read-only state check:
2026-10-27 17:12 CET, Europe/Prague.


## PipeWire restored, 2026-10-28 21:59 CET

The user requested returning to PipeWire. The saved rollback helper restored
the signed cached `pipewire-pulse` and `pipewire-alsa` 1:1.6.10-1 packages and
`easyeffects` 8.3.0-1, matching the installed PipeWire core. Native PulseAudio,
PulseAudio-ALSA/Bluetooth, and its optional LADSPA EQ were removed. EQ settings
and EasyEffects presets were preserved; EasyEffects autostart was restored,
but it was not launched or new processing enabled during this rollback.

Removed only the backed-up migration-created
`90-pulseaudio.conf` live override and its untracked, hostname-scoped chezmoi
template. This was local retirement of an unpublished migration override;
other WirePlumber files and unrelated source edits were preserved. No global
chezmoi apply, Git commit/push, or system upgrade occurred.

PipeWire, PipeWire-Pulse, and WirePlumber are active; both PipeWire sockets and
WirePlumber are enabled for future sessions. `pactl info` reports
`PulseAudio (on PipeWire 1.6.10)`. HyperX playback and microphone are the saved
defaults, with the immediately preceding levels retained: output 85% unmuted
and microphone 100% unmuted. HyperX output is advertised as 24-bit/48 kHz.
A quiet `pw-play` volume-change sound completed without error; audible sound
and the original pop have not been confirmed by the user. Existing Discord
playback/capture streams did not automatically reappear during verification;
if needed, reselect its audio devices or reconnect voice.

Pre-rollback state/configuration backup:
`~/.local/state/audio-migration/20261028-215847-restore-pipewire/`.
The original PulseAudio migration backup remains available below.

## Historical: optional graphical EQ installed, 2026-10-28 00:02 CET

At the user's request for an EQ similar to Peace/Equalizer APO, installed the
official Arch `pulseaudio-equalizer-ladspa 3.0.2-11` package with `bc 1.08.2-1`
and `swh-plugins 0.4.17-7`. This is a 15-band graphical equalizer compatible with
the current native PulseAudio server. No PipeWire audio package was reinstalled.

Launched `/usr/bin/pulseaudio-equalizer-gtk` detached as the user unit
`pulseaudio-equalizer-gui.service`. Verified both the live service/process and
KWin's running window titled "PulseAudio Equalizer", then activated that window.
Generated settings are flat (all 15 bands 0 dB, preamp 1.0), EQ disabled and
persistence disabled. No EQ sink is loaded; Firefox still uses the HyperX sink.
No Peace/Cloud III preset from the example screenshot was copied to Cloud III S
Wireless. EQ is available for the user to enable and configure; this is not a
verified remedy for the popping. The migration rollback helper now removes the
optional EQ package too, since it depends on native PulseAudio.

## PulseAudio migration, 2026-10-27 23:56 CET

The user requested replacing PipeWire after rejecting keep-alive workarounds and
reporting that the zeroramp trial still popped. This authorization covers the
replacement and necessary dependency changes; it does not establish a fix.

### Result and verification

- Installed `pulseaudio 17.0+r134+g77d25a1e6-1`,
  `pulseaudio-alsa 1:1.2.12-6`, and matching `pulseaudio-bluetooth` from signed
  official Arch packages. No repository refresh or full system upgrade occurred.
- Removed `pipewire-pulse`, `pipewire-alsa`, and `easyeffects`. EasyEffects has a
  hard dependency on `pipewire-pulse` in this Arch build, so it could not remain
  installed with native PulseAudio. Its presets/configuration remain in place
  and were also backed up. Its user autostart entry was moved into the backup.
- Retained `pipewire`, `pipewire-audio`, `pipewire-jack`, and `wireplumber`:
  KDE/other packages depend on these. PipeWire core remains available for video
  and screen capture. Existing JACK compatibility is retained; JACK audio is not
  part of this Firefox comparison and has not been validated under this setup.
- Added a hostname/Linux-scoped chezmoi template at
  `dot_config/wireplumber/wireplumber.conf.d/90-pulseaudio.conf.tmpl` and applied
  only its live target. It disables `monitor.alsa` and `monitor.bluez` in the
  WirePlumber `main` profile so PulseAudio can own the audio hardware. Scoped
  `chezmoi diff/status` is clean. No unrelated dotfiles were applied.
- `pulseaudio.service` and its enabled socket are active; `pipewire-pulse` is
  absent. `pipewire.service` and `wireplumber.service` are active. `pw-dump`
  showed no PipeWire hardware ALSA/Bluetooth audio nodes after the handover.
- `pactl info` reports **Server Name: pulseaudio**, not PulseAudio on PipeWire.
  The HyperX playback and microphone are defaults. The existing normal Firefox
  process reconnected without a browser restart and has a playback stream on
  the HyperX sink. `fuser` confirms the HyperX playback PCM is held by pulseaudio.
- Restored the saved Firefox stream volume from PulseAudio's initial 100% to
  the pre-migration 50%; the unmuted headset sink remains at its saved 100%.
- Hardware currently runs stereo `S16_LE` at 48000 Hz under PulseAudio defaults,
  compared with PipeWire's former `S24_3LE` at 48000 Hz. Thus this is a practical
  audio-stack replacement comparison, not an identical-format controlled test.
- No keep-alive, artificial background sound, zeroramp filter, firmware update,
  or new Firefox profile is active. No reboot was performed.
- Listening result: the user reports no clear improvement, possibly a small
  improvement or lower loudness. This does not establish a fix. Read-only
  recheck confirmed matching numeric headset and Firefox volumes before/after
  the migration: 100%/0 dB at the headset sink and 50%/-18.06 dB for Firefox,
  unmuted. Equal settings do not establish perceptually matched loudness.
  Bluetooth, screen sharing, and JACK applications have not been functionally
  tested.

### Corrected Windows reference and next comparison

The earlier report of no Windows popping was superseded by the user's
2026-10-28 clarification: **popping occurs on Windows too, but is less
irritating there**. Windows must not be treated as a pop-free reference.
The cause remains unconfirmed. Shared headset/dongle behavior is a possible
lead, while the perceived difference between operating systems still needs
characterization; neither establishes a hardware or Linux-specific fault.

Record the Windows output bit depth/sample rate, Windows and Firefox
mixer levels, enhancements/DTS/spatial-audio settings, actual driver provider and
version, and headset/dongle firmware versions. These have not yet been collected.
Matching exposed format/volume/effect settings is feasible; Windows can also
load vendor processing that cannot be copied by selecting an identically named
Linux option. Do not assume an APO or a particular Windows USB driver is active
on this device without inspecting it.

If matching visible settings still leaves the discrepancy, a read-only USB trace
comparison of one chess move after silence could distinguish different stream
start/stop, gain/mute, or vendor-control behavior. This is a proposed deeper
investigation, not a verified explanation or an authorized new experiment.
No Windows reboot, firmware update, capture installation, or further audio
configuration change was performed in response to this result.

### Backup and rollback

Private backup directory:
`~/.local/state/audio-migration/20261027-235510-pulseaudio/`.
It holds initial package/unit/routing state, PulseAudio and EasyEffects config
backups, WirePlumber state, the disabled EasyEffects autostart file, signed
replacement packages, and `ROLLBACK.md` plus `rollback-packages.sh`.

Rollback uses the exact cached PipeWire-Pulse, PipeWire-ALSA, and EasyEffects
package versions. Follow `ROLLBACK.md`: stop PulseAudio, restore packages, remove
only the migration-created WirePlumber live fragment and its source template,
restore the saved EasyEffects autostart, and restart the original PipeWire audio
units. Restore and verify the saved HyperX route and volumes. No Git commit or
push was requested or performed. Unrelated repository drift is preserved.

Configuration reference: [WirePlumber feature overrides](https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/modifying_configuration.html#customizing-the-loaded-features).

## Temporary chess zeroramp trial, 2026-10-27 23:50 CET

The user explicitly authorized this trial and selected chess move sounds as the
comparison. They report a loud initial pop, sometimes delayed popping, and
occasionally missing very short move sounds. These are observations, not a
confirmed PipeWire fault or proof of a single cause.

- Normal Firefox (existing profile/process) remains open. PipeWire and
  WirePlumber remain running; no audio service or browser restart was needed.
- A separate filter-chain process provides stereo `zeroramp`, with `Gap (s)` and
  `Duration (s)` both set to `0.001`. Only Firefox streams are routed through it.
  This tests abrupt transitions to/from exact digital silence; it does not
  establish that device-side muting or delayed/missing sounds are addressed.
- Verified active links on both channels: Firefox -> `hyperx_chess_anticlick` ->
  `hyperx_chess_anticlick_output` -> the stable HyperX sink.
- Firefox's existing 50% stream volume is retained; the filter is unity gain.
  Hardware remained stereo `S24_3LE` at 48000 Hz. A short `pw-top` sample showed
  zero errors for Firefox, the two filter nodes, and HyperX; this does not verify
  audible improvement or exclude intermittent faults.
- Runtime files: `/run/user/1000/hyperx-chess-anticlick-ygjqb1zo/`. No permanent
  PipeWire/WirePlumber configuration was installed.
- Unit: `hyperx-chess-anticlick.service`, with `RuntimeMaxSec=600`. Its wrapper
  restores Firefox's original output before terminating the filter, both on
  manual stop and timeout (scheduled about 2026-10-28 00:00:36 CET).
- Manual rollback: `systemctl --user stop hyperx-chess-anticlick.service`.
  Verify Firefox is back on the HyperX sink and the temporary sink is absent.
- Listening result: the user reported that popping remained, although the first
  couple of moves appeared not to pop. This trial did not establish a reliable
  improvement; the initial clean moves alone do not establish a cause.
- Manually stopped after that report. Verified the temporary sink was absent,
  the rollback marker existed, and Firefox was back directly on the stable
  HyperX sink, unmuted at its original 50% stream volume. Hardware remained
  stereo `S24_3LE` at 48000 Hz. No anti-click filter remains active.

An earlier separate Firefox ALSA window was closed at the user's request, and
the HyperX duplex profile and normal Firefox/PipeWire routing were restored.
Direct ALSA playback from Firefox was not verified, so that attempt supplies no
valid PipeWire-versus-ALSA listening comparison. The normal Firefox profile was
not modified.

## Earlier resume boundary and conversational position (17:12 checkpoint)

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

## Symptom and setup at the 2026-10-27 checkpoint

- An electrical pop/click when sound emerges after silence, resembling insertion
  of a 3.5 mm connector. The later 2026-10-28 clarification confirms popping on Windows too, but
  less irritating there. Exact Windows settings have not been collected.
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

## Earlier state, verified 2026-10-27 17:12 CET

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

## Earlier proposed next steps (17:12 checkpoint)

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

At this earlier checkpoint, not yet implemented: direct ALSA comparison,
anti-click fade/zeroramp,
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
  — fades for abrupt digital-silence transitions; the later trial is recorded above.
- [WirePlumber configuration locations](https://pipewire.pages.freedesktop.org/wireplumber/daemon/locations.html)
  — runtime overrides and fragment search paths used in the 96 kHz trial.

## Historical repository checkpoint (2026-10-27)

Source: `~/.local/share/chezmoi`, branch `main`. Publication base: `d1e384e`.
After saving the checkpoint, the user explicitly requested a commit and push.
That publication covered this record, its `README.md` index, and
`../linux-audio.md` as a link to the consolidated record.

Other configuration edits and the existing untracked KDE, gaming, sleep, and Zsh
documentation were outside that earlier commit's scope. Publishing these notes applies
no audio settings and does not authorize another experiment.
