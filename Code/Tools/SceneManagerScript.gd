@tool
extends Resource
class_name SceneManagerScript

@export var script_source_file: String
@export_multiline var script_content: String:
	set(value):
		script_content = value
		notify_property_list_changed()


func load_script() -> void: 
	print(script_source_file)
	var file : FileAccess
	if script_source_file.begins_with("uid"):
		var parsed_uid := ResourceUID.text_to_id(script_source_file)
		var parsed_path := ResourceUID.get_id_path(parsed_uid)
		file = FileAccess.open(parsed_path,FileAccess.READ)
		print(parsed_path)
	else: 
		file = FileAccess.open(script_source_file,FileAccess.READ)
	var content = file.get_as_text()
	var content_clean = content.replace("\r", "")
	script_content = content_clean
	file.close()
	print(script_content)
	

@export_tool_button("Load Script", "Callable") var load_script_action = load_script
