extends CanvasLayer

@export var bginthisscene : CanvasLayer
var usingcontroller := false

func _ready() -> void:
	usingcontroller = Globals.onController
	
	for c in get_children():
		c.modulate = Color('ffffff00')
		var tween = create_tween()
		tween.tween_property(c, "modulate", Color('ffffff'), 2.0)
	
	$play.focus_mode = Control.FOCUS_ALL
	$exit.focus_mode = Control.FOCUS_ALL
	
	$play.focus_neighbor_bottom = $exit.get_path()
	$exit.focus_neighbor_top = $play.get_path()
	
	$play.focus_neighbor_top = $play.get_path()
	$exit.focus_neighbor_bottom = $exit.get_path()
	
	for btn in [$play, $exit]:
		btn.get_node("ps4iconX").hide()
		btn.focus_entered.connect(_update_icons)
		btn.focus_exited.connect(_update_icons)
	
	$play.grab_focus()
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("x"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused is BaseButton:
			focused.pressed.emit()
			get_viewport().set_input_as_handled()

	# switch to mouse mode
	if event is InputEventMouseMotion and not event.relative.is_zero_approx():
		if usingcontroller:
			usingcontroller = false
			_update_icons()
	
	# switch back to controller
	elif event is InputEventJoypadButton or (event is InputEventJoypadMotion and abs(event.axis_value) > 0.2):
		if not usingcontroller:
			usingcontroller = true
			_update_icons()

func _update_icons() -> void:
	var focused = get_viewport().gui_get_focus_owner()
	for btn in [$play, $exit]:
		btn.get_node("ps4iconX").visible = (usingcontroller and btn == focused)


func fadeouteverything(node: Node, time=0.5) -> void:
	if 'bg' in node.name:
		return
	
	if node is CanvasItem:
		var t = create_tween()
		t.tween_property(node, "self_modulate", Color("ffffff00"), time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	for child in node.get_children():
		fadeouteverything(child, time)

func _on_button_pressed() -> void: # play
	print('clicked')
	fadeouteverything(get_tree().current_scene)
	await get_tree().create_timer(0.7).timeout
	
	var mainSCENE = load("res://scenes/main.tscn")
	var mainINSTANCE = mainSCENE.instantiate()

	# cool bg no jump
	var bg = mainINSTANCE.get_node("bg")
	bg.initcol2 = Color.from_hsv(bginthisscene.hue, 0.87, 0.4, 0.5)

	# swap
	var tree = get_tree()
	var curscene = tree.current_scene
	tree.root.add_child(mainINSTANCE)
	tree.current_scene = mainINSTANCE
	curscene.queue_free()

func _on_exit_pressed() -> void:
	get_tree().quit()
