<!-- foundation:identity -->
# RogueDelve

A simple single-screen browser roguelike: procedurally generated dungeon levels, turn-based movement, lootable items, normal and special monsters, a definite end goal, and a kills-based top-scorer lea

- Site: https://rogue-delve.api.holode.xyz
- Support: support@rogue-delve.api.holode.xyz
<!-- /foundation:identity -->

## What this is

A simple single-screen browser roguelike: procedurally generated dungeon levels, turn-based movement, lootable items, normal and special monsters, a definite end goal, and a kills-based top-scorer leaderboard.

## Who it is for

- Player (guest, plays runs in the browser, name recorded at run end)
- Visitor (views the leaderboard)

## Main features

- **Start a run** — Player enters a name and starts a new game; dungeon level 1 generates with player, monsters, items, and stairs.
- **Move and fight** — Arrow/WASD moves the player turn by turn; stepping onto a monster attacks it; monsters take a turn after the player.
- **Loot items** — Walking over an item picks it up; potions heal, tomes buff attack, shields buff defense; inventory is shown.
- **Descend** — Walking onto stairs descends to the next generated level, deeper and harder.
- **Reach the goal and end the game** — Reaching the goal depth (defeating the final boss / claiming the artifact at depth 5) ends the run as a win; dying ends it as death; either way the run records a score entry.
- **View leaderboard** — Top scorers ranked by kills, showing name, kills, depth, score, and result.

## Core entities

- Game
- Level
- Monster
- Item
- ScoreEntry

## Run locally

```bash
bundle install
bin/rails db:prepare
bin/dev
```

Requires Ruby, PostgreSQL, and the usual Rails toolchain. See `bin/setup` if present.

## Demo

A few sample ScoreEntries so the leaderboard is populated before anyone plays, and a fresh starter run demonstrating level 1 generation.

## Deploy notes

Production `config.hosts` is derived from `domain` in `config/foundation.yml`. Keep that value aligned with the real host or every request will 403.
