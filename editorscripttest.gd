@tool
extends EditorScript

@export var file: String = "res://Assets/scripts/level_01_g1_01.txt"

func _run() -> void:
	var uid := ResourceUID.create_id_for_path(file)
	var uidFile := FileAccess.open(file + ".uid", FileAccess.WRITE)
	var uidStr := ResourceUID.id_to_text(uid)
	ResourceUID.add_id(uid, file)
	uidFile.store_string(uidStr)
	print(uidStr)
