-- Night mode: dynamic range compression so dialogue is audible without loud explosions.
-- Publishes `night_mode` to uosc so its control-bar button shows the current state.

local enabled = false

local function set(on)
    if on == enabled then return end
    enabled = on
    if on then
        mp.commandv("af", "add", "@night:lavfi=[dynaudnorm=f=150:g=15]")
    else
        mp.commandv("af", "remove", "@night")
    end
    mp.commandv("script-message", "set", "night_mode", on and "yes" or "no")
    mp.osd_message("Night mode " .. (on and "on" or "off"))
end

mp.add_key_binding(nil, "toggle", function() set(not enabled) end)
mp.register_script_message("set", function(prop, value)
    if prop == "night_mode" then set(value == "yes") end
end)
