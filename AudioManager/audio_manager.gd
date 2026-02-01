extends Node2D

@export var mute: bool = false
@export var crossfade_time_ms: float = 2000.0  # Crossfade duration in milliseconds

# Cache $DynamicMusic_Player so it can be accessed in every frame
@onready var layered_player = $DynamicMusic_Player

# Dictionary storing target volume for each music layer
var layer_volumes := {}
var current_zone := ""
# Track which zones the player is currently inside (for bidirectional movement)
var active_zones := []

func _ready():
	setup_layered_music()
	setup_music_zones()

func StartBGMusic():
	# Set default zone instantly (no crossfade)
	set_zone_instant("default")

# Play individual sound effects
func play_sfx(sound_path: String):
	if not mute:
		var stream = load(sound_path)
		
		if stream and has_node("SFX_Player"):
			$SFX_Player.stream = stream
			$SFX_Player.play()

# Play single track background music
func play_bgm(sound_path: String):
	if not mute:
		var stream = load(sound_path)
		
		if stream and has_node("BGM_Player"):
			$BGM_Player.stream = stream
			$BGM_Player.play()

func start_layered_music():
	# Stop regular BGM first
	if has_node("BGM_Player") and $BGM_Player.playing:
		$BGM_Player.stop()
	
	# Start layered music
	if layered_player and not layered_player.playing:
		layered_player.play()

func setup_layered_music():
	if not has_node("DynamicMusic_Player"):
		push_error("AudioManager needs DynamicMusic_Player")
		return
	
	var sync_stream = AudioStreamSynchronized.new()
	sync_stream.stream_count = 6
	
	var file1 = preload("res://Assets/audio/FieldMusicStem1.ogg") # Base
	var file2 = preload("res://Assets/audio/FieldMusicStem2.ogg") # Forest/Jungle
	var file3 = preload("res://Assets/audio/FieldMusicStem3.ogg") # Waterfall
	var file4 = preload("res://Assets/audio/FieldMusicStem4.ogg") # Volcano
	var file5 = preload("res://Assets/audio/FieldMusicStem5.ogg") # Vocal 1
	var file6 = preload("res://Assets/audio/FieldMusicStem6.ogg") # Vocal 2
	
	print("=== AUDIO FILE CHECK ===")
	print("File 1: ", file1.resource_path)
	print("File 2: ", file2.resource_path)
	
	sync_stream.set_sync_stream(0, file1)
	sync_stream.set_sync_stream(1, file2)
	
	# Start all layers silent
	for i in range(sync_stream.stream_count):
		sync_stream.set_sync_stream_volume(i, -80.0)
		layer_volumes[i] = -80.0
	
	layered_player.stream = sync_stream
	layered_player.play()
	
	# FORCE Layer 1 to stay silent immediately
	await get_tree().process_frame  # Wait one frame for stream to initialize
	sync_stream.set_sync_stream_volume(1, -80.0)
	print("Forced Layer 1 to -80dB at startup")

# Automatically connect all Area2D children as music zone triggers
func setup_music_zones():
	for child in get_children():
		if child is Area2D:
			print("Found music zone: ", child.name)
			# Only connect body_entered for toggle behavior
			child.body_entered.connect(_on_zone_entered.bind(child.name))

# Called when player enters a zone - TOGGLES between states
func _on_zone_entered(body, zone_name: String):
	print("Body entered zone '", zone_name, "': ", body.name)
	
	if body.name == "Player":
		print("✓ Player entered: ", zone_name)
		start_layered_music()
		
		# TOGGLE: If currently in default, go to zone2. If in zone2, go back to default
		if current_zone == "default" or current_zone == "zone1":
			print("  → Toggling FROM default TO zone2")
			change_music_zone("zone2")
		else:
			print("  → Toggling FROM zone2 TO default")
			change_music_zone("default")

