extends Sprite2D

@export var Keyboard_Image : String
@export var Controller_Image : String

func _ready() -> void:
	if !Keyboard_Image || !Controller_Image:
		print("Warning: Keyboard or controller image not set for " + self.get_class())
	SetSprite(Keyboard_Image)
	
func On_Controller_Used():
	SetSprite(Controller_Image)
func On_Keyboard_Used():
	SetSprite(Keyboard_Image)
	
func SetSprite(img):
	print("Setting image " + img)
	texture = SceneManager.GetImage("res://Assets/gui/", img, ".PNG")
