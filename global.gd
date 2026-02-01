extends Node

enum FACING { LEFT, RIGHT, UP, DOWN } # Up and down are ONLY spider form
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
#endregion
