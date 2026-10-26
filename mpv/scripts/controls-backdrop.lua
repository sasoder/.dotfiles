-- Chrome around uosc while its controls are visible: a soft shadow behind them, the
-- title (with the current chapter above it) bottom-left, and subtitles lifted clear.

local options = {
    title_font = "Bodoni 72",
    meta_font = "DIN Alternate",
}
require("mp.options").read_options(options, "controls-backdrop")

local base_sub_margin = mp.get_property_number("sub-margin-y", 22)
local overlay = mp.create_osd_overlay("ass-events")
overlay.z = -10 -- below uosc
local margin_bottom = 0
local menu_open = false

local function escape(text)
    return (text:gsub("\\", "\\\226\129\160"):gsub("{", "\\{"):gsub("\n", " "))
end

local function title()
    local media_title = mp.get_property("media-title", "")
    if media_title == mp.get_property("filename") then
        media_title = media_title:gsub("%.%w+$", "")
    end
    return media_title
end

-- A heavily blurred rectangle reads as a smooth vertical gradient without banding.
local function shade(y0, y1, w, alpha, blur)
    return string.format(
        "{\\an7\\pos(0,0)\\bord0\\shad0\\blur%d\\1c&H000000&\\1a&H%02X&\\p1}m %d %d l %d %d %d %d %d %d{\\p0}",
        blur, alpha, -blur * 2, y0, w + blur * 2, y0, w + blur * 2, y1, -blur * 2, y1)
end

local function text(x, y, font, size, alpha, value)
    return string.format("{\\an1\\pos(%.1f,%.1f)\\bord0\\shad0\\fn%s\\fs%.1f\\1c&HFFFFFF&\\1a&H%02X&}%s",
        x, y, font, size, alpha, escape(value))
end

local function render()
    local dims = mp.get_property_native("osd-dimensions")
    if not dims or dims.h == 0 or margin_bottom <= 0 or menu_open then
        overlay:remove()
        mp.set_property_number("sub-margin-y", base_sub_margin)
        return
    end

    local w, h = 720 * dims.w / dims.h, 720
    local px = mp.get_property_number("display-hidpi-scale", 1) * h / dims.h -- one uosc pixel
    local controls_top = h - margin_bottom * h
    local left = 22 * px
    local title_size, chapter_size = 30 * px, 15 * px
    local title_y = controls_top - 10 * px
    local chapter = mp.get_property("chapter-metadata/title")

    local events = { shade(controls_top - 150 * px, h + 80, w, 0x50, math.floor(110 * px)) }
    events[#events + 1] = text(left, title_y, options.title_font, title_size, 0x00, title())
    local block = title_size + 10 * px
    if chapter and chapter ~= "" then
        events[#events + 1] = text(left, title_y - title_size - 4 * px, options.meta_font, chapter_size, 0x50, chapter)
        block = block + chapter_size + 4 * px
    end

    overlay.res_x, overlay.res_y = w, h
    overlay.data = table.concat(events, "\n")
    overlay:update()
    mp.set_property_number("sub-margin-y", base_sub_margin + math.floor(h - controls_top + block))
end

mp.observe_property("user-data/osc/margins", "native", function(_, margins)
    margin_bottom = margins and margins.b or 0
    render()
end)
mp.observe_property("user-data/uosc/menu/type", "native", function(_, menu_type)
    menu_open = menu_type ~= nil
    render()
end)
for _, prop in ipairs({ "osd-dimensions", "media-title", "chapter" }) do
    mp.observe_property(prop, "native", render)
end
