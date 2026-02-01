extends Node2D


func _ready() -> void:
	%Player.FixTheGoddamnSpiderBox()
	Global.SetVar("hasSnake", 1)
	Global.SetVar("hasBird", 0)
	Global.SetVar("hasJelly", 0)
	
