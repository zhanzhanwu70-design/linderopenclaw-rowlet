# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.
-e 
## Local Whisper.cpp Transcription

本機轉錄已實作，不用 OpenAI Whisper API、不上傳音檔。

- Source: `/home/node/.openclaw/local/whisper.cpp`
- Model: `/home/node/.openclaw/local/whisper.cpp/models/ggml-small.bin`
- Portable toolchain: `/home/node/.openclaw/local/toolchain`（CMake + Ninja + Zig，免 root）
- Build/rebuild: `/home/node/.openclaw/local/bin/build-whispercpp`
- Single/batch audio: `/home/node/.openclaw/local/bin/whispercpp-transcribe <wav-or-dir>`
- YouTube audio + transcript: `/home/node/.openclaw/local/bin/youtube-whispercpp-transcribe <youtube-url> [output-dir]`

Wrapper 預設使用 `-ng -nfa` CPU-only / no flash-attn，因為 dynamic/shared build 曾在 model load 後 `free(): invalid pointer`；目前 static build smoke test OK。

## API Key Reading

When you need an API key, use:

const fs = require('fs');
const apiKey = fs.readFileSync(process.env.OPENAI_API_KEY_DIR, 'utf8').trim();

OPENAI_API_KEY_DIR = /home/node/.openclaw/secrets/openai-api-key.txt
