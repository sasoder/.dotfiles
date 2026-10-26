-- Night mode: dynamic range compression so dialogue is audible without loud explosions.

local enabled = false

mp.add_key_binding(nil, "toggle", function()
    enabled = not enabled
    if enabled then
        mp.commandv("af", "add", "@night:lavfi=[dynaudnorm=f=150:g=15]")
    else
        mp.commandv("af", "remove", "@night")
    end
    mp.osd_message("Night mode " .. (enabled and "on" or "off"))
end)
