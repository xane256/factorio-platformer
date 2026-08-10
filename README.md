# factorio-platformer

Fork of two Factorio mods by Corlin (GPLv3), ported to Factorio 2.1 and
renamed so they can live on the mod portal alongside the originals:

- **`platformer-fork/`** — fork of [Platformer](https://mods.factorio.com/mod/platformer),
  a skyblock-style Space Age overhaul: you live on a single space platform,
  never land, and feed the factory from asteroids. Upstream 1.0.6 targeted 2.0.
- **`space-platform-chests-fork/`** — fork of
  [Space Platform Chests](https://mods.factorio.com/mod/space-platform-chests),
  its dependency (hub-teleport chests), same author.

The first commit is the pristine upstream zips; everything after it is the
port. Port details live in each mod's `changelog.txt`. The 2.1 breakage was
confined to the prototype stage (recipe product and category schema changes);
the control-stage code already used 2.0-era APIs that 2.1 kept.

Prototype names ("hub-chest", asteroid and recipe names) are unchanged from
upstream, so the forks declare `!` incompatibility with the upstream mods —
enabling both would collide. Saves started with the upstream mods do not carry
over: the mod names differ, and Factorio treats them as unrelated mods.

## Test loop

`.modtest/` (gitignored) symlinks both mod dirs next to a `mod-list.json` so
the game loads the working tree directly. Against the Steam install:

```sh
FA="$HOME/Library/Application Support/Steam/steamapps/common/Factorio/factorio.app/Contents/MacOS/factorio"

# data stage + on_init: creates a map, exits. Errors print to stdout.
"$FA" --mod-directory "$PWD/.modtest" --create /tmp/test-map.zip

# control stage: run the map headless for a minute of game time.
"$FA" --mod-directory "$PWD/.modtest" --benchmark /tmp/test-map.zip --benchmark-ticks 3600 --disable-audio
```

The binary exits 0 even on load errors; read the output, not the exit code.
Neither step creates a player, so `on_player_created` (character destroy +
teleport to the platform) is only exercised by starting a real game.

## Packaging

Zip each mod dir as `<name>_<version>/` (dir name must match `info.json`) and
drop the zips in `~/Library/Application Support/factorio/mods/`. Include
`LICENSE` in each zip: GPLv3 requires the license text to travel with the
distribution.

## Publishing

Both mods publish to the mod portal under the fork names via the
[publish API](https://wiki.factorio.com/Mod_publish_API): `init_publish` with
an API key (factorio.com profile -> API keys, "ModPortal: Publish Mods"
permission), then POST the zip to the returned upload URL, which also accepts
description, category, license, and source_url fields. Subsequent releases use
the [upload API](https://wiki.factorio.com/Mod_upload_API) ("ModPortal: Upload
Mods" permission) against the existing mod name.
