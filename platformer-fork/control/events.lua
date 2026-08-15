-- Cargo pods leaving a hub. A pod carrying a hub-to-hub transfer
-- (destination type "station") or a starter pack flies on. Any other pod is
-- destroyed once it clears the platform: there is no planet to receive it, so
-- it would only land as a cargo-pod-container on the shrunk planet surface.
local keep = {
    [defines.cargo_destination.station] = true,
    [defines.cargo_destination.space_platform] = true,
}

script.on_event(defines.events.on_cargo_pod_finished_ascending, function(e)
    local pod = e.cargo_pod
    if not (pod and pod.valid) then return end
    local dest = pod.cargo_pod_destination
    if dest and keep[dest.type] then return end
    pod.destroy()
end)
