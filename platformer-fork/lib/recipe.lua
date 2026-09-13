platformer.recipe = {}

--Both disables, hides from factoriopedia and removes it from technology unlocks
platformer.recipe.hide = function(recipe_name)
    local recipe = data.raw.recipe[recipe_name]
    recipe.enabled = false
    recipe.hidden = true
    recipe.hidden_in_factoriopedia = true
    platformer.technology.remove_everywhere(recipe_name)
end

platformer.recipe.hide_many = function (recipes) 
    for _, recipe in ipairs(recipes) do 
        platformer.recipe.hide(recipe) 
    end 
end
-- Replace a recycling recipe's results. The results are written per one
-- recycled item. If another mod already scaled the recipe's input (Quality
-- Science Patch runs scrap recycling at 16 scrap per craft), the results
-- scale to match, so the batch size survives whichever mod loads last.
platformer.recipe.set_recycling_results = function(recipe_name, results)
    local recipe = data.raw.recipe[recipe_name]
    local batch = recipe.ingredients[1].amount or 1
    for _, result in ipairs(results) do
        local total = ((result.amount or 1) + (result.extra_count_fraction or 0)) * batch
        result.amount = math.floor(total)
        local fraction = total - result.amount
        if fraction > 0.000001 then
            result.extra_count_fraction = fraction
        else
            result.extra_count_fraction = nil
        end
    end
    recipe.results = results
end
