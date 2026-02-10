class_name InputComponent extends Node

var form_control_names_keys := Global.FORM_CONTROL_NAMES.keys()

var move_dir := 0.0
var move_dir_y := 0.0
var jump_pressed := false
var form_cycle_pressed := false
var form_cycle_reverse_pressed := false
var form_hotkey_pressed : Dictionary[Global.FORM,bool] = Global.FORM.keys().reduce(
	func(acc: Dictionary[Global.FORM,bool],cur : String):
		acc[Global.FORM[cur]] = false;
		return acc;
,{} as Dictionary[Global.FORM,bool]) 




func update() -> void:
	move_dir = Input.get_axis("ui_left", "ui_right")
	move_dir_y = Input.get_axis("ui_up", "ui_down")
	jump_pressed = Input.is_action_just_pressed("jump")
	form_cycle_pressed = Input.is_action_just_pressed("form_cycle")
	if form_cycle_pressed:
		print("form_cycle_pressed!")
	form_cycle_reverse_pressed = Input.is_action_just_pressed("form_cycle_reverse")
	for key in form_control_names_keys:
		var input_name := Global.FORM_CONTROL_NAMES[key]
		form_hotkey_pressed[key] = Input.is_action_just_pressed(input_name)
		
	
