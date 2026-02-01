extends Node


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Level_01.tscn")
