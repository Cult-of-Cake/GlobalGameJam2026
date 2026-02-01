extends EnemyBase
class_name EnemyWanderer

@export var startsLeft : bool = true
@export var wanderSpeed : float = 40

const LEFT = -1
const RIGHT = 1
var currDir = -1 if startsLeft else 1
enum FACING { LEFT, RIGHT }
var facing

func _physics_process(delta):
	bonk()
	if !is_on_floor():
		velocity = velocity + get_gravity() * delta
	move_and_slide()
	if currDir == 1:
		$AnimatedSprite2D.flip_h = true
		$CollisionShape2D.position.x = 15
		$PlayerBonker.position.x = 15
	else:
		$AnimatedSprite2D.flip_h = false
		$CollisionShape2D.position.x = -15
		$PlayerBonker.position.x = -15

func _process(delta):
	# Guards
	if not is_on_floor():
		return
	
	# Proceed
	var foundMove = false
	if currDir == LEFT:
		if %EdgeCheckerL.is_colliding():
			foundMove = true
		else:
			currDir *= -1 # Try the other way
	elif currDir == RIGHT: # If we swapped directions, just wait for the next frame
		if %EdgeCheckerR.is_colliding():
			foundMove = true
		else:
			currDir *= -1 # Try the other way
	if foundMove && !punched:
		velocity.x = currDir * wanderSpeed

#func UpdateSprites():
#		if currDir == LEFT:
#			facing = FACING.LEFT
#		else:
#			facing = FACING.RIGHT
#		$AnimatedSprite2D.sprite.flip_h = false if facing == FACING.LEFT else true
#		print($AnimatedSprite2D.sprite.flip_h)
	

func _on_wall_finder_right_body_entered(body: Node2D) -> void:
	if body.get_class() == "TileMap" || (body.has_method("is_enemy") && body.is_enemy()):
	#if (body.has_method("is_enemy") && body.is_enemy()):
		#print("happen")
		velocity.x = wanderSpeed * -1
		currDir = LEFT

func _on_wall_finder_left_body_entered(body: Node2D) -> void:
	if body.get_class() == "TileMap" || (body.has_method("is_enemy") && body.is_enemy()):
	#if (body.has_method("is_enemy") && body.is_enemy()):
		velocity.x = wanderSpeed
		currDir = RIGHT
