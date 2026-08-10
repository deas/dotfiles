-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Wayland-native apps are scaled by the compositor, so GDK must not scale again.
hl.env("GDK_SCALE", "1")

-- Built-in panel: 1080p at 1.5x. Omarchy's "auto" picks 2x here, which makes
-- everything (fonts included) noticeably too big.
hl.monitor({ output = "eDP-1", mode = "1920x1080@60.05", position = "0x0", scale = 1.5 })

-- Anything else attached: let Hyprland decide.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
