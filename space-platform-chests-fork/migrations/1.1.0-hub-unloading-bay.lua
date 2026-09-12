-- Vanilla landing-pad unloading bays on platforms never worked with the hub.
-- Replace each with a hub unloading bay in place; on_configuration_changed
-- attaches the proxies afterwards.
for _, surface in pairs(game.surfaces) do
    if surface.platform then
        for _, old in pairs(surface.find_entities_filtered({ name = "landing-pad-unloading-bay" })) do
            local spec = { name = "hub-unloading-bay", position = old.position, direction = old.direction,
                force = old.force, quality = old.quality, raise_built = true }
            old.destroy()
            surface.create_entity(spec)
        end
    end
end
