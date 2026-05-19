extends "res://ui/views/aero_ui_glass_panel_view.gd"

# Transitional compatibility wrapper.
#
# The canonical shared panel runtime now lives at:
# - script: res://ui/views/aero_ui_glass_panel_view.gd
# - scene:  res://ui/views/aero_ui_glass_panel_view.tscn
#
# Keep this legacy script path only to lower transition risk for older scenes/tests while
# host adoption migrates to the canonical AeroUiGlassPanelView path/API.
