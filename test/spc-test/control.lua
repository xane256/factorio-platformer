-- Headless regression harness. Read SPCTEST lines in the log.
script.on_init(function()
    -- Case 1: hubless surface (simulates editor-extensions testing lab paste).
    local lab = game.create_surface("spc-test-lab")
    lab.request_to_generate_chunks({ 0, 0 }, 3)
    lab.force_generate_chunk_requests()
    local c1 = lab.create_entity({ name = "hub-chest", position = { 0, 0 }, force = "player", raise_built = true })
    if c1 and c1.valid then
        log("SPCTEST: hubless chest built OK, bar=" .. tostring(c1.get_inventory(defines.inventory.chest).get_bar()) .. " (want 1)")
        local inserted = c1.get_inventory(defines.inventory.chest).insert({ name = "solar-panel", count = 10 })
        log("SPCTEST: hubless chest accepted " .. inserted .. " items (want 0)")
        storage.lab_chest = c1
    else
        log("SPCTEST: FAIL hubless chest not created")
    end

    -- Case 2: chest on the platform, next to the real hub.
    for _, s in pairs(game.surfaces) do
        if s.platform then
            local c2 = s.create_entity({ name = "hub-chest", position = { 6, 6 }, force = "player", raise_built = true })
            if c2 and c2.valid then
                local n = c2.get_inventory(defines.inventory.chest).insert({ name = "solar-panel", count = 5 })
                log("SPCTEST: platform chest built OK, seeded " .. n .. " solar panels")
                storage.platform_chest = c2
            else
                log("SPCTEST: FAIL platform chest not created")
            end
            break
        end
    end

    storage.stage = 0
end)

script.on_nth_tick(120, function()
    local lab = game.get_surface("spc-test-lab")
    local chest = storage.lab_chest
    if not (lab and chest and chest.valid) then return end
    local inv = chest.get_inventory(defines.inventory.chest)

    if storage.stage == 0 then
        -- Platform teleport check, then: hub appears on the lab, off-origin.
        if storage.platform_chest and storage.platform_chest.valid then
            local left = storage.platform_chest.get_inventory(defines.inventory.chest).get_item_count("solar-panel")
            log("SPCTEST: platform chest has " .. left .. " solar panels left (want 0)")
        end
        local hub = lab.create_entity({ name = "space-platform-hub", position = { 32, 32 }, force = "player", raise_built = true })
        if hub and hub.valid then
            log("SPCTEST: lab hub placed at (32,32), chest bar=" .. tostring(inv.get_bar()) .. " (want >1: unblocked)")
            log("SPCTEST: lab chest accepted " .. inv.insert({ name = "solar-panel", count = 7 }) .. " items (want 7)")
            storage.lab_hub = hub
        else
            log("SPCTEST: lab hub creation refused by engine (expected on 2.1)")
        end
        storage.stage = 1
    elseif storage.stage == 1 then
        if not (storage.lab_hub and storage.lab_hub.valid) then
            log("SPCTEST: skipping hub-lifecycle stages, no lab hub")
            storage.stage = 2
            return
        end
        local inhub = storage.lab_hub.get_item_count("solar-panel")
        log("SPCTEST: lab hub has " .. inhub .. " solar panels (want 7), chest has " .. inv.get_item_count("solar-panel") .. " (want 0)")
        storage.lab_hub.destroy({ raise_destroy = true })
        log("SPCTEST: lab hub destroyed, chest bar=" .. tostring(inv.get_bar()) .. " (want 1: re-blocked)")
        log("SPCTEST: re-blocked chest accepted " .. inv.insert({ name = "solar-panel", count = 3 }) .. " items (want 0)")
        storage.stage = 2
    elseif storage.stage == 5 then
        -- Destroy the real platform hub: does the engine keep the surface?
        local pc = storage.platform_chest
        if pc and pc.valid then
            local hub = pc.surface.find_entities_filtered({ name = "space-platform-hub", limit = 1 })[1]
            if hub then
                local sname = pc.surface.name
                hub.destroy({ raise_destroy = true })
                local surf = game.get_surface(sname)
                log("SPCTEST: platform hub destroyed; surface alive=" .. tostring(surf ~= nil) ..
                    " chest valid=" .. tostring(pc.valid) ..
                    (pc.valid and (" bar=" .. tostring(pc.get_inventory(defines.inventory.chest).get_bar()) .. " (want 1)") or ""))
            else
                log("SPCTEST: no platform hub found to destroy")
            end
        end
        storage.stage = 6
    elseif storage.stage == 2 then
        -- Create a platform in waiting_for_starter_pack (the native + button
        -- flow); the mod's scan should fulfill it from Base One's hub.
        local force = game.forces.player
        local base = nil
        for _, pl in pairs(force.platforms) do base = pl break end
        if base and base.hub then
            base.hub.insert({ name = "space-platform-starter-pack", count = 1 })
            local sibling = force.create_space_platform({ name = "Base 2", planet = "nauvis", starter_pack = "space-platform-starter-pack" })
            log("SPCTEST: sibling created, state=" .. sibling.state .. " (want " .. defines.space_platform_state.waiting_for_starter_pack .. ": waiting)")
            storage.sibling = sibling
        else
            log("SPCTEST: skipping sibling stage, no base platform hub")
        end
        storage.stage = 3
    elseif storage.stage == 3 then
        -- 120 ticks later the scan (60-tick cadence) must have fulfilled it.
        local sib = storage.sibling
        local force = game.forces.player
        local base = nil
        for _, pl in pairs(force.platforms) do base = pl break end
        if sib and sib.valid then
            log("SPCTEST: sibling state=" .. sib.state .. " (want not " .. defines.space_platform_state.waiting_for_starter_pack ..
                "), hub=" .. tostring(sib.hub ~= nil) .. " (want true), packs left in old hub: " ..
                base.hub.get_item_count("space-platform-starter-pack") .. " (want 0)")
            if sib.hub then
                local c = sib.hub.surface.create_entity({ name = "hub-chest", position = { 6, 6 }, force = "player", raise_built = true })
                if c and c.valid then
                    local n = c.get_inventory(defines.inventory.chest).insert({ name = "solar-panel", count = 4 })
                    log("SPCTEST: sibling chest built, seeded " .. n .. " solar panels")
                    storage.sibling_chest = c
                end
            end
        end
        storage.stage = 4
    elseif storage.stage == 4 then
        local c = storage.sibling_chest
        if c and c.valid then
            local left = c.get_inventory(defines.inventory.chest).get_item_count("solar-panel")
            local inhub = storage.sibling.hub.get_item_count("solar-panel")
            log("SPCTEST: sibling chest has " .. left .. " (want 0), sibling hub has " .. inhub .. " solar panels (want 4)")
        end
        storage.stage = 5
    end
end)
