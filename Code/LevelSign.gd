extends FriendBase

@export var next_scene : PackedScene

func _input(_event: InputEvent) -> void:
	if(talkable):
		if Input.is_action_just_pressed("ui_up"):
			get_tree().change_scene_to_packed(next_scene)
