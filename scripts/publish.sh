#!/usr/bin/env bash
# Sync the checked-out mods to the Factorio mod portal.
# Skips any mod whose info.json version is already released; otherwise packages
# the committed tree and uploads. First-time publish creates the portal entry
# with the description/category/license constants below.
#
# Key: $FACTORIO_PORTAL_KEY, or ~/.config/factorio-portal-key. Needs both
# "ModPortal: Publish Mods" and "ModPortal: Upload Mods" permissions.
# Optional: $SOURCE_URL adds a source link on first publish.
set -euo pipefail
cd "$(dirname "$0")/.."

KEY="${FACTORIO_PORTAL_KEY:-$(cat "$HOME/.config/factorio-portal-key")}"
MODS=(platformer-fork space-platform-chests-fork)
LICENSE=default_gnugplv3

category() {
    case "$1" in
        platformer-fork) echo overhaul ;;
        space-platform-chests-fork) echo content ;;
    esac
}

description() {
    case "$1" in
        platformer-fork) echo 'Fork of [Platformer](https://mods.factorio.com/mod/platformer) by Corlin & Xiroc, ported to Factorio 2.1. Loads saves started with the original. All credit upstream.' ;;
        space-platform-chests-fork) echo 'Fork of [Space Platform Chests](https://mods.factorio.com/mod/space-platform-chests) by Corlin, ported to Factorio 2.1.' ;;
    esac
}

json_field() { python3 -c "import json,sys; print(json.load(sys.stdin)$2)" <<<"$1"; }

for mod in "${MODS[@]}"; do
    version=$(json_field "$(cat "$mod/info.json")" "['version']")

    if [ -n "$(git status --porcelain -- "$mod" LICENSE)" ]; then
        echo "$mod: uncommitted changes, refusing to publish" >&2
        exit 1
    fi

    portal=$(curl -s "https://mods.factorio.com/api/mods/$mod/full")
    if ! grep -q '"message"' <<<"$portal" &&
        python3 -c "import json,sys; d = json.load(sys.stdin); sys.exit(0 if any(r['version'] == '$version' for r in d.get('releases', [])) else 1)" <<<"$portal"; then
        echo "$mod $version: already on the portal"
        continue
    fi

    work=$(mktemp -d)
    trap 'rm -rf "$work"' EXIT
    cp -R "$mod" "$work/${mod}_${version}"
    cp LICENSE "$work/${mod}_${version}/"
    (cd "$work" && zip -qr "${mod}_${version}.zip" "${mod}_${version}")
    zip="$work/${mod}_${version}.zip"

    if grep -q '"message"' <<<"$portal"; then
        # Portal entry does not exist yet: publish flow.
        init=$(curl -s -X POST -H "Authorization: Bearer $KEY" -F "mod=$mod" \
            https://mods.factorio.com/api/v2/mods/init_publish)
        upload_url=$(json_field "$init" "['upload_url']") || { echo "$mod: init_publish failed: $init" >&2; exit 1; }
        result=$(curl -s -X POST -F "file=@$zip" \
            -F "description=$(description "$mod")" \
            -F "category=$(category "$mod")" \
            -F "license=$LICENSE" \
            ${SOURCE_URL:+-F "source_url=$SOURCE_URL"} \
            "$upload_url")
    else
        # Portal entry exists: release upload flow.
        init=$(curl -s -X POST -H "Authorization: Bearer $KEY" -F "mod=$mod" \
            https://mods.factorio.com/api/v2/mods/releases/init_upload)
        upload_url=$(json_field "$init" "['upload_url']") || { echo "$mod: init_upload failed: $init" >&2; exit 1; }
        result=$(curl -s -X POST -F "file=@$zip" "$upload_url")
    fi

    grep -q '"success"' <<<"$result" || { echo "$mod: upload failed: $result" >&2; exit 1; }
    echo "$mod $version: published"
    rm -rf "$work"
    trap - EXIT
done
