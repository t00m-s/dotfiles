hl.env("XCURSOR_SIZE", "24")
hl.env("GDK_SCALE", "1.5")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "hyprqt6engine")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
-- dGPU stuff
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("NVD_BACKEND", "direct")
-- hl.env('AQ_NO_ATOMIC', '1')
-- hl.env('WLR_NO_HARDWARE_CURSORS', '1')
-- hl.env('AQ_DRM_DEVICES', '/dev/dri/card1')
-- hl.env(
--   '__EGL_VENDOR_LIBRARY_FILENAMES',
--   '/usr/share/glvnd/egl_vendor.d/10_nvidia.json:/usr/share/glvnd/egl_vendor.d/50_mesa.json'
-- )
-- Forcing iGPU rendering, offloading to prime-run when gpu is needed.
-- hl.env('AQ_DRM_DEVICES', '/dev/dri/card2')
-- hl.env(
--   '__EGL_VENDOR_LIBRARY_FILENAMES',
--   '/usr/share/glvnd/egl_vendor.d/50_mesa.json:/usr/share/glvnd/egl_vendor.d/10_nvidia.json'
-- )
