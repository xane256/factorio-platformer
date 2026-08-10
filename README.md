# factorio-platformer

Forks of two GPLv3 Factorio mods by Corlin, ported to 2.1 and renamed to
coexist with the originals:

- [platformer-fork](https://mods.factorio.com/mod/platformer-fork) — fork of
  [Platformer](https://mods.factorio.com/mod/platformer) by Corlin & Xiroc:
  skyblock Space Age. One platform, no landing, asteroids for resources.
- [space-platform-chests-fork](https://mods.factorio.com/mod/space-platform-chests-fork)
  — fork of [Space Platform Chests](https://mods.factorio.com/mod/space-platform-chests)
  by Corlin: chests that teleport their contents into the hub. Required by
  platformer-fork.

## Playing

Install both from the portal. Can't run alongside the upstream mods —
prototype names are unchanged, so the copies would collide. Same fact makes
upstream saves portable: swap the forks in on the mod-sync screen and
everything carries over.

Gameplay changes beyond the port:

- A hub-chest on a hubless surface (an Editor Extensions lab) acts as a full
  chest. Upstream crashed on pasting one there.
- A toolbar shortcut founds another platform in the current orbit, consuming
  a starter pack from the hub — the vanilla flow needs a planetside silo,
  and Platformer has no planets.
- Founded platforms are ordinary vanilla platforms: 2.1 transfers work
  between them, and each platform's chests feed its own hub.

## Working on it

Each mod directory is the unzipped mod. The first commit is pristine
upstream, so `git log` reads as the complete port.

Test loop — build a symlink mod dir once, then run headless against any 2.1
binary:

```sh
mkdir .modtest && cp test/mod-list.json .modtest/
ln -s "$PWD"/platformer-fork "$PWD"/space-platform-chests-fork "$PWD"/test/spc-test .modtest/

"$FA" --mod-directory "$PWD/.modtest" --create /tmp/test-map.zip
"$FA" --mod-directory "$PWD/.modtest" --benchmark /tmp/test-map.zip --benchmark-ticks 900 --disable-audio
```

`--create` runs the prototype stage plus `on_init` (platform creation, save
adoption); `--benchmark` runs `test/spc-test`, which logs a `SPCTEST:` line
per check with the value it wants. The binary exits 0 on load errors — read
the output. Not covered headlessly: `on_player_created`, GUI feel.

`scripts/publish.sh` uploads whatever committed versions the portal lacks.
Key in `~/.config/factorio-portal-key`; refuses a dirty tree.

GPLv3, as upstream.
