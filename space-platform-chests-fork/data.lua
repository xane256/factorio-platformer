require("__space-platform-chests-fork__/tips-and-tricks.lua")


local item_name = "hub-chest"
local graphics = "__space-platform-chests-fork__/graphics"
local global_inventory_size = 10000

-- Entity
local entity = table.deepcopy(data.raw["container"]["steel-chest"])
entity.name = item_name
entity.inventory_size = global_inventory_size
entity.inventory_type = "with_filters_and_bar"
entity.minable.result = "hub-chest"
entity.icon = graphics .. "/icon/voidchest.png"
entity.icon_size = 64
entity.surface_conditions = { { min = 0, max = 0, property = "gravity" } }
entity.open_sound = nil
entity.fast_replaceable_group = "hub chest"
entity.picture =
{
    layers =
    {
        {
            filename = graphics .. "/hr-voidchest.png",
            priority = "extra-high",
            width = 66,
            height = 74,
            shift = util.by_pixel(0, -2),
            scale = 0.5
        },
        {
            filename = graphics .. "/hr-voidchest-shadow.png",
            priority = "extra-high",
            width = 112,
            height = 46,
            shift = util.by_pixel(12, 4.5),
            draw_as_shadow = true,
            scale = 0.5
        }
    }
}

-- Item
local item = table.deepcopy(data.raw["item"]["steel-chest"])
item.icon = graphics .. "/icon/voidchest.png"
item.name = item_name
item.place_result = "hub-chest"

-- Recipe
local recipe = table.deepcopy(data.raw.recipe["steel-chest"])
recipe.name = item_name
recipe.results = {
    { type = "item", name = item_name, amount = 1 }
}
recipe.ingredients = {
    { type = "item", name = "steel-chest",        amount = 1 },
    { type = "item", name = "electronic-circuit", amount = 1 }
}
recipe.allow_quality = true

-- Technology
local technology = table.deepcopy(data.raw.technology["steel-processing"])
technology.name = item_name
technology.effects = {
    {
        type   = "unlock-recipe",
        recipe = item_name
    }
}
technology.prerequisites = { "steel-processing" };
technology.icon = graphics .. "/hr-voidchest-technology.png"
technology.icon_size = 256
technology.unit =
{
    count_formula = "100",
    ingredients =
    {
        { "automation-science-pack", 1 },
        { "logistic-science-pack",   1 },
    },
    time = 30
}


data:extend { entity, item, recipe, technology }