---
name: Remotion
description: "Best practices for Remotion - Video creation in React. Compositions, animations, transitions, audio, captions, 3D, charts, rendering, and content-to-animation workflows. Use when Remotion, video, animation, motion graphics, Remotion render, create video, animate content, video composition, programmatic video."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
---

# Remotion — Video Creation in React

Programmatic video creation using React components. Every frame is a function of time — no CSS animations, no third-party animation libraries.

**Project location:** Set `REMOTION_PROJECT_DIR` in `~/.env` or use the current working directory.

## When to Use

Use this skill whenever working with Remotion code, creating programmatic videos, or transforming content into animations.

## Critical Rules

1. **NO CSS animations** — they won't render. Use `useCurrentFrame()` for all animations
2. **NO third-party animation libraries** — they cause flickering. Drive animations from frame number
3. **Use `staticFile()`** for assets in `/public` directory
4. **Extrapolate carefully** — use `extrapolateRight: 'clamp'` to prevent overflow
5. **Props with Zod** — define schemas for type-safe, configurable compositions

## Video Size Presets

| Format | Dimensions | Use Case |
|--------|------------|----------|
| YouTube landscape | 1920x1080 | Default |
| YouTube Shorts | 1080x1920 | Vertical clips |
| Square | 1080x1080 | Instagram |
| Instagram portrait | 1080x1350 | Feed posts |
| Twitter/X | 1280x720 | Landscape |

## Code Patterns

See [./Patterns.md](./Patterns.md) for core pattern, spring, sequence, series, and OffthreadVideo examples.

## Captions

When dealing with captions or subtitles, load [./rules/subtitles.md](./rules/subtitles.md).

## Using FFmpeg

For video operations (trimming, silence detection), load [./rules/ffmpeg.md](./rules/ffmpeg.md).

## Silence Detection

For detecting and trimming silent segments, load [./rules/silence-detection.md](./rules/silence-detection.md).

## Audio Visualization

For spectrum bars, waveforms, bass-reactive effects, load [./rules/audio-visualization.md](./rules/audio-visualization.md).

## Sound Effects

For sound effects, load [./rules/sfx.md](./rules/sfx.md).

## PAI Theme

All PAI videos use a consistent theme. See [./ArtIntegration.md](./ArtIntegration.md) and [./Tools/Theme.ts](./Tools/Theme.ts).

## Content-to-Animation Workflow

Transform any content (blog posts, YouTube, articles, raw text) into animated videos. See [./Workflows/ContentToAnimation.md](./Workflows/ContentToAnimation.md).

## Rendering

Programmatic rendering interface at [./Tools/Render.ts](./Tools/Render.ts).

```bash
cd <project-directory>
bunx remotion render my-composition output/video.mp4
```

## Rule Files Reference

Detailed explanations and code examples for every Remotion topic:

- [rules/3d.md](rules/3d.md) — 3D content using Three.js and React Three Fiber
- [rules/animations.md](rules/animations.md) — Fundamental animation patterns
- [rules/assets.md](rules/assets.md) — Importing images, videos, audio, and fonts
- [rules/audio.md](rules/audio.md) — Audio: importing, trimming, volume, speed, pitch
- [rules/audio-visualization.md](rules/audio-visualization.md) — Spectrum bars, waveforms, bass-reactive effects
- [rules/calculate-metadata.md](rules/calculate-metadata.md) — Dynamic composition duration, dimensions, props
- [rules/can-decode.md](rules/can-decode.md) — Browser video decode check via Mediabunny
- [rules/charts.md](rules/charts.md) — Bar, pie, line, stock chart patterns
- [rules/compositions.md](rules/compositions.md) — Compositions, stills, folders, default props
- [rules/display-captions.md](rules/display-captions.md) — TikTok-style captions with word highlighting
- [rules/extract-frames.md](rules/extract-frames.md) — Frame extraction via Mediabunny
- [rules/ffmpeg.md](rules/ffmpeg.md) — FFmpeg operations for trimming, silence detection
- [rules/fonts.md](rules/fonts.md) — Google Fonts and local font loading
- [rules/get-audio-duration.md](rules/get-audio-duration.md) — Audio duration via Mediabunny
- [rules/get-video-dimensions.md](rules/get-video-dimensions.md) — Video width/height via Mediabunny
- [rules/get-video-duration.md](rules/get-video-duration.md) — Video duration via Mediabunny
- [rules/gifs.md](rules/gifs.md) — GIFs synchronized with timeline
- [rules/images.md](rules/images.md) — Img component for embedding images
- [rules/import-srt-captions.md](rules/import-srt-captions.md) — SRT subtitle import via @remotion/captions
- [rules/light-leaks.md](rules/light-leaks.md) — Light leak overlay effects
- [rules/lottie.md](rules/lottie.md) — Lottie animation embedding
- [rules/maps.md](rules/maps.md) — Mapbox map animation
- [rules/measuring-dom-nodes.md](rules/measuring-dom-nodes.md) — DOM element dimension measurement
- [rules/measuring-text.md](rules/measuring-text.md) — Text dimensions, fitting, overflow detection
- [rules/parameters.md](rules/parameters.md) — Parametrizable videos with Zod schemas
- [rules/sequencing.md](rules/sequencing.md) — Delay, trim, limit duration of items
- [rules/sfx.md](rules/sfx.md) — Sound effects
- [rules/silence-detection.md](rules/silence-detection.md) — Adaptive silence detection via FFmpeg
- [rules/subtitles.md](rules/subtitles.md) — Subtitle handling and display
- [rules/tailwind.md](rules/tailwind.md) — TailwindCSS in Remotion
- [rules/text-animations.md](rules/text-animations.md) — Typography and text animation patterns
- [rules/timing.md](rules/timing.md) — Interpolation curves: linear, easing, spring
- [rules/transcribe-captions.md](rules/transcribe-captions.md) — Audio transcription for captions
- [rules/transitions.md](rules/transitions.md) — Scene transition patterns
- [rules/transparent-videos.md](rules/transparent-videos.md) — Rendering with transparency
- [rules/trimming.md](rules/trimming.md) — Cut beginning or end of animations
- [rules/videos.md](rules/videos.md) — Video embedding: trimming, volume, speed, looping, pitch
- [rules/voiceover.md](rules/voiceover.md) — AI voiceover via ElevenLabs TTS
