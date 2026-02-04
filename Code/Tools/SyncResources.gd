@tool
extends EditorScript


func _run() -> void:
	var script_folder := "res://Assets/scripts/"
	var script_resources = Array(DirAccess.get_files_at(script_folder)).filter(\
		func (cur): return cur.contains(".script.tres")\
	)
	for rScript in script_resources:
		var resource_file = ResourceLoader.load(script_folder + rScript)
		resource_file.load_script()
		print(resource_file.script_content)
		ResourceSaver.save(resource_file,script_folder + rScript)
	
