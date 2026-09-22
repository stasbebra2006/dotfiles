---
name: download-song
description: Download a song from SoundCloud or another yt-dlp-supported track URL, verify the saved audio, and optionally open it in the default player or reveal it in the file manager. Use when the user asks to download or install a song, or open a previously downloaded song in Files.
---

# Download Song

## Download

1. Use the user's exact track URL. If only a title is supplied, locate and verify the matching track before downloading; a search-results URL is not a track URL.
2. Default to `~/Music` and the best available audio without lossy conversion. Honor an explicitly requested destination or format. Do not download an entire playlist when the user requested one song.
3. Check for `yt-dlp`, `uv`, and `ffprobe` using `command -v`. Use installed `yt-dlp` when available; otherwise use `uvx yt-dlp` if `uv` exists. This avoids installing a system package. If neither runner exists, resolve installation using the host's package-management conventions rather than assuming sudo access.
4. Run the download with the real URL substituted for `TRACK_URL`:

   ```bash
   uvx yt-dlp --no-playlist -f bestaudio \
     -o "$HOME/Music/%(title)s.%(ext)s" \
     --print after_move:filepath -- TRACK_URL
   ```

   Replace `uvx yt-dlp` with `yt-dlp` when installed. Quote the actual URL. yt-dlp creates missing destination directories. Preserve an existing unrelated file if a title collides; use `%(title)s [%(id)s].%(ext)s` for that download rather than overwriting it.

5. Capture the final path from the successful command; do not guess its extension. Container fixups and MP3 conversion require `ffmpeg`. If MP3 was explicitly requested, add `-x --audio-format mp3 --audio-quality 0`. Converting to MP3 does not improve source quality.
6. Verify the actual saved file with the real path substituted below:

   ```bash
   ffprobe -v error -show_entries format=duration,size:stream=codec_name \
     -of json '/absolute/path/to/song.m4a'
   ```

   Confirm an audio stream, positive duration, and nonzero size. Report the path, duration, and format only after successful download and verification. Do not treat a partial download or an extraction error as success.

## Open or Reveal

Use the known downloaded path. “Open it” means the default audio player; “open in Files” means reveal the file in the file manager, not play it. Only perform these actions when requested.

On Linux with a systemd user session, launch GUI applications detached from the agent process tree:

```bash
systemd-run --user --collect xdg-open '/absolute/path/to/song.m4a'
```

On KDE, reveal and select the song in Dolphin:

```bash
systemd-run --user --collect dolphin --select '/absolute/path/to/song.m4a'
```

Use unique automatically generated service names, not a fixed unit name that can collide with a running player. Check launch errors; service creation alone does not prove that playback started. If confirming the GUI is not possible, report that the open request was sent rather than claiming playback was verified.

On other desktops, use the available file manager's reveal action; opening the containing directory is a fallback, and must not be described as selecting the file. On macOS, use `open` for playback and `open -R` to reveal the file.

## Boundaries

- Download only the requested track; do not change desktop defaults or start playback automatically.
- Do not store session cookies, account credentials, downloaded media, or generated caches in the skill or dotfiles repository.
- A private, removed, region-restricted, or login-required track is an access limitation, not a reason to silently substitute another recording.
