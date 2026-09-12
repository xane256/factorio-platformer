-- Headless regression harness for the hub unloading bay. Read BAYTEST lines.
local BAY = "hub-unloading-bay"
local D = defines.direction

local function tname(t) return t and t.valid and (t.name .. "@" .. t.position.x .. "," .. t.position.y) or "nil" end
local function fmt_box(b) return string.format("[%.1f,%.1f..%.1f,%.1f]", b.left_top.x, b.left_top.y, b.right_bottom.x, b.right_bottom.y) end

local function proxy_of(bay)
    return bay.surface.find_entities_filtered({ name = { "hub-unloading-bay-proxy-ns", "hub-unloading-bay-proxy-ew" }, area = bay.bounding_box })[1]
end

script.on_init(function()
    game.forces.player.technologies["hub-unloading-bay"].researched = true
    log("BAYTEST: vanilla bay item hidden=" .. tostring(prototypes.item["landing-pad-unloading-bay"].hidden) ..
        " recipe hidden=" .. tostring(prototypes.recipe["landing-pad-unloading-bay"].hidden) ..
        " tech enabled=" .. tostring(prototypes.technology["landing-pad-unloading-bay"].enabled) .. " (want true true false)")

    local s
    for _, surface in pairs(game.surfaces) do
        if surface.platform and surface.platform.hub then s = surface break end
    end
    local hub = s.platform.hub
    hub.insert({ name = "copper-plate", count = 100 })

    -- One bay per side; each proxy must sit inside its bay, on the outer row.
    local sides = {
        { dir = D.north, pos = { 0, -6 } }, { dir = D.east, pos = { 6, 0 } },
        { dir = D.south, pos = { 0, 6 } }, { dir = D.west, pos = { -6, 0 } },
    }
    storage.bays = {}
    for _, side in ipairs(sides) do
        local bay = s.create_entity({ name = BAY, position = side.pos, direction = side.dir, force = "player", raise_built = true })
        local proxy = proxy_of(bay)
        log("BAYTEST: bay dir=" .. side.dir .. " bbox=" .. fmt_box(bay.bounding_box) ..
            " proxy=" .. tname(proxy) .. (proxy and (" pbox=" .. fmt_box(proxy.bounding_box) .. " target=" .. tname(proxy.proxy_target_entity) .. " inv=" .. tostring(proxy.proxy_target_inventory)) or "") ..
            " (want proxy on the outer row, target hub, inv " .. defines.inventory.hub_main .. ")")
        storage.bays[side.dir] = bay
    end

    -- North bay: an unloading inserter on the west half of the row, a loading
    -- inserter on the east half.
    local ins = s.create_entity({ name = "burner-inserter", position = { -1.5, -9.5 }, direction = D.south, force = "player", raise_built = true })
    ins.insert({ name = "coal", count = 5 })
    ins.use_filters = true
    ins.set_filter(1, { name = "copper-plate" })
    storage.out = s.create_entity({ name = "iron-chest", position = { -1.5, -10.5 }, force = "player" })
    storage.src = s.create_entity({ name = "iron-chest", position = { 1.5, -10.5 }, force = "player" })
    storage.src.insert({ name = "stone", count = 30 })
    local ins2 = s.create_entity({ name = "burner-inserter", position = { 1.5, -9.5 }, direction = D.north, force = "player", raise_built = true })
    ins2.insert({ name = "coal", count = 5 })
    storage.hub = hub
    storage.stage = 0

    -- Hubless surface: the bay must build and get a proxy with no target.
    local lab = game.create_surface("bay-test-lab")
    lab.request_to_generate_chunks({ 0, 0 }, 3)
    lab.force_generate_chunk_requests()
    local lab_bay = lab.create_entity({ name = BAY, position = { 0, 0 }, direction = D.north, force = "player", raise_built = true })
    local lab_proxy = lab_bay and proxy_of(lab_bay)
    log("BAYTEST: hubless bay proxy=" .. tname(lab_proxy) .. " target=" .. tname(lab_proxy and lab_proxy.proxy_target_entity) .. " (want a proxy, target nil)")
end)

script.on_nth_tick(300, function(e)
    if not storage.hub or e.tick == 0 then return end
    if storage.stage == 0 then
        log("BAYTEST t=" .. e.tick .. ": out copper=" .. storage.out.get_item_count("copper-plate") .. " (want >0), hub copper=" .. storage.hub.get_item_count("copper-plate") ..
            " (want <100), hub stone=" .. storage.hub.get_item_count("stone") .. " (want >0), src stone=" .. storage.src.get_item_count("stone") .. " (want <30)")
        storage.stage = 1
    elseif storage.stage == 1 then
        -- Mining the east bay must take its proxy with it.
        local bay = storage.bays[D.east]
        local proxy = proxy_of(bay)
        bay.destroy({ raise_destroy = true })
        log("BAYTEST t=" .. e.tick .. ": east bay removed, proxy valid=" .. tostring(proxy and proxy.valid) .. " (want false)")
        storage.stage = 2
    end
end)
