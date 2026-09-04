# Chroma Orbit — Game Design

## One-line pitch
A one-tap orbit-launch arcade game where timing your release angle and
reading color patterns both matter — chain matching-hue prisms for
escalating combos, dodge the spiked hazard ones, and see how far the chain
goes.

## Core mechanic
The player orb is always doing exactly one of two things:

1. **Orbiting** the current prism, sweeping around it automatically.
2. **Flying** in a dead-straight line after being launched.

A single tap is the entire control surface: it releases the orb
tangentially, at whatever angle it happens to be at on the orbit ring the
instant you tap. There is no steering after that — the orb flies straight
until it either comes within capture range of the next prism (and starts
orbiting it), flies far enough past it to be a miss, hits a hazard prism, or
leaves the screen.

This gives the game a single, legible skill: **read the current prism's
spin and tap at the moment that sends you toward the next one.** Because
the flight path is a straight line, the same small timing error produces a
proportionally larger miss the farther away (or the faster-spinning) the
next prism is — so difficulty ramps purely from geometry, without needing a
separate "precision" stat bolted on top.

## The color layer
Every prism has one of three hues (cyan / magenta / gold). Landing on a
prism whose hue matches the one you just launched from extends your combo
multiplier (`score += 10 × combo`); landing on a different hue resets the
combo to 1. This adds a second thing to track — "is the next prism my
color?" — without adding a second input. Skilled play means threading
same-color runs together for large scores, not just surviving.

## Hazards
Spiked, fast-spinning red prisms are never safe to touch, in flight or
otherwise — contact ends the run immediately. They start appearing after a
short hazard-free ramp (the first few prisms of every run) so a new player
gets a few reps of the core mechanic before anything can kill them.

## Failure states
A run ends when the orb:
- touches a hazard prism, or
- drifts past the next prism without ever coming into capture range, or
- flies off the top or bottom of the screen.

## Progression / difficulty curve
`LevelGenerator` (`ChromaOrbit/Models/LevelGenerator.swift`) derives a
single `difficulty` value from how many prisms have been passed and uses it
to widen prism spacing, speed up orbit spin, and raise hazard frequency —
all three curves are capped so the game plateaus into a consistent "hard
but fair" ceiling rather than becoming unplayable.

## Presentation
- Dark navy background, neon cyan/magenta/gold palette, glowing hex
  prisms and spiked hazard stars.
- All glow/particle textures are generated procedurally at runtime
  (`Models/Textures.swift`) — the project ships with zero bundled image
  assets besides the App Icon.
- All sound effects are synthesized sine-wave tones generated at runtime
  (`Managers/SoundManager.swift`) — no bundled audio assets either. Capture
  pitch rises with combo length; the shatter tone descends.
- Haptics: a light tap on launch, a medium thud on capture, and a
  notification-error buzz on a run ending.

## Why this fits a first solo App Store release
- Single input (tap), understood in seconds, no tutorial screen needed —
  the menu preview animates the mechanic before you even press Play.
- Runs are short (typically 20–90 seconds), which suits mobile "one more
  try" sessions.
- No IAP, no ads, no network calls, no data collection — nothing for App
  Review to flag, and no server to operate.
- Endless/procedural, so there's no content wall — a strong high-score
  chase is the entire retention loop.
