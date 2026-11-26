extends CanvasLayer

@onready var menuroot: Control = $menuRoot

var paused := false
var t: Tween

func _ready() -> void:
	visible = false
	menuroot.modulate.a = 0.0
	
	$menuRoot/vtext.text = 'v' + str(Globals.version)
	
	$menuRoot/resume.focus_neighbor_bottom = $menuRoot/quit.get_path()

	$menuRoot/quit.focus_neighbor_top = $menuRoot/resume.get_path()
	
	$menuRoot/seed.text = 'Seed: ' + str(Globals.seed)

func upd() -> void:
	if t:
		t.kill()
		
	t = create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	if paused:
		get_tree().paused = true 
		visible = true
		t.tween_property(menuroot, "modulate:a", 1.0, 0.33)
		$menuRoot/resume.grab_focus()
	else:
		t.tween_property(menuroot, "modulate:a", 0.0, 0.33)
		await t.finished
		if not paused:
			visible = false
			get_tree().paused = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		paused = not paused
		upd()

func _on_resume_pressed() -> void:
	paused = false
	upd()
