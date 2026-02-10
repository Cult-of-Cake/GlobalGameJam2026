extends CanvasItem
class_name HealthBar

var MAX_HEALTH : int = 2

func SetMaxHealth(max : int):
	MAX_HEALTH = max
	SetHealth(MAX_HEALTH)

func SetHealth(h : int) -> void:
	while %HealthContainer.get_child_count() > 0:
		%HealthContainer.remove_child(%HealthContainer.get_child(0))
	for i in range(0, h):
		AddHeart(%TemplateFull)
	for i in range(h, MAX_HEALTH):
		AddHeart(%TemplateEmpty)
	
func AddHeart(template):
	var heart = template.duplicate()
	heart.visible = true
	%HealthContainer.add_child(heart)
		
