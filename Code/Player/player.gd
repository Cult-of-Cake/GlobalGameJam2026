extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const MAX_HITPOINTS = 5

var facing = Global.FACING.RIGHT
var metafloor = true
var punching = false

var invincible = false
var stunned = false
var crawling
var direction
var starting_position : Vector2 # Set in _ready
var hitpoints = MAX_HITPOINTS

var invincibleDuration = 2
var stunDuration = 0.4


func _ready():
	Global.landed.connect(land)
	Global.dialogue_started.connect(diag_started)
	Global.dialogue_finished.connect(diag_finished)
	
	FormSetup()
	hide_sprites()
	activate_sprites()
	show_sprite(%SpiderStanding)
	starting_position = position


func is_player():
	return true

func get_hit(damage: int, direction: Vector2, force: int):
	
	AudioManager.play_sound_group(Global.SfxType.HURT) #play damage sfx grouping
	
	if !invincible:
		velocity = direction.normalized() * force
		hitpoints -= damage
		if (hitpoints <= 0):
			Die()
		else:
			become_invincible()
			become_stunned()
		

func become_invincible():
	invincible = true
	$AnimationPlayer.play("invincibility")
	await get_tree().create_timer(invincibleDuration).timeout
	invincible = false
	$AnimationPlayer.stop()
	$AnimationPlayer.seek(0.11, true)

func become_stunned():
	stunned = true;
	crawling = false
	await get_tree().create_timer(stunDuration).timeout
	stunned = false
	
func _input(_event: InputEvent) -> void:
	CheckFormSwap()

func _unhandled_input(event):
	if event.get_class() == "InputEventKey":
		if event.keycode == 4194326 && event.pressed == true:
			if facing == Global.FACING.RIGHT:
				$ThePunchZone.position.x = 48
			else:
				$ThePunchZone.position.x = -48
			await get_tree().create_timer(0.1).timeout
			POooooOONCH()

func _physics_process(delta: float) -> void:
	if isDialogGoing:
		return
	
	# Handle player-induced upward velocity
	if (currPhysics == PHYSICS.FLY):
		if Input.is_action_just_pressed("jump") and !is_on_floor():
			if flyCount < FLY_MAX:
				flyCount += 1
				velocity.y = JUMP_VELOCITY * 1.5
				AudioManager.play_sound_group(Global.SfxType.FLAP) #play flying sfx grouping
	elif (currPhysics == PHYSICS.JUMP):
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			AudioManager.play_sound_group(Global.SfxType.JUMP) #play jump sfx grouping
	elif (currPhysics == PHYSICS.SWIM):
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY / 3
			AudioManager.play_sound_group(Global.SfxType.SWIM) #play swim sfx grouping
	
	# Add the gravity.
	if !metafloor && is_on_floor():
		Global.landed.emit()
		metafloor = true
	
	if !crawling:
		crawling = (is_on_floor() or custom_on_ceiling() or %SpiderWallLeft.is_colliding() && direction < 0 or %SpiderWallRight.is_colliding() && direction > 0)
	else:
		if !is_on_floor() && !custom_on_ceiling() && !%SpiderWallLeft.is_colliding() && !%SpiderWallRight.is_colliding():
			crawling = false
			
	if (currPhysics == PHYSICS.JUMP or currPhysics == PHYSICS.FLY):
		if not is_on_floor():
			velocity += get_gravity() * delta
	elif (currPhysics == PHYSICS.SWIM):
		if not is_on_floor():
			velocity += get_gravity() * delta / 3
	elif currPhysics == PHYSICS.CRAWL:
		if stunned || !crawling:
			velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	#left-right movement.
	#briefly disable it when taking damage
	direction = Input.get_axis("ui_left", "ui_right")
	if !stunned:
		if direction:
			velocity.x = direction * SPEED
			if(velocity.x < 0):
				facing = Global.FACING.LEFT
			if(velocity.x > 0):
				facing = Global.FACING.RIGHT
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		pass
	if currPhysics == PHYSICS.CRAWL and crawling:
		var updir := Input.get_axis("ui_up", "ui_down")
		if updir && (%SpiderWallLeft.is_colliding() || %SpiderWallRight.is_colliding() || custom_on_ceiling()):
			velocity.y = updir * SPEED
			if(velocity.y < 0):
				facing = Global.FACING.UP
			if(velocity.y > 0):
				facing = Global.FACING.DOWN
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
	
	if position.x < 0:
		position.x = 0
		velocity.x = 0
	
	# Die code
	if global_position.y > 2000:
		Die()

	UpdateSprites()
	move_and_slide()
	
