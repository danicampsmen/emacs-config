// ==============================================================================
// Firefox Battery, Performance & Wayland Optimizations for Lenovo Yoga 9
// ==============================================================================

// Hardware Video Acceleration (VA-API Intel QuickSync)
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.enabled", true);
user_pref("media.rdd-v4l2.enabled", true);
user_pref("media.ffvpx.enabled", false);

// WebRender & Wayland Native Integration
user_pref("gfx.webrender.all", true);
user_pref("widget.wayland.fractional-scale.enabled", true);
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
user_pref("widget.use-xdg-desktop-portal.mime-handler", 1);

// Energy Efficiency & Smart Tab Discarding
user_pref("browser.tabs.unloadOnLowMemory", true);
user_pref("browser.low_commit_space_threshold_mb", 2048);

// Reduce Disk Writes (Saves NVMe power and extends SSD life)
user_pref("browser.sessionstore.interval", 60000);

// Privacy & Performance
user_pref("privacy.donottrackheader.enabled", true);
user_pref("browser.download.panel.shown", true);
user_pref("extensions.autoDisableScopes", 0);
user_pref("browser.toolbars.bookmarks.visibility", "always");
