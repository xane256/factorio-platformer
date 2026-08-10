-- Additional platforms. Platformer has no planets to launch starter packs
-- from, so the vanilla create-platform flow is unreachable; instead the
-- toolbar shortcut consumes a starter pack from the current platform's hub
-- and creates a sibling platform in the same orbit. The result is an
-- ordinary platform: native 2.1 platform-to-platform transfers apply.

-- Returns the new platform, or nil and a locale key explaining why not.
function create_sibling_platform(force, platform)
    local location = platform.space_location
    if not location or location.type ~= "planet" then
        return nil, "platformer.new-platform-not-in-orbit"
    end

    local hub = platform.hub
    if not (hub and hub.valid) or hub.get_item_count("space-platform-starter-pack") == 0 then
        return nil, "platformer.new-platform-no-starter-pack"
    end

    local count = 0
    for _ in pairs(force.platforms) do count = count + 1 end
    local sibling = force.create_space_platform({
        name = "Base " .. (count + 1),
        planet = location.name,
        starter_pack = "space-platform-starter-pack",
    })
    if not sibling then
        return nil, "platformer.new-platform-failed"
    end

    hub.remove_item({ name = "space-platform-starter-pack", count = 1 })
    sibling.apply_starter_pack()
    return sibling
end

script.on_event(defines.events.on_lua_shortcut, function(e)
    if e.prototype_name ~= "platformer-new-platform" then
        return
    end
    local player = game.players[e.player_index]
    local platform = player.surface.platform
    if not platform then
        player.print({ "platformer.new-platform-need-platform" })
        return
    end
    local sibling, why_not = create_sibling_platform(player.force, platform)
    if sibling then
        player.print({ "platformer.new-platform-created", sibling.name })
    else
        player.print({ why_not })
    end
end)

remote.add_interface("platformer", {
    -- remote.call("platformer", "new_platform", force, platform) -> LuaSpacePlatform?
    new_platform = function(force, platform)
        return create_sibling_platform(force, platform)
    end,
})
