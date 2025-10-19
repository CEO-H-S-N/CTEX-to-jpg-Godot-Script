@tool
extends Node

func _ready():
	# Folder inside the project where Godot stores converted import files
	var import_folder := "res://.import"
	var out_folder := "res://exported_textures"

	# Create output folder
	var dir := DirAccess.open("res://")
	if dir:
		dir.make_dir_recursive(out_folder)
	else:
		printerr("❌ Could not open base directory")
		return

	var d := DirAccess.open(import_folder)
	if not d:
		printerr("❌ Could not open", import_folder)
		return

	d.list_dir_begin()
	var fname := d.get_next()
	while fname != "":
		# Skip directories like "." and ".."
		if not d.current_is_dir() and fname.to_lower().ends_with(".ctex"):
			var import_path := import_folder + "/" + fname
			print("🔄 Loading:", import_path)

			var tex := ResourceLoader.load(import_path)
			if tex:
				var img: Image = null  # 👈 explicitly declare type
				# Try to get the texture's image data
				if "get_image" in tex:
					img = tex.get_image()
				elif "get_data" in tex:
					img = tex.get_data()

				if img:
					var out_path := out_folder + "/" + fname.get_basename() + ".png"
					var err := img.save_png(out_path)
					if err == OK:
						print("✅ Saved:", out_path)
					else:
						printerr("⚠️ Failed to save:", out_path, "Error code:", err)
				else:
					printerr("⚠️ Could not extract image for", import_path)
			else:
				printerr("❌ Failed to load resource:", import_path)
		fname = d.get_next()
	d.list_dir_end()

	print("🎉 Export finished! Check the 'exported_textures' folder.")
