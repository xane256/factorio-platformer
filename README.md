# factorio-platformer

Forks of two GPLv3 Factorio mods by Corlin, ported to Factorio 2.1 and
renamed so they can live on the mod portal alongside the originals:

- [platformer-fork](https://mods.factorio.com/mod/platformer-fork) — fork of
  [Platformer](https://mods.factorio.com/mod/platformer) by Corlin & Xiroc: a
  skyblock-style Space Age overhaul. You live on a space platform, never
  land, and feed the factory from passing asteroids.
- [space-platform-chests-fork](https://mods.factorio.com/mod/space-platform-chests-fork)
  — fork of [Space Platform Chests](https://mods.factorio.com/mod/space-platform-chests)
  by Corlin: chests that teleport their contents into the platform hub.
  Required by platformer-fork.

## Playing

Install both from the mod portal. The forks refuse to run alongside the
upstream mods: prototype names are unchanged, so the two copies would
collide. Unchanged names are also what makes upstream saves portable — load
one, swap the forks in on the mod-sync screen, and the mods adopt it on
first load. The platform, hub chests, researched techs, and everything
placed carry over.

Beyond the port, the forks change gameplay in three ways:

- A hub-chest on a surface with no hub — an Editor Extensions lab, any
  non-platform surface — acts as a full chest. Upstream crashed on
  blueprint-pasting one there; in multiplayer the paste killed the server.
- A toolbar shortcut founds an additional platform in the current orbit,
  consuming a space platform starter pack from the hub. Vanilla founds
  platforms from a planetside silo; Platformer has no planets to build one
  on. Also callable as `remote.call("platformer", "new_platform", force,
  platform)`.
- Founded platforms are ordinary vanilla platforms. Factorio 2.1's
  platform-to-platform transfers work between them, and hub chests on each
  platform feed that platform's own hub.

## Working on it

Each mod directory is the unzipped mod. The first commit is the pristine
upstream release, so `git log` reads as the complete port; user-facing
changes also land in each mod's `changelog.txt`.

The game can load the working tree directly through a directory of
symlinks. Build it once:

```sh
mkdir .modtest && cp test/mod-list.json .modtest/
ln -s "$PWD"/platformer-fork "$PWD"/space-platform-chests-fork "$PWD"/test/spc-test .modtest/
```

Then, against a Factorio 2.1 install (`FA` = path to its binary):

```sh
"$FA" --mod-directory "$PWD/.modtest" --create /tmp/test-map.zip
"$FA" --mod-directory "$PWD/.modtest" --benchmark /tmp/test-map.zip --benchmark-ticks 900 --disable-audio
```

`--create` runs the prototype stage plus `on_init` — platform creation,
starter pack, save adoption. `--benchmark` then exercises control-stage
code: `test/spc-test` stages a scenario each 120 ticks (hubless chest
blocked, chest-to-hub teleport, sibling platform founded, hub destroyed and
chests re-blocked) and logs one `SPCTEST:` line per check, each stating the
value it wants. The binary exits 0 even on load errors, so read the output,
not the exit code. No headless run covers `on_player_created` (it needs a
real player join) or GUI feel.

`scripts/publish.sh` uploads any committed mod version the portal lacks,
creating the portal entry on first publish. It reads the API key from
`~/.config/factorio-portal-key` and refuses a dirty tree.

GPLv3, as upstream.
