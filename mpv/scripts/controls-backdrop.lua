-- Streaming-app style chrome around uosc: a soft shadow behind the top bar and
-- controls while they're visible, and subtitles lifted above the controls.

local base_sub_margin = mp.get_property_number("sub-margin-y", 22)
local scrim = mp.create_osd_overlay("ass-events")
scrim.z = -10 -- below uosc
local margins = { t = 0, b = 0 }

-- A heavily blurred rectangle reads as a smooth vertical gradient without banding.
local function shade(y0, y1, w, alpha, blur)
    return string.format(
        "{\\an7\\pos(0,0)\\bord0\\shad0\\blur%d\\1c&H000000&\\1a&H%02X&\\p1}m %d %d l %d %d %d %d %d %d{\\p0}",
        blur, alpha, -blur * 2, y0, w + blur * 2, y0, w + blur * 2, y1, -blur * 2, y1)
end

local function render()
    local dims = mp.get_property_native("osd-dimensions")
    if not dims or dims.h == 0 then return end
    local w, h = math.floor(720 * dims.w / dims.h), 720
    local events = {}

    if margins.b > 0 then
        local height = margins.b * h
        events[#events + 1] = shade(h - height * 1.6, h + 80, w, 0x48, math.floor(height * 0.9))
    end
    if margins.t > 0 then
        local height = margins.t * h
        events[#events + 1] = shade(-80, height * 1.2, w, 0x70, math.floor(height * 0.9))
    end

    if #events == 0 then
        scrim:remove()
        return
    end
    scrim.res_x, scrim.res_y = w, h
    scrim.data = table.concat(events, "\n")
    scrim:update()
end

mp.observe_property("user-data/osc/margins", "native", function(_, value)
    margins = { t = value and value.t or 0, b = value and value.b or 0 }
    mp.set_property_number("sub-margin-y", base_sub_margin + math.floor(margins.b * 720))
    render()
end)
mp.observe_property("osd-dimensions", "native", render)
