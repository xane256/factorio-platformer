script.on_init(function()
    -- Case 1: hubless surface (simulates editor-extensions testing lab paste).
    local lab = game.create_surface("spc-test-lab")
    local c1 = lab.create_entity({ name = "hub-chest", position = { 0, 0 }, force = "player", raise_built = true })
    if c1 and c1.valid then
        log("SPCTEST: hubless chest built OK, bar=" .. tostring(c1.get_inventory(defines.inventory.chest).get_bar()))
        local inserted = c1.get_inventory(defines.inventory.chest).insert({ name = "iron-plate", count = 10 })
        log("SPCTEST: hubless chest accepted " .. inserted .. " items (want 0)")
    else
        log("SPCTEST: FAIL hubless chest not created")
    end

    -- Case 2: chest on the platform, next to the real hub.
    local psurface = storage_platform_surface()
    if psurface then
        local c2 = psurface.create_entity({ name = "hub-chest", position = { 6, 6 }, force = "player", raise_built = true })
        if c2 and c2.valid then
            local n = c2.get_inventory(defines.inventory.chest).insert({ name = "solar-panel", count = 5 })
            log("SPCTEST: platform chest built OK, seeded " .. n .. " solar panels")
            storage.c2 = c2
        else
            log("SPCTEST: FAIL platform chest not created")
        end
    else
        log("SPCTEST: FAIL no platform surface")
    end
end)

function storage_platform_surface()
    for _, s in pairs(game.surfaces) do
        if s.platform then return s end
    end
    return nil
end

script.on_nth_tick(300, function()
    if storage.c2 and storage.c2.valid then
        local left = storage.c2.get_inventory(defines.inventory.chest).get_item_count("solar-panel")
        local hub = storage.c2.surface.find_entity("space-platform-hub", { 0, 0 })
        local inhub = hub and hub.get_item_count("solar-panel") or -1
        log("SPCTEST: after 300 ticks, chest has " .. left .. " solar panels, hub has " .. inhub)
        storage.c2 = nil
    end
end)
