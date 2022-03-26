extends "res://addons/gd-plug/plug.gd"

func _plugging():
    # Declare your plugins in here with plug(src, args)
    # By default, only "addons/" directory will be installed
    
    # dependencies
    plug("rakugoteam/project-settings-helpers")

    # optional supported plugins
    plug("rakugoteam/Emojis-For-Godot", {"include": [".import/"]})
    plug("rakugoteam/Godot-Material-Icons", {"include": [".import/"]})
    
    # optional plugins to help with development
    plug("Xrayez/godot-editor-icons-previewer")