#A demonstration illustrating the class established
#By: Jstn Jrg 
extends Control

onready var h_box_container: HBoxContainer = $HBoxContainer

enum {ADD_POINT,REMOVE_POINT,EDIT_POINT, CURVE}

#Exports
export var precision := 20.0
export var curve_softness := 30
export(Array,Color) var colors 
export(Array,Texture) var textures

#Vars
var current_state := ADD_POINT
var points := []
var bazier_curve := []
var bazier_classe := Bazier.new()

#Signals
signal updated_curve

func _ready() -> void:
	
	for c in h_box_container.get_child_count():
		h_box_container.get_child(c).connect("pressed",self,"_on_button_pressed",[c])
	
	set_process(true)

func _process(_delta: float) -> void:
	match current_state:
		ADD_POINT: _add_points()
		EDIT_POINT: _edit_point()
		REMOVE_POINT: _remove_point()
	update()

func _draw() -> void:
	
	if points.size() > 2 and  (current_state == ADD_POINT or current_state == REMOVE_POINT) : 
		draw_polyline(points,colors[0],4.0)
		
		if current_state == REMOVE_POINT:
			for p in points:
				draw_texture(textures[1],p-textures[1].get_size()*0.5)
	
	if bazier_curve.size() > 2 and  (current_state == EDIT_POINT or current_state == CURVE): draw_polyline(bazier_curve,colors[1],4.0)
	
	if  current_state == EDIT_POINT: 
		var control_points := bazier_classe._control_points()
		for c in control_points:
			draw_line(c[0],c[-1],colors[2],3.0)
			draw_texture(textures[0],c[0]-textures[0].get_size()*0.5)
			draw_texture(textures[0],c[-1]-textures[0].get_size()*0.5)

func _add_points() -> void:
	if Input.is_action_just_pressed("mouse") and not h_box_container.get_rect().has_point(get_global_mouse_position()) :
		points.append(get_global_mouse_position())

func _edit_point () -> void:
	if Input.is_action_pressed("mouse"):
		var data := bazier_classe.data
		for i in data.size():
			if (data[i]-get_global_mouse_position()).length() < precision:
				data[i] = get_global_mouse_position()
				points = data
				emit_signal("updated_curve")
				break

func _remove_point() -> void:
	if Input.is_action_pressed("mouse"):
		for i in points.size():
			if (points[i]-get_global_mouse_position()).length() < precision:
				points.remove(i)
				break

func _generate_curve () -> void:
	bazier_curve = bazier_classe._bazier_curve(points,curve_softness)

func _on_main_updated_curve() -> void:
	bazier_curve = bazier_classe._bazier_curve(points,curve_softness)

func _on_button_pressed(indx: int) -> void:
	
	match indx:
		0: 
			_generate_curve()
			current_state = EDIT_POINT
		
		1: current_state = ADD_POINT
		
		2: 
			_generate_curve()
			current_state = CURVE
		
		3: current_state = REMOVE_POINT



