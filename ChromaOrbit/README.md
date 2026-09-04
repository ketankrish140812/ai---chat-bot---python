# Chroma Orbit

A one-tap arcade game for iOS, built with **Swift + SwiftUI + SpriteKit**.
See [`GAME_DESIGN.md`](GAME_DESIGN.md) for the mechanic and why it's
designed the way it is.

This project was written without access to Xcode or a Mac (developed in a
Linux CLI environment), so while the code has been carefully reviewed by
hand, **it has not been compiled**. Do the first build in Xcode before
relying on it — see [Known risk](#known-risk--first-build) below.

## Requirements

- macOS with **Xcode 16** or later
- No third-party dependencies, no CocoaPods/SPM packages, no bundled media
  assets to fetch — the whole game is Swift source plus one PNG app icon.

## Open & run

```bash
open ChromaOrbit/ChromaOrbit.xcodeproj
```

Pick any iPhone simulator and hit **Run** (⌘R). The game is portrait-only.

## Project layout

```
ChromaOrbit/
  ChromaOrbit.xcodeproj/
  ChromaOrbit/
    ChromaOrbitApp.swift      — @main SwiftUI App entry point
    GameScene.swift           — the whole game engine (SpriteKit)
    GameState.swift           — observable state shared with SwiftUI chrome
    Views/                    — MenuView, HUDView, GameOverView, ContentView
    Models/                   — Prism, PlayerOrb, LevelGenerator, ColorTheme, Textures
    Managers/                 — HighScoreManager, HapticsManager, SoundManager
    Assets.xcassets/          — App Icon + accent color (no other bundled assets)
```

## Before you submit to the App Store

1. **Bundle identifier & team.** The project ships with a placeholder
   `PRODUCT_BUNDLE_IDENTIFIER` of `com.example.chromaorbit`. In Xcode:
   select the `ChromaOrbit` target → *Signing & Capabilities* → set your
   Team, and change the bundle identifier to one under your own developer
   account (e.g. `com.yourcompany.chromaorbit`).
2. **App name collision.** "Chroma Orbit" hasn't been checked against the
   live App Store catalog — search it in App Store Connect when you create
   the app record, and adjust `INFOPLIST_KEY_CFBundleDisplayName` in the
   target's build settings if it's taken.
3. **Version numbers.** `MARKETING_VERSION` (1.0) and `CURRENT_PROJECT_VERSION`
   (1) are set in the target's build settings — bump the build number on
   every subsequent upload.
4. **Screenshots.** App Store Connect requires screenshots for at least one
   6.9" (or 6.5") and one 5.5" display size. Easiest path: run the app in
   the corresponding simulators and use *Simulator → Device → Screenshot*
   (⌘S) while playing.
5. **Archive & upload:** *Product → Archive*, then use the Organizer's
   *Distribute App → App Store Connect* flow.

### Suggested App Store Connect metadata

- **Category:** Games → Arcade
- **Age rating:** 4+ (no objectionable content, no user-generated content,
  no web access)
- **Privacy:** the app makes no network requests and collects no data —
  `bestScore` is stored locally via `UserDefaults` only. In App Store
  Connect's Privacy Nutrition Label questionnaire, answer "No" to data
  collection.
- **Subtitle idea:** "One-tap orbit arcade"
- **Keywords idea:** `orbit,arcade,one tap,color,reflex,casual,endless,combo`
- **Promotional text idea:** "Tap to launch off every prism. Chain matching
  colors for combos. Dodge the spiked ones. How far can you get?"

## Known risk — first build

Because this was authored without a Swift toolchain available, the code
has been checked carefully for API correctness and the `.pbxproj` was
generated and structurally validated (every object reference resolves,
every source file on disk has a matching project entry and vice versa) —
but it has never actually been run through `swiftc` or Xcode's build
system. If Xcode reports an error on first open, it is most likely a small
one (a typo'd API name or similar); the architecture and file wiring have
been verified independently of compilation.

## Testing the mechanic without a device

`ChromaOrbit/Models/LevelGenerator.swift` has zero SpriteKit or UIKit
dependencies by design — it's pure `CoreGraphics` math — specifically so
you (or a test target you add) can exercise the difficulty curve without
booting the simulator.
