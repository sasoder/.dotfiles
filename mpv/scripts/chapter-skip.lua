-- Netflix-style "Skip Intro" prompt for opening/credits/recap/preview chapters.
-- Click it or press ENTER while it's visible. `script-binding chapter_skip/toggle-auto`
-- switches to skipping automatically, each chapter once per file so seeking back into
-- it still works.

local options = {
    auto = false,
    prompt_duration = 8,
    font = "DIN Alternate",
}
require("mp.options").read_options(options, "chapter-skip")

local kinds = {
    { label = "Intro", patterns = { "^op$", "^op[%s%d%-:]", "^opening", "^intro", "オープニング" } },
    { label = "Credits", patterns = { "^ed$", "^ed[%s%d%-:]", "^ending", "^credits", "^end credits", "^outro", "エンディング" } },
    { label = "Recap", patterns = { "^recap", "^previously" } },
    { label = "Preview", patterns = { "^preview", "^next episode", "^next time" } },
}

local overlay = mp.create_osd_overlay("ass-events")
local hide_timer
local shown_label
local bottom_margin = 0
local auto_skipped = {}
local rect, hovered = nil, false -- prompt bounds in OSD pixels, for mouse hover/click

local function kind_of(title)
    title = (title or ""):lower()
    for _, kind in ipairs(kinds) do
        for _, pattern in ipairs(kind.patterns) do
            if title:find(pattern) then return kind.label end
        end
    end
end

local function capsule(w, h)
    local r, k = h / 2, h / 2 * 0.5523
    return string.format(
        "m %.1f 0 l %.1f 0 b %.1f 0 %.1f %.1f %.1f %.1f b %.1f %.1f %.1f %.1f %.1f %.1f l %.1f %.1f " ..
        "b %.1f %.1f 0 %.1f 0 %.1f b 0 %.1f %.1f 0 %.1f 0",
        r, w - r, w - r + k, w, r - k, w, r, w, r + k, w - r + k, h, w - r, h, r, h,
        r - k, h, r + k, r, r - k, r - k, r)
end

-- Apple TV style glass capsule: white glyph and label, brightens on hover, clickable.
local function render()
    local dims = mp.get_property_native("osd-dimensions")
    if not shown_label or not dims or dims.h == 0 then return end

    local w, h = 720 * dims.w / dims.h, 720
    local px = mp.get_property_number("display-hidpi-scale", 1) * h / dims.h
    local text = "Skip " .. shown_label
    local fs, pad, icon = 17 * px, 20 * px, 11 * px
    local bw, bh = pad + icon * 1.6 + 10 * px + #text * fs * 0.52 + pad, 44 * px
    local x = w - 24 * px - bw
    local y = h - bottom_margin * h - 18 * px - bh
    rect = { x = x * dims.h / h, y = y * dims.h / h, w = bw * dims.h / h, h = bh * dims.h / h }

    overlay.res_x, overlay.res_y = w, h
    overlay.data = table.concat({
        string.format("{\\an7\\pos(%.1f,%.1f)\\bord0\\shad0\\1c&H%s&\\1a&H%s&\\p1}%s{\\p0}",
            x, y, hovered and "FFFFFF" or "1C1C1C", hovered and "00" or "30", capsule(bw, bh)),
        string.format("{\\an7\\pos(%.1f,%.1f)\\bord0\\shad0\\1c&H%s&\\p1}m 0 0 l %.1f %.1f l 0 %.1f m %.1f 0 l %.1f %.1f l %.1f %.1f{\\p0}",
            x + pad, y + (bh - icon) / 2, hovered and "000000" or "FFFFFF",
            icon * 0.8, icon / 2, icon, icon * 0.8, icon * 1.6, icon / 2, icon * 0.8, icon),
        string.format("{\\an4\\pos(%.1f,%.1f)\\bord0\\shad0\\fn%s\\fs%.1f\\1c&H%s&}%s",
            x + pad + icon * 1.6 + 10 * px, y + bh / 2, options.font, fs, hovered and "000000" or "FFFFFF", text),
    }, "\n")
    overlay:update()
end

local function set_hovered(value)
    if value == hovered then return end
    hovered = value
    if value then
        mp.add_forced_key_binding("MBTN_LEFT", "chapter-skip-click", function() mp.commandv("add", "chapter", 1) end)
    else
        mp.remove_key_binding("chapter-skip-click")
    end
    render()
end

local function hide()
    if hide_timer then
        hide_timer:kill()
        hide_timer = nil
    end
    shown_label, rect = nil, nil
    set_hovered(false)
    overlay:remove()
    mp.remove_key_binding("chapter-skip-enter")
end

local function skip()
    hide()
    mp.commandv("add", "chapter", 1)
end

local function show(label)
    shown_label = label
    render()
    mp.add_forced_key_binding("ENTER", "chapter-skip-enter", skip)
    hide_timer = mp.add_timeout(options.prompt_duration, hide)
end

mp.observe_property("mouse-pos", "native", function(_, pos)
    set_hovered(rect ~= nil and pos ~= nil and pos.hover
        and pos.x >= rect.x and pos.x <= rect.x + rect.w and pos.y >= rect.y and pos.y <= rect.y + rect.h)
end)

mp.observe_property("chapter", "number", function(_, index)
    hide()
    if not index or index < 0 then return end
    local chapter = mp.get_property_native("chapter-list", {})[index + 1]
    local label = chapter and kind_of(chapter.title)
    if not label then return end

    if options.auto and not auto_skipped[index] then
        auto_skipped[index] = true
        mp.osd_message("Skipped " .. label)
        mp.commandv("add", "chapter", 1)
    else
        show(label)
    end
end)

-- Follow uosc's controls so the prompt sits just above them.
mp.observe_property("user-data/osc/margins", "native", function(_, margins)
    bottom_margin = margins and margins.b or 0
    render()
end)
mp.observe_property("osd-dimensions", "native", render)

mp.register_event("start-file", function() auto_skipped = {} end)
mp.register_event("end-file", hide)

mp.add_key_binding(nil, "toggle-auto", function()
    options.auto = not options.auto
    mp.osd_message("Auto-skip intros & credits " .. (options.auto and "on" or "off"))
end)
