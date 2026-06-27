# ziro

A macOS productivity dashboard with anime-inspired aesthetics — built with SwiftUI, SwiftData, and AVFoundation.

**ziro** combines a focus timer, task management (Eisenhower matrix), habit tracker, notes, calendar, statistics, and local video/audio playback into a single menu-bar app with a polished, minimalist UI.

> **Note**: This repository contains **source code only**. You must build the project using Xcode.

---

## Features

- **Dashboard** — Animated video background (import your own), music player, pomodoro timer, live stats
- **Focus Timer** — Full-screen focus sessions with configurable duration and progress tracking
- **Task Management** — Full CRUD with priorities, due dates, search, filters, and context menus
- **Eisenhower Matrix** — Auto-categorizes tasks into Do/Schedule/Delegate/Eliminate quadrants
- **Calendar** — Month view with day selection
- **Notes** — Rich text editor with pinning, search, and delete
- **Habits** — Daily check-in tracker with streak counting and archiving
- **Statistics** — Live counts for tasks, pomodoros, habits, and best streak
- **Music Library** — Import MP3/AAC/FLAC/WAV/OGG from your Mac, play with speed/seek/volume controls
- **Video Library** — Import videos, preview with full transport controls, set as dashboard background
- **Menu Bar** — Quick-access status icon with music controls, video info, and focus session shortcut
- **Theme Switching** — System/Light/Dark with global preference storage

---

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later
- Apple Developer account (for signing, optional)

## Build Instructions

```bash
# 1. Clone the repository
git clone https://github.com/HiddenCedar/ziro.git
cd ziro

# 2. Open the project in Xcode
open ziro.xcodeproj

# 3. Select your target:
#    - Scheme: ziro (macOS)
#    - Destination: My Mac

# 4. Build and run (⌘B → ⌘R)
```

The app runs as a menu-bar agent (no dock icon). Look for the icon in your menu bar after launching.

## Project Structure

```
ziro/
├── App/              — Entry point, sidebar, content routing, menu bar delegate
├── Components/       — Reusable UI (buttons, charts, visual effects)
├── Extensions/       — Color, view modifiers, theme constants
├── Features/         — One folder per feature (Dashboard, Focus, Tasks, etc.)
├── Managers/         — Data seeding, notifications, statistics, shortcuts
├── Models/           — SwiftData schema (TaskModel, HabitModel, etc.)
├── Resources/        — Info.plist, asset catalog
├── Services/         — AnimeVideoLibrary, AnimeAudioLibrary
└── Utilities/        — Formatters, date helpers
```

## Architecture

- **SwiftUI** + **SwiftData** for the UI and persistence layer
- **AVPlayer** / **AVPlayerItem** for video and audio playback
- **NSVisualEffectView** for glass-morphism backgrounds
- **LSUIElement** enabled for menu-bar-only operation

---

*Inspired by anime ambiance videos and the desire for a beautiful, focused workspace.*
