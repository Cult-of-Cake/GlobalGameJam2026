extends CharacterBody2D
class_name EnemyBase

@export var hitpoints = 5
var damage = 2
var bonkPower = 200
var punched = false

func _ready() -> void:
	$AnimatedSprite2D.play()
	timer_sound()

func bonk():
	var bodies = $PlayerBonker.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("is_player") && body.is_player():
			var direction = body.global_position - global_position
			body.get_hit(damage, direction, bonkPower)

func timer_sound() -> void:
	var dist = position.distance_to(%Player.position)
	#print ("Distance %d" % dist)
	if dist < 600:
		make_regular_sound()
	# Call self again, after a delay
	await get_tree().create_timer(3).timeout
	timer_sound()

func is_punchable():
	return true
	
func is_enemy():
	return true

func get_punched(facing):
	punched = true
	make_hurt_sound()
	$AnimatedSprite2D/AnimationPlayer.play("get hit")
	var xMul
	if(facing == Global.FACING.LEFT):
		xMul = -1
	else:
		xMul = 1
	var newVelocity = Vector2(200, -150)
	newVelocity.x = newVelocity.x * xMul
	velocity = newVelocity
	hitpoints = hitpoints - 1
	if(hitpoints <= 0):
		queue_free()
	await get_tree().create_timer(0.5).timeout
	punched = false;

func make_hurt_sound():
	print("Warning: make_hurt_sound not implemented in child class of EnemyBase")

func make_regular_sound():
	print("Warning: make_regular_sound not implemented in child class of EnemyBase")
