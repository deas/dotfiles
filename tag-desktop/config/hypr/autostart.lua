-- Extra autostart processes.
-- Omarchy's own startup commands live in default/hypr/autostart.lua.

hl.on("hyprland.start", function()
  -- Terminal on workspace 1, browser on workspace 2, without stealing focus.
  hl.exec_cmd("omarchy-launch-terminal", { workspace = "1 silent" })
  hl.exec_cmd("omarchy-launch-browser", { workspace = "2 silent" })
end)

-- Network indicator in the tray.
o.launch_on_start("nm-applet --indicator")