func POooooOONCH():
	if(!punching && currForm == FORM.SNAKE):
		punching = true;
		AudioManager.play_sound_group(Global.SfxType.ATTACK) #play attack sfx grouping
		%SnakePunching.stop()
		%SnakePunching.play()
		#Actual Punch is executed when the signal indicating the correct frame is received


func _on_snake_punching_animation_finished() -> void:
		punching = false;
		hide_sprites()

func _on_snake_punching_frame_changed() -> void:
	if %SnakePunching.frame == 2:
		var bodies = $ThePunchZone.get_overlapping_bodies()
		for body in bodies:
			if body.has_method("is_punchable") && body.is_punchable():
				body.get_punched(facing)


#region Forms
var FORM_SIZES = [
	[27,55],   #Spider
	[35,130],  #Snake
	[62,124],  #Bird
	[44,140]]  #Jellyfish

enum FORM { SPIDER, SNAKE, BIRD, JELLYFISH }
var currForm = FORM.SPIDER

enum PHYSICS { CRAWL , JUMP, FLY, SWIM }
var formPhysics = [ PHYSICS.CRAWL, PHYSICS.JUMP, PHYSICS.FLY, PHYSICS.SWIM ]
var currPhysics = formPhysics[currForm]

var formSpriteNames = [ "spider", "snake", "bird", "jellyfish" ]
var formSprites = [] # Gets loaded on config

var flyCount = 0
const FLY_MAX = 3

func FormSetup() -> void:
	for n in formSpriteNames:
		formSprites.append(SceneManager.GetTexture("res://Assets/characters/", n, ".png"))
		
func FixTheGoddamnSpiderBox() -> void:
	$CollisionShape2D.shape.radius = FORM_SIZES[FORM.SPIDER][0]
	$CollisionShape2D.shape.height = FORM_SIZES[FORM.SPIDER][1]	
	

func CheckFormSwap() -> void:
	
	var prevForm = currForm
	if Input.is_action_just_pressed("form_cycle"):
		CycleUntilAllowed(1)
	elif Input.is_action_just_pressed("form_cycle_reverse"):
		CycleUntilAllowed(-1)
	elif Input.is_action_just_pressed("form_spider"):
		SwitchIfAllowed(FORM.SPIDER)
	elif Input.is_action_just_pressed("form_bird"):
		SwitchIfAllowed(FORM.BIRD)
	elif Input.is_action_just_pressed("form_snake"):
		SwitchIfAllowed(FORM.SNAKE)
	elif Input.is_action_just_pressed("form_jelly"):
		SwitchIfAllowed(FORM.JELLYFISH)
	
	if (currForm != prevForm):
		print ("Changed form to %s" % currForm)
		currPhysics = formPhysics[currForm]
		UpdateSprites()
		
		if currForm == FORM.SPIDER:
			$CollisionShape2D.shape.radius = FORM_SIZES[FORM.SPIDER][0]
			$CollisionShape2D.shape.height = FORM_SIZES[FORM.SPIDER][1]		
		if currForm == FORM.SNAKE:
			%SceneManager.play_single_sound("SnakeMaskActivate")
			$CollisionShape2D.shape.radius = FORM_SIZES[FORM.SNAKE][0]
			$CollisionShape2D.shape.height = FORM_SIZES[FORM.SNAKE][1]
		if currForm == FORM.BIRD:
			%SceneManager.play_single_sound("BirdMaskActivate")
			$CollisionShape2D.shape.radius = FORM_SIZES[FORM.BIRD][0]
			$CollisionShape2D.shape.height = FORM_SIZES[FORM.BIRD][1]
		if currForm == FORM.JELLYFISH:
			%SceneManager.play_single_sound("BlubMaskActivate")
			$CollisionShape2D.shape.radius = FORM_SIZES[FORM.JELLYFISH][0]
			$CollisionShape2D.shape.height = FORM_SIZES[FORM.JELLYFISH][1]


		if (currPhysics != PHYSICS.FLY):
			flyCount = 0

func land():
	hide_sprites()
	$SpiderStanding.visible = true

var isDialogGoing : bool = false
func diag_started() -> void:
	isDialogGoing = true
func diag_finished() -> void:
	isDialogGoing = false
	

