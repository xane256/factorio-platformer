
script.on_init(function(e)
    storage.hub_chests = {}
    storage.global_index = 1

    -- Adopt chests placed by the upstream mod: its registry died with its
    -- storage, but the entities survive because prototype names are unchanged.
    -- Filters and wires persist on the entities; only registration is rebuilt.
    for _, surface in pairs(game.surfaces) do
        for _, chest in pairs(surface.find_entities_filtered({ name = "hub-chest" })) do
            local set = register_hub_chest(chest)
            if set.hub then
                create_wire_connection(set)
                log("space-platform-chests-fork: adopted hub-chest on " .. surface.name)
            else
                block_hubless_chest(chest)
            end
        end
    end
end)

script.on_event(
    { defines.events.on_built_entity, defines.events.on_robot_built_entity, defines.events
        .on_space_platform_built_entity, defines.events.script_raised_built },
    function(e)
        local entity = e.entity
        if not (entity and entity.valid) then
            return
        end
        if entity.name == "hub-chest" and entity.type == "container" then
            local set = register_hub_chest(entity)
            init_hub_chest_with_filters(entity)
            if set.hub then
                create_wire_connection(set)
            else
                block_hubless_chest(entity)
            end
        elseif entity.name == "space-platform-hub" then
            adopt_surface_chests(entity)
        end
    end)

-- A hub appeared (script or editor; the engine allows at most one per
-- surface). Wake every blocked chest on its surface.
function adopt_surface_chests(hub)
    for _, chest in pairs(hub.surface.find_entities_filtered({ name = "hub-chest" })) do
        if not is_registered(chest) then
            local set = { chest = chest, hub = hub }
            table.insert(storage.hub_chests, set)
            init_hub_chest_with_filters(chest)
            create_wire_connection(set)
        end
    end
end

function is_registered(chest)
    for _, set in ipairs(storage.hub_chests) do
        if set.chest.valid and set.chest == chest then
            return true
        end
    end
    return false
end

-- The hub is gone but its surface survives (script/editor removal; platform
-- death deletes the surface and takes the chests with it). Re-block the
-- orphaned chests so they act full again instead of hoarding items.
script.on_event(
    { defines.events.on_entity_died, defines.events.script_raised_destroy,
        defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity,
        defines.events.on_space_platform_mined_entity },
    function(e)
        local entity = e.entity
        if entity and entity.valid and entity.name == "space-platform-hub" then
            release_surface_chests(entity)
        end
    end)

function release_surface_chests(hub)
    for i = #storage.hub_chests, 1, -1 do
        local set = storage.hub_chests[i]
        if set.hub == hub then
            table.remove(storage.hub_chests, i)
            storage.global_index = 1
            if set.chest.valid then
                block_hubless_chest(set.chest)
            end
        end
    end
end

script.on_nth_tick(1, function(event)
    if storage.hub_chests == nil or #storage.hub_chests == 0 then
        return
    end

    local max_per_tick = 3

    if not storage.global_index then
        storage.global_index = 1
    end
    
    local chest_index = storage.global_index

    for n = 1, max_per_tick do
        local set = storage.hub_chests[chest_index]

        if not is_data_set_valid(set) then
            return
        end

        if not set.chest.get_inventory(defines.inventory.chest).is_empty() then
            teleport_items_to_hub_from_chest(set.chest, set.hub)
        end

        -- Move to next chest
        chest_index = chest_index + 1
        storage.global_index = storage.global_index + 1
        if chest_index > #storage.hub_chests then
            storage.global_index = 1
            return
        end
    end
end)

function init_hub_chest_with_filters(chest)
    local quality = chest.quality
    local inventory = chest.get_inventory(defines.inventory.chest)
    local i = 1
    for _, item in pairs(prototypes.item) do
        if item_filter(item)
        then
            inventory.set_filter(i, { name = item.name, quality = quality })
            i = i + 1
        end
    end

    inventory.set_bar(i) -- block rest of  inventory slots
    chest.operable = false
end

function item_filter(item)
    if item.type == "capsule"                   -- some ammonition
        or item.type == "item-with-entity-data" -- cars / trains
        or item.type == "rail-planner"          -- rails
    then
        return false
    end

    if item.place_result ~= nil
        or item.subgroup.name == "terrain"
        or item.place_as_tile_result ~= nil
        or item.type == "repair-tool"
        or item.type == "module"
    then
        return true
    end

    return false
end

function is_data_set_valid(set)
    if not (set.chest.valid and set.hub and set.hub.valid) then
        if set.chest.valid then
            block_hubless_chest(set.chest)
        end
        remove_set_from_storage(set)
        storage.global_index = 1 -- don't bother to handele it, just start over in next iteration
        return false
    end
    return true
end

function remove_set_from_storage(set_to_remove)
    for i, set in ipairs(storage.hub_chests) do
        if set == set_to_remove then
            table.remove(storage.hub_chests, i)
            break
        end
    end
end

function teleport_items_to_hub_from_chest(chest, hub)
    local inventory = chest.get_inventory(defines.inventory.chest)

    if not inventory.is_empty() then
        for _, item in pairs(inventory.get_contents()) do
            if hub.can_insert(item) then
                num_items = hub.insert(item)
                inventory.remove({ name = item.name, count = num_items, quality = item.quality })
            end
        end
    end
end

-- Registers the chest for hub teleport when its own surface has a hub.
-- Surfaces without a hub (labs, sandboxes) get no registration; the caller
-- blocks the chest instead, so per-tick logic only ever sees live hubs.
function register_hub_chest(chest)
    -- Surface-wide lookup, not a probe at (0,0): the engine allows one hub
    -- per surface but scripts and the editor can put it anywhere.
    local hub = chest.surface.find_entities_filtered({ name = "space-platform-hub", limit = 1 })[1]
    local set = { chest = chest, hub = hub }
    if hub then
        table.insert(storage.hub_chests, set)
    end
    return set
end

-- A hub-chest with no hub to feed acts full: bar at slot 1 blocks every
-- slot, so inserters and bots treat it exactly like a full chest.
function block_hubless_chest(chest)
    chest.get_inventory(defines.inventory.chest).set_bar(1)
end

function create_wire_connection(set)
    connect_ports(set, defines.wire_connector_id.circuit_red)
    connect_ports(set, defines.wire_connector_id.circuit_green)
end

function connect_ports(set, definition)
    chest_port = set.chest.get_wire_connector(definition, true)
    hub_port = set.hub.get_wire_connector(definition, true)
    chest_port.connect_to(hub_port, false, defines.wire_origin.script)
end
