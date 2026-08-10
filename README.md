# factorio-platformer

Two of Corlin's GPLv3 Factorio mods, forked and ported to 2.1, renamed so
they don't clash with the originals on the mod portal:

- [platformer-fork](https://mods.factorio.com/mod/platformer-fork) — fork of
  [Platformer](https://mods.factorio.com/mod/platformer) by Corlin & Xiroc:
  skyblock Space Age. One platform, no landing, asteroids for resources.
- [space-platform-chests-fork](https://mods.factorio.com/mod/space-platform-chests-fork)
  — fork of [Space Platform Chests](https://mods.factorio.com/mod/space-platform-chests)
  by Corlin: chests that teleport their contents into the hub. Required by
  platformer-fork.

## Playing

Install both from the portal. You can't run these alongside the upstream
mods; the prototype names are unchanged, so the two copies collide. That
also means upstream saves come over fine: swap the forks in on the mod-sync
screen and everything carries over.

Gameplay changes beyond the port:

- A hub-chest on a hubless surface (an Editor Extensions lab) just acts
  full. Upstream crashed if you pasted one there.
- There's a toolbar shortcut that starts a new platform in the current
  orbit, paid for with a starter pack from the hub. The vanilla flow needs
  a planetside silo, and Platformer has no planets.
- New platforms are ordinary vanilla platforms: 2.1 transfers work between
  them, and each platform's chests feed its own hub.

## Working on it

Each mod directory is the unzipped mod. The first commit is pristine
upstream, so `git log` reads as the complete port.

Build the symlink mod dir once, then run headless against any 2.1 binary:

```sh
mkdir .modtest && cp test/mod-list.json .modtest/
ln -s "$PWD"/platformer-fork "$PWD"/space-platform-chests-fork "$PWD"/test/spc-test .modtest/

"$FA" --mod-directory "$PWD/.modtest" --create /tmp/test-map.zip
"$FA" --mod-directory "$PWD/.modtest" --benchmark /tmp/test-map.zip --benchmark-ticks 900 --disable-audio
```

`--create` runs the prototype stage plus `on_init` (platform creation, save
adoption); `--benchmark` runs `test/spc-test`, which logs a `SPCTEST:` line
for each check with the value it expects. The binary exits 0 even on load
errors, so read the output. The harness doesn't catch `on_player_created`
(that needs a real player join) and says nothing about GUI feel.

`scripts/publish.sh` uploads whatever committed versions the portal lacks.
It reads the key from `~/.config/factorio-portal-key` and refuses a dirty
tree.

GPLv3, as upstream.