func custom_on_ceiling():
	var bodies = %SpiderCeiling.get_overlapping_bodies()
	for body in bodies:
		if body.get_class() == "TileMap" && !stunned && (Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right") || crawling):
			return true
	return false

func IsFormAllowed(form : FORM):
	var globalForms = [ true, Global.GetVar("hasSnake"),
		Global.GetVar("hasBird"), Global.GetVar("hasJelly") ]
	
	var clearance = [check_horizontal_clearance(), check_vertical_clearance()]
	
	var allowedForms = [true]
	var index = 1;
	while(index < globalForms.size()): 		
		print("%d,%d,%s" % [(clearance[0] - FORM_SIZES[index][0]), (clearance[1] - FORM_SIZES[index][1]), globalForms[index]])
		allowedForms.push_back((
			((clearance[0] - (2* FORM_SIZES[index][0])) > 0)
			&& ((clearance[1] - FORM_SIZES[index][1]) > 0)
			&& bool(globalForms[index])
		))
		index = index + 1
	return allowedForms[form]

func CycleUntilAllowed(dir : int):
	while true: # This forces at least one iteration, like a do-while (which Godot lacks)
		currForm = (currForm as int + dir + 4) % FORM.size() as FORM
		if IsFormAllowed(currForm):
			break

func SwitchIfAllowed(form : FORM):
	if (IsFormAllowed(form)):
		currForm = form
	
#endregion

#region Animations

@onready var all_sprites = [
	%SpiderStanding, %SpiderWalking,
	%SnakeStanding, %SnakeWalking, %SnakeJumping, %SnakePunching,
	%BirdFlying, %BirdStanding,
	%JellyfishSwimming
]

func activate_sprites():
	for sprite in all_sprites:
		if (sprite):
			sprite.play()

func hide_sprites():
	for sprite in all_sprites:
		if (sprite):
			sprite.visible = false

func show_sprite(sprite : Node):
	sprite.visible = true
	
func UpdateSprites():
	hide_sprites()
	var is_moving = Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")
	match currForm:
		FORM.SNAKE:
			var sprite
			if !punching:
				if is_on_floor():
					if is_moving:
						sprite = %SnakeWalking
					else:
						sprite = %SnakeStanding
				else:
					sprite = %SnakeJumping
			else:
				sprite = %SnakePunching
			show_sprite(sprite)
			SpriteRotate(sprite, facing == Global.FACING.LEFT)
		FORM.SPIDER:
			var sprite
			if is_moving:
				sprite = %SpiderWalking
			else:
				sprite = %SpiderStanding
			show_sprite(sprite)
			if is_on_floor():
				SpriteRotate(sprite, facing == Global.FACING.LEFT, false)
			elif %SpiderWallLeft.is_colliding():
				SpriteRotate(sprite, facing == Global.FACING.UP, false, 90)
			elif %SpiderWallRight.is_colliding():
				SpriteRotate(sprite, facing == Global.FACING.DOWN, false, -90)
			elif custom_on_ceiling():
				SpriteRotate(sprite, facing == Global.FACING.LEFT, true)
			else:
				if !stunned:
					SpriteRotate(sprite, facing == Global.FACING.LEFT, false)
		FORM.BIRD:
			if !is_on_floor():
				SpriteRotate(%BirdFlying, facing == Global.FACING.LEFT)
				show_sprite(%BirdFlying)
			else:
				SpriteRotate(%BirdStanding, facing == Global.FACING.LEFT)
				show_sprite(%BirdStanding)
		FORM.JELLYFISH:
			show_sprite(%JellyfishSwimming)

func SpriteRotate(sprite : Node, flip_h : bool, flip_v : bool = false, rotation : int = 0):
	sprite.flip_h = flip_h
	sprite.flip_v = flip_v
	sprite.rotation = rotation

#endregion

func Die() -> void:
	%SceneManager.play_single_sound("DeathSound")
	position = starting_position
	hitpoints = MAX_HITPOINTS

func check_vertical_clearance():
	var overhead
	var under
	if !%CastUp.is_colliding():
		overhead = 500
	else:
		overhead = global_position.y - %CastUp.get_collision_point().y
	if !%CastDown.is_colliding():
		under = 500
	else:
		under = %CastDown.get_collision_point().y - global_position.y
	var clearance = overhead + under
	return clearance
func check_horizontal_clearance():
	var left
	var right
	if !%CastLeft.is_colliding():
		left = 500
	else:
		left =  global_position.x - %CastLeft.get_collision_point().x
	if !%CastRight.is_colliding():
		right = 500
	else:
		right = %CastRight.get_collision_point().x - global_position.x
	return left + right
