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
	var file = FileAccess.open(script_source_file,FileAccess.READ)
	var content = file.get_as_text()
	script_content = content
	print(script_content)
	

@export_tool_button("Load Script", "Callable") var load_script_action = load_script
