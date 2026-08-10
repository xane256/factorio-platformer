require("__platformer-fork__/data/technologies/disabled-technologies.lua")
require("__platformer-fork__/data/technologies/modified-technologies.lua")
require("__platformer-fork__/data/technologies/new-technologies.lua")

-- Enable selected technologies
data.raw.technology["space-platform"].enabled = true;
platformer.technology.prune_all()
