platformer = {}

platformer.helpers = {}
platformer.helpers.tablelength = function(T)
    local count = 0
    if T ~= nil then
        for _ in pairs(T) do count = count + 1 end
    end
    return count
end

require("__platformer-fork__/lib/recipe.lua")
require("__platformer-fork__/lib/technology.lua")