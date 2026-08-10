data:extend({
    {
        type = "tips-and-tricks-item-category",
        name = "space-hub-chest",
        order = "space-hub-chest-a"
    },
    {
        type= "tips-and-tricks-item",
        category = "space-hub-chest",
        name = "space-hub-chest-intro",
        indent = 0,
        order = "space-hub-chest-b",
        starting_status = "unlocked",
        tag = "[entity=hub-chest]",
        is_title = true,
        trigger = {
          type = "research",
          technology = "hub-chest"
        },
        simulation = {
            mods = {"space-platform-chests"},
            init =
            [[
                player = game.simulation.create_test_player{name = "Spaceman"}
                storage.platform = player.force.create_space_platform({name="platform", planet="nauvis", starter_pack="space-platform-starter-pack"})
                storage.hub = storage.platform.apply_starter_pack()
                player.teleport({0, 0}, game.surfaces[2])
                game.simulation.camera_player = player
                game.simulation.camera_position = {-5, -2}
                game.simulation.camera_zoom = 1.6
                game.simulation.hide_cursor = true
                game.simulation.camera_alt_info = true

                for _, tech in pairs(game.forces["player"].technologies) do
                    tech.researched = true
                end

                game.surfaces[2].create_entities_from_blueprint_string
                {
                  string = "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",
                  position = {0, 0}
                }

                local bp_string = "0eNql1eFqwyAQB/B3uc+mNDHamlcpo9jWDsFoUDNagu8+kw7KyCCO+5aE+/803pFMcDGjGry2EboJ9NXZAN1pgqA/rTTzMyt7BR0EZ6SvBmmVgURA25t6QFenDwLKRh21egWXm+fZjv1F+VxA/gIIDC7kjLPzCtmp6mbHCDzzFduxlMgKagohseHQQodvOG2hQzccVujsNxxe5vw+5ty8qM1P51YtaV+VPL3pQV5VNRgZ78731d2N9iaXzLyjFUCxQIMFaiywRwICmT8i8wdkniPzDJnHziB2BNETiMsjxw+5OvLl/3X2+VOko+pz0fuPROBL+bCAjDeiFYIxejxQQVP6BgwbOpQ="
                local stack = game.create_inventory(1)[1]
                stack.import_stack(bp_string)
                local ghosts = stack.build_blueprint
                {
                    surface = game.surfaces[2],
                    force = game.forces.player,
                    position = {-5,-6},
                    build_mode = defines.build_mode.forced,
                    direction = defines.direction.north,
                    skip_fog_of_war = false
                }
                
                game.surfaces[2].create_entity{name = "hub-chest", position = {-13, -3}, force = "player", raise_built=true}
            ]]
        }
    },
    {
        type= "tips-and-tricks-item",
        category = "space-hub-chest",
        name = "space-hub-chest-circuit",
        indent = 1,
        order = "space-hub-chest-c",
        starting_status = "unlocked",
        image = "__space-platform-chests-fork__/graphics/tips-and-tricks-wire-connection.png",
        trigger = {
          type = "research",
          technology = "hub-chest"
        }
    },
    {
        type= "tips-and-tricks-item",
        category = "space-hub-chest",
        name = "space-hub-chest-quality",
        indent = 1,
        order = "space-hub-chest-d",
        starting_status = "unlocked",
        trigger = {
          type = "research",
          technology = "hub-chest"
        },
        simulation = {
            mods = {"space-platform-chests"},
            init = 
            [[
                player = game.simulation.create_test_player{name = "Spaceman"}
                storage.platform = player.force.create_space_platform({name="platform", planet="nauvis", starter_pack="space-platform-starter-pack"})
                storage.hub = storage.platform.apply_starter_pack()
                player.teleport({0, 0}, game.surfaces[2])
                game.simulation.camera_player = player
                game.simulation.camera_position = {-5, -2}
                game.simulation.camera_zoom = 1.6
                game.simulation.hide_cursor = true
                game.simulation.camera_alt_info = true

                for _, tech in pairs(game.forces["player"].technologies) do
                    tech.researched = true
                end

                game.surfaces[2].create_entities_from_blueprint_string
                {
                  string = "0eNq93O1O2zAUgOF78e8U+ZuGW5mmKLQus5SPzknQGOq9z2mgsMGmlldjvxiJ7ebUPBz5nPIobpsp7FPsRnHzKOKm7wZx8+VRDPGuq5v5e13dBnEjhn29Cat9U4+7PrWrb9OtOBQidtvwQ9yow9dChG6MYwzL+ON/Hqpuam9DyjcUz/PEbhe7fGm1+RaGURRi3w95WN/Na+WpVusrV4iH/IW9cscVlvurIYxj7O6G+b4U2v4+VFO+1owhhW0Vx9DmS7u6GUIhlm8vr+T59fdNnVb7ugtNXnTTT/MTO1mItt/O1+tx1YT6+IpeHupwKN48in71KENIeZ13HqL8/SG2MYXNct2+M6X5QHT0f4zO96lu8qT5+1O36ds2L49CZi8KmT4nZO4DIZOfErJUp8DC5S8KlzwnXNeXh0t9IFpjmi4LVtjHDQvW+pJgqXNiVRb/MO/N3PI4sczTpvB9yiGtTo+fFV3WWUJxeo7i9HW2pM533IenjTYzepom9W11O+12x7nmyL5ao43DkN+NavY6XzquUrV1XjfmeZ5vf8uwvHwfmM/YB024C922Tg9sMyh1yW4w5+wG9eJ9aPKNKW5WoQvp7mGVf2mGtMtb5J01lhXKPP/yFlZD/BnmN+D0b36vx9g8/b78c7yyy0/39eFvu3GXw7Stj2Pml/1mAkMn0HQCRSeQcIISjl/D8ddwvIfjHRxP9yDdgngHsvFw+8HV4cPD2GN+nibw1C9P/fLUL0/98tAvD/3y0C8P/fLQLw/98tAvD/3y0C/P/PLML8/88swvz/zy1C9H/XLUL0f9ctQvB/1y0C8H/XLQLwf9ctAvB/1y0C8H/XLML8f8cswvx/xyzC9H/bLUL0v9stQvS/2y0C8L/bLQLwv9stAvC/2y0C8L/bLQL8v8sswvy/yyzC/L/LLUL0P9MtQvQ/0y1C8D/TLQLwP9MtAvA/0y0C8D/TLQLwP9Mswvw/wyzC/D/DLML0P90tQvTf3S1C9N/dLQLw390tAvDf3S0C8N/dLQLw390tAvzfzSzC/N/NLML8380tQvRf1S1C9F/VLULwX9UtAvBf1S0C8F/VLQLwX9UtAvBf1SzC/F/FLML8X8UswvBf2SkC8J9ZIQLwntkowuyeSSDC7J3JKMLcnUkgwtycySjCyJxJIILIm8kogribSSECuaa9FUi2ZaNNGCeRZMs2CWBZMsmGPBFAtmWDDBgvkVS69YdsWSK5ZbsdSKZlb0YIuea9FjLXqqBQ+14JkWPNKCJ1rwQAueZ8HjLHiaBQ+z2FkWO8piJ1nsIIudY9FjLFpFpEVEWkOkJURYQYQFRFg/hOVDWD2ExUNYO4SlQ1g5ZIVDVjdkZUNWNWRFQ1ozpC1btGOLNmzRfi3YrgW7tWCzFuzVgq1asFMLNmrBPi3YpsW6tFiTFuvRYi1arEOLNmjR/njaHk+742lzPOyNh63xsDMeNsbDvnjYFg+74mFTPOyJZy3xrCOeNcSzfnjWDg/3K/wcGvwYHPwUL/wQ8Zqtvmarl2z184Z/LcT85wfyTS9/06YQ9yENxwmd16UtS+fM+tqU5nD4BQM57QQ=",
                  position = {0, 0}
                }

                game.surfaces[2].create_entity{name = "hub-chest", position = {-11, -5}, force = "player", raise_built=true, quality = "normal"}
                game.surfaces[2].create_entity{name = "hub-chest", position = {-11, -3}, force = "player", raise_built=true, quality = "uncommon"}
                game.surfaces[2].create_entity{name = "hub-chest", position = {-11, -1}, force = "player", raise_built=true, quality = "rare"}
                game.surfaces[2].create_entity{name = "hub-chest", position = {-11, 1}, force = "player", raise_built=true, quality = "epic"}
                game.surfaces[2].create_entity{name = "hub-chest", position = {-11, 3}, force = "player", raise_built=true, quality = "legendary"}
            ]]
        }
    }
})