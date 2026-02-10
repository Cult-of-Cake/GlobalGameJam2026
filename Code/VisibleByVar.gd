extends Node2D
class_name VisibleByVar

@export var ConnectToVariable : String
@export var DisconnectAfterUpdate : bool = true # Saves processing if we only need to flip once

func _ready():
	UpdateVisibility()
	Global.ConnectMeToVar(self)

func UpdateVisibility() -> void:
	var prev = visible
	visible = Global.GetVar(ConnectToVariable)
	if DisconnectAfterUpdate and visible != prev:
		Global.DisconnectFromVar(self)
