-- Hub unloading bay lifecycle. Each bay owns one hidden proxy container on
-- its outer row, targeted at the hub's main inventory. Registry:
-- storage.hub_bays[bay.unit_number] = proxy. No per-tick work; the engine
-- forwards every inserter interaction with the proxy to the hub.
-- control.lua calls these from its event handlers.
local M = {}
local BAY = "hub-unloading-bay"
local NS = "hub-unloading-bay-proxy-ns"
local EW = "hub-unloading-bay-proxy-ew"

-- The outer row is the one tile of the bay's footprint past the 4x4
-- connectable square, on the side the bay faces.
local function proxy_placement(bay)
    local box = bay.bounding_box
    local cx = (box.left_top.x + box.right_bottom.x) / 2
    local cy = (box.left_top.y + box.right_bottom.y) / 2
    local d = bay.direction
    if d == defines.direction.north then
        return NS, { cx, math.floor(box.left_top.y) + 0.5 }
    elseif d == defines.direction.south then
        return NS, { cx, math.ceil(box.right_bottom.y) - 0.5 }
    elseif d == defines.direction.east then
        return EW, { math.ceil(box.right_bottom.x) - 0.5, cy }
    else
        return EW, { math.floor(box.left_top.x) + 0.5, cy }
    end
end

local function surface_hub(surface)
    return surface.find_entities_filtered({ name = "space-platform-hub", limit = 1 })[1]
end

function M.attach_proxy(bay)
    storage.hub_bays = storage.hub_bays or {}
    local name, position = proxy_placement(bay)
    local proxy = bay.surface.create_entity({ name = name, position = position, force = bay.force })
    proxy.destructible = false
    local hub = surface_hub(bay.surface)
    if hub then
        proxy.proxy_target_entity = hub
        proxy.proxy_target_inventory = defines.inventory.hub_main
    end
    storage.hub_bays[bay.unit_number] = proxy
    return proxy
end

function M.detach_proxy(bay)
    local proxy = storage.hub_bays and storage.hub_bays[bay.unit_number]
    if proxy and proxy.valid then
        proxy.destroy()
    end
    if storage.hub_bays then
        storage.hub_bays[bay.unit_number] = nil
    end
end

-- A hub appeared on the surface: point every bay's proxy at it.
function M.retarget_surface_bays(hub)
    for _, bay in pairs(hub.surface.find_entities_filtered({ name = BAY })) do
        local proxy = storage.hub_bays and storage.hub_bays[bay.unit_number]
        if proxy and proxy.valid then
            proxy.proxy_target_entity = hub
            proxy.proxy_target_inventory = defines.inventory.hub_main
        end
    end
end

-- Bays without a live proxy: saves from before this feature, or bays the
-- migration converted from the vanilla landing-pad unloading bay.
function M.adopt_bays()
    storage.hub_bays = storage.hub_bays or {}
    for _, surface in pairs(game.surfaces) do
        for _, bay in pairs(surface.find_entities_filtered({ name = BAY })) do
            local proxy = storage.hub_bays[bay.unit_number]
            if not (proxy and proxy.valid) then
                M.attach_proxy(bay)
            end
        end
    end
end

M.BAY = BAY
return M
