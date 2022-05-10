extends "res://addons/gd-plug/plug.gd"

func _plugging():
    # Declare your plugins in here with plug(src, args)
    # By default, only "addons/" directory will be installed
    
    # dependencies
    
    # optional plugins to help with development
    plug("Xrayez/godot-editor-icons-previewer")

    # optional supported plugins
    plug("rakugoteam/Emojis-For-Godot", {"include": ["addons", ".import/"]})
    plug("rakugoteam/Godot-Material-Icons", {"include": ["addons", ".import/"]})
  
