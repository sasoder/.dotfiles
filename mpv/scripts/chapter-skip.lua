-- Netflix-style "Skip Intro" prompt for opening/credits/recap/preview chapters.
-- ENTER skips while the prompt is visible. `script-binding chapter_skip/toggle-auto`
-- (or uosc's control-bar button) switches to skipping automatically, each chapter
-- once per file so seeking back into it still works.

local options = {
    auto = false,
    prompt_duration = 8,
    font = "Avenir Next Demi Bold",
    accent = "FFEE8C",
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

local function bgr(rgb) return rgb:sub(5, 6) .. rgb:sub(3, 4) .. rgb:sub(1, 2) end

local function kind_of(title)
    title = (title or ""):lower()
    for _, kind in ipairs(kinds) do
        for _, pattern in ipairs(kind.patterns) do
            if title:find(pattern) then return kind.label end
        end
    end
end

local function rounded_rect(w, h, r)
    return string.format(
        "m %d 0 l %d 0 b %d 0 %d 0 %d %d l %d %d b %d %d %d %d %d %d l %d %d b 0 %d 0 %d 0 %d l 0 %d b 0 0 0 0 %d 0",
        r, w - r, w, w, w, r, w, h - r, w, h, w, h, w - r, h, r, h, h, h, h - r, r, r)
end

local function render()
    local dims = mp.get_property_native("osd-dimensions")
    if not shown_label or not dims or dims.h == 0 then return end

    -- Modelled on Netflix/Prime: dark translucent button, thin light border, icon + label.
    local w, h = math.floor(720 * dims.w / dims.h), 720
    local text = "Skip " .. shown_label
    local fs, pad = 20, 16
    local text_w = math.floor(#text * fs * 0.5)
    local key_w, key_h = 46, 20
    local bw, bh = pad + 16 + 10 + text_w + 14 + key_w + pad, 42
    local x = w - 32 - bw
    local y = h - math.floor(bottom_margin * h) - 28 - bh
    local accent = bgr(options.accent)

    overlay.res_x, overlay.res_y = w, h
    overlay.data = table.concat({
        string.format("{\\an7\\pos(%d,%d)\\bord1\\shad0\\1c&H141414&\\1a&H38&\\3c&HFFFFFF&\\3a&HA0&\\p1}%s{\\p0}",
            x, y, rounded_rect(bw, bh, 6)),
        -- fast-forward icon
        string.format("{\\an7\\pos(%d,%d)\\bord0\\shad0\\1c&H%s&\\p1}m 0 0 l 8 6 l 0 12 m 8 0 l 16 6 l 8 12{\\p0}",
            x + pad, y + bh / 2 - 6, accent),
        string.format("{\\an4\\pos(%d,%d)\\bord0\\shad0\\fn%s\\fs%d\\1c&HFFFFFF&}%s",
            x + pad + 26, y + bh / 2, options.font, fs, text),
        string.format("{\\an7\\pos(%d,%d)\\bord1\\shad0\\1a&HFF&\\3c&HFFFFFF&\\3a&HB0&\\p1}%s{\\p0}",
            x + bw - pad - key_w, y + (bh - key_h) / 2, rounded_rect(key_w, key_h, 4)),
        string.format("{\\an5\\pos(%d,%d)\\bord0\\shad0\\fn%s\\fs11\\1c&HFFFFFF&\\1a&H60&\\fsp1}ENTER",
            x + bw - pad - key_w / 2, y + bh / 2, options.font),
    }, "\n")
    overlay:update()
end

local function hide()
    if hide_timer then
        hide_timer:kill()
        hide_timer = nil
    end
    shown_label = nil
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

local function set_auto(on)
    options.auto = on
    mp.commandv("script-message", "set", "auto_skip", on and "yes" or "no")
end

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
    set_auto(not options.auto)
    mp.osd_message("Auto-skip intros & credits " .. (options.auto and "on" or "off"))
end)
mp.register_script_message("set", function(prop, value)
    if prop == "auto_skip" and (value == "yes") ~= options.auto then set_auto(value == "yes") end
end)
