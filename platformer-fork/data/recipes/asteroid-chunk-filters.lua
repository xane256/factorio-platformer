-- Item selection lists (inserter filters, logistic requests) only offer items
-- that some enabled recipe produces, and no recipe produces an asteroid chunk.
-- Each chunk's self-recycling recipe (chunk to 25% chunk) is a producer
-- already, so it carries the unlock: at game start for the chunks Nauvis orbit
-- spawns, at planet discovery for the rest. The recipe itself stays hidden.
-- Runs in data-updates because the recycler generates the vanilla chunks'
-- recycling recipes in its own data-updates.
local function unlock_chunk_in_selection(chunk, technology_name)
    local recipe = data.raw.recipe[chunk .. "-recycling"]
    recipe.unlock_results = true
    -- Defaults to `hidden`, and the chunk is its own only ingredient.
    recipe.requires_ingredients_to_unlock_results = false
    if technology_name then
        recipe.enabled = false
        table.insert(data.raw.technology[technology_name].effects,
            { type = "unlock-recipe", recipe = recipe.name, hidden = true })
    else
        recipe.enabled = true
    end
end

unlock_chunk_in_selection("metallic-asteroid-chunk")
unlock_chunk_in_selection("crudeic-asteroid-chunk")
unlock_chunk_in_selection("oxide-asteroid-chunk")
unlock_chunk_in_selection("vulcanus-asteroid-chunk", "planet-discovery-vulcanus")
unlock_chunk_in_selection("fulgora-asteroid-chunk", "planet-discovery-fulgora")
unlock_chunk_in_selection("gleba-asteroid-chunk", "planet-discovery-gleba")
unlock_chunk_in_selection("aquilo-asteroid-chunk", "planet-discovery-aquilo")
