-- Platformer has no planets, so the vanilla starter-pack delivery (a rocket
-- silo on the chosen planet) can never happen. The native "+ Add Space
-- Platform" UI still drives creation; a platform waiting for its pack is
-- instead fulfilled from any hub on its force that holds the requested pack
-- at the requested quality. Scan cadence is once a second, and only
-- platforms in the waiting state do any work.

local waiting = defines.space_platform_state.waiting_for_starter_pack

local function requested_pack(platform)
    local pack = platform.starter_pack
    if not pack then
        return { name = "space-platform-starter-pack", quality = "normal" }
    end
    local name = pack.name
    if type(name) ~= "string" then name = name.name end
    local quality = pack.quality or "normal"
    if type(quality) ~= "string" then quality = quality.name end
    return { name = name, quality = quality }
end

local function try_fulfill(platform)
    local pack = requested_pack(platform)
    for _, donor in pairs(platform.force.platforms) do
        local hub = donor.hub
        if hub and hub.valid and hub.get_item_count(pack) > 0 then
            hub.remove_item({ name = pack.name, quality = pack.quality, count = 1 })
            platform.apply_starter_pack()
            return
        end
    end
end

script.on_nth_tick(60, function()
    for _, force in pairs(game.forces) do
        for _, platform in pairs(force.platforms) do
            if platform.valid and platform.state == waiting then
                try_fulfill(platform)
            end
        end
    end
end)
