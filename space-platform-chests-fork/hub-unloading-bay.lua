-- Hub unloading bay: a cargo bay whose outer row carries a hidden proxy
-- container pointed at the hub's main inventory. Inserters on that row read
-- and write the hub directly. The bay itself must not allow unloading: an
-- unloading-capable bay captures the inserter's pickup target and starves it.
local graphics = "__space-platform-chests-fork__/graphics"

local bay = table.deepcopy(data.raw["cargo-bay"]["landing-pad-unloading-bay"])
bay.name = "hub-unloading-bay"
bay.minable.result = "hub-unloading-bay"
bay.allow_unloading = false
bay.use_unloading_distance_limit = nil
bay.surface_conditions = { { property = "gravity", min = 0, max = 0 } }
bay.platform_graphics_set = table.deepcopy(bay.graphics_set)
bay.platform_graphics_set.water_reflection = nil
bay.platform_graphics_set.connections = require("__space-age__.graphics.entity.cargo-hubs.connections.platform-connections")

-- One proxy per bay, sized to the extractor row. Two shapes because the
-- proxy has no direction of its own.
local function proxy(name, box)
    return {
        type = "proxy-container",
        name = name,
        hidden = true,
        flags = { "placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable",
            "not-upgradable", "not-rotatable", "not-repairable", "not-in-kill-statistics", "no-copy-paste" },
        collision_box = box,
        selection_box = box,
        collision_mask = { layers = {} },
        selectable_in_game = false,
        allow_copy_paste = false,
        max_health = 1,
        draw_inventory_content = false,
    }
end

local item = table.deepcopy(data.raw["item"]["landing-pad-unloading-bay"])
item.name = "hub-unloading-bay"
item.place_result = "hub-unloading-bay"
item.order = "c[hub-unloading-bay]"

local recipe = table.deepcopy(data.raw["recipe"]["landing-pad-unloading-bay"])
recipe.name = "hub-unloading-bay"
recipe.results = { { type = "item", name = "hub-unloading-bay", amount = 1 } }

local technology = table.deepcopy(data.raw["technology"]["landing-pad-unloading-bay"])
technology.name = "hub-unloading-bay"
technology.effects = { { type = "unlock-recipe", recipe = "hub-unloading-bay" } }
technology.prerequisites = { "space-science-pack" }

data:extend({
    bay,
    proxy("hub-unloading-bay-proxy-ns", { { -1.9, -0.4 }, { 1.9, 0.4 } }),
    proxy("hub-unloading-bay-proxy-ew", { { -0.4, -1.9 }, { 0.4, 1.9 } }),
    item,
    recipe,
    technology,
})