# This runs EVERY FRAME to smoothly crossfade layers
func _process(delta):
	if layered_player and layered_player.stream is AudioStreamSynchronized:
		var sync_stream = layered_player.stream as AudioStreamSynchronized
		
		# Convert crossfade time from milliseconds to seconds
		var fade_time_seconds = crossfade_time_ms / 1000.0
		
		# Calculate lerp weight based on fade time
		# Formula: weight = delta / fade_time
		# This makes the transition complete in exactly fade_time_seconds
		var fade_weight = delta / fade_time_seconds
		
		for layer_id in layer_volumes.keys():
			var current_vol = sync_stream.get_sync_stream_volume(layer_id)
			var target_vol = layer_volumes[layer_id]
			var new_vol = lerp(current_vol, target_vol, fade_weight)
			sync_stream.set_sync_stream_volume(layer_id, new_vol)
		
		# DEBUG: Print volumes every 30 frames to reduce spam
		if Engine.get_process_frames() % 30 == 0:
			var vol0 = sync_stream.get_sync_stream_volume(0)
			var vol1 = sync_stream.get_sync_stream_volume(1)
			#print("Zone: ", current_zone, " | Layer 0: ", snappedf(vol0, 0.1), " dB | Layer 1: ", snappedf(vol1, 0.1), " dB")

# Set initial music state for start of level
func set_zone_instant(zone_name: String):
	print("!!! SETTING INITIAL ZONE (INSTANT): '", zone_name, "'")
	current_zone = zone_name
	
	# Set target volumes
	match zone_name.to_lower():
		"default", "zone1":
			layer_volumes[0] = 0.0
			layer_volumes[1] = -80.0
			print("  ✓ DEFAULT: Layer 0 ON, Layer 1 OFF")

		"zone2", "musiczone2":
			layer_volumes[0] = 0.0
			layer_volumes[1] = 0.0
			print("  ✓ ZONE2: Both layers ON")
	
	# Apply volumes IMMEDIATELY to the stream (no lerp)
	if layered_player and layered_player.stream is AudioStreamSynchronized:
		var sync_stream = layered_player.stream as AudioStreamSynchronized
		for layer_id in layer_volumes.keys():
			sync_stream.set_sync_stream_volume(layer_id, layer_volumes[layer_id])
			print("    Layer ", layer_id, " set to ", layer_volumes[layer_id], " dB instantly")

# Called when zones trigger (with crossfade)
func change_music_zone(zone_name: String):
	if current_zone == zone_name or mute:
		print("  (Already in zone: ", zone_name, ")")
		return
	
	print("!!! CHANGING MUSIC ZONE TO: '", zone_name, "' (CROSSFADE)")
	print("    Crossfade time: ", crossfade_time_ms, " ms")
	current_zone = zone_name
	
	match zone_name.to_lower():
		"default", "zone1":
			layer_volumes[0] = 0.0
			layer_volumes[1] = -80.0
			layer_volumes[2] = -80.0
			layer_volumes[3] = -80.0
			layer_volumes[4] = 0.0
			layer_volumes[5] = -80.0
			#print("  ✓ DEFAULT: Layer 0 = 0dB (ON), Layer 1 = -80dB (OFF)")

		# Forest/Jungle
		"zone2", "musiczone2":
			layer_volumes[0] = 0.0
			layer_volumes[1] = 0.0
			layer_volumes[2] = -80.0
			layer_volumes[3] = -80.0
			layer_volumes[4] = 0.0
			layer_volumes[5] = -80.0
			#print("  ✓ ZONE2: Layer 0 = 0dB (ON), Layer 1 = 0dB (ON)")
			
		# Waterfall
		"zone3", "musiczone3":
			layer_volumes[0] = 0.0
			layer_volumes[1] = -80.0
			layer_volumes[2] = 0.0
			layer_volumes[3] = -80.0
			layer_volumes[4] = 0.0
			layer_volumes[5] = 0.0
			
		# Volcano
		"zone3", "musiczone3":
			layer_volumes[0] = 0.0
			layer_volumes[1] = -80.0
			layer_volumes[2] = -80.0
			layer_volumes[3] = 0.0
			layer_volumes[4] = 0.0
			layer_volumes[5] = -80.0
