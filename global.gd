extends Node

enum FACING { LEFT, RIGHT, UP, DOWN } # Up and down are ONLY spider form
#region signals
signal landed()

signal dialogue_started
signal dialogue_finished

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
#endregion


#region Controls

# Dictionary keeps track of control images e.g. WASD
enum CONTROL_TYPE { KEYBOARD, CONTROLLER }
const SHOWCASE_MOVEMENT = ["Keyboard_WASD", "Keyboard_WASD"]
const SHOWCASE_DIALOGUE = ["Keyboard_Enter", "Keyboard_Enter"]

#endregion
