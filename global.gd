extends Node

enum FACING { LEFT, RIGHT, UP, DOWN } # Up and down are ONLY spider form
enum FORM { SPIDER, SNAKE, BIRD, JELLYFISH } # Global list of all forms associated with a number
var FORM_CONTROL_NAMES : Dictionary[FORM,String] = FORM.keys().reduce(
	func(acc: Dictionary[FORM,String],cur: String) -> Dictionary[FORM,String]:
		var key = FORM[cur]
		var value: String = "form_" + cur.to_lower()
		acc[key] = value
		return acc
,{} as Dictionary[FORM,String])


#region signals
@warning_ignore("unused_signal")
signal landed()

@warning_ignore("unused_signal")
signal dialogue_started
@warning_ignore("unused_signal")
signal dialogue_finished

@warning_ignore("unused_signal")
signal controller_used
@warning_ignore("unused_signal")
signal keyboard_used

#endregion

#region Variables

var variables = {}
# Variable functions
func GetVar(v):
	if !variables.has(v):
		variables[v] = 0
	return Global.variables[v]
func SetVar(v, to):
	Global.variables[v] = to
	print(Global.variables)
	for obj : VisibleByVar in ObjsVisibleByVar:
		if obj.ConnectToVariable == v:
			obj.UpdateVisibility()

var ObjsVisibleByVar : Array[VisibleByVar] = []
func ConnectMeToVar(obj):
	ObjsVisibleByVar.append(obj)
func DisconnectFromVar(obj):
	ObjsVisibleByVar.erase(obj)

#endregion

#region Audio

var isBGMon = false

enum SfxType {
	# Player
	HURT, ATTACK, JUMP, FLAP, SWIM,
	# Enemies
	MOUSE_MAIN, MOTH_MAIN,
}

# Dictionary keeps track of which thing has which sounds
const SFX_POOLS: Dictionary = {
	SfxType.HURT: [
		"res://Assets/audio/HurtSound1.wav",
		"res://Assets/audio/HurtSound2.wav",
		"res://Assets/audio/HurtSound3.wav",
	],
	SfxType.ATTACK: [
		"res://Assets/audio/AttackSound1.wav",
		"res://Assets/audio/AttackSound2.wav",
		"res://Assets/audio/AttackSound3.wav",
	],
	SfxType.JUMP: [
		"res://Assets/audio/JumpSound1.wav",
		"res://Assets/audio/JumpSound2.wav",
		"res://Assets/audio/JumpSound3.wav",
	],
	SfxType.FLAP: [
		"res://Assets/audio/BirdFlap1.wav",
		"res://Assets/audio/BirdFlap2.wav",
	],
	SfxType.SWIM: [
		"res://Assets/audio/Jellyfish Move.wav",
	],
	SfxType.MOUSE_MAIN: [
		"res://Assets/audio/MouseChitter1.wav",
		"res://Assets/audio/MouseChitter2.wav",
	],
	SfxType.MOTH_MAIN: [
		"res://Assets/audio/MothFlutter1.wav",
		"res://Assets/audio/MothFlutter2.wav",
	],
}

# Makes sure audio won't play in rapid succession and screw up
@export var COOLDOWNS: Dictionary = {
	SfxType.HURT: 0.8,
	SfxType.ATTACK: 1,
	SfxType.JUMP: 0.3,
	SfxType.FLAP: 1,
	SfxType.SWIM: 0.6,
	SfxType.MOUSE_MAIN: 0.8,
	SfxType.MOTH_MAIN: 0.8,
}

#endregion
