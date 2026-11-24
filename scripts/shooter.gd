extends RigidBody2D

@export var shootSpeed := 750.0
@export var sizedecay := 0.333
@export var turnspeed := 0.01

@onready var path : Line2D = $path

var isClone := false
var shotcount := 0
var cooldowntimer := 0.0

@export var maxpoints := 60
@export var timestep := 0.05

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = Globals.seed + 1
	
	self.modulate = Color('ffffff00')
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color('ffffff'), 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not event.relative.is_zero_approx():
		if Globals.onController:
			Globals.onController = false
		look_at(get_global_mouse_position())

func _physics_process(delta: float) -> void:
	if isClone:
		return
		
	if cooldowntimer > 0:
		cooldowntimer -= delta
	
	if Input.is_action_pressed("aimup"):
		rotate(-turnspeed)
		if not Globals.onController:
			Globals.onController = true
		
	elif Input.is_action_pressed("aimdown"):
		rotate(turnspeed)
		if not Globals.onController:
			Globals.onController = true

	if Input.is_action_pressed("uppc"):
		rotate(-turnspeed)
		if Globals.onController:
			Globals.onController = false
		
	elif Input.is_action_pressed("downpc"):
		rotate(turnspeed)
		if Globals.onController:
			Globals.onController = false
			
	update_trajectory()

	if Input.is_action_just_pressed("shoot"):
		if Globals.canshoot and cooldowntimer <= 0:
			shoot()
			cooldowntimer = Globals.cooldownspeed
			Globals.playsound('res://sounds/shoot.wav', rng.randf_range(0.7, 1.3))

func shoot() -> void:
	var clone = self.duplicate() as RigidBody2D
	clone.isClone = true
	clone.freeze = false
	
	clone.get_node('shootercol').disabled = false
	
	clone.name = 'bullet' + str(shotcount)
	shotcount += 1
	
	clone.get_node('path').hide()
	
	get_parent().add_child(clone)
	
	var fwddir = Vector2.RIGHT.rotated(rotation)
	clone.apply_central_impulse(fwddir * shootSpeed)

func hitsomething(): # when hit something
	$ballSprite.scale *= sizedecay
	$shootercol.scale *= sizedecay
	
	if $shootercol.scale.x < 0.25:
		self.queue_free()

func _on_kill_body_entered(body: Node2D) -> void:
	if 'bullet' in body.name:
		body.queue_free()

func update_trajectory() -> void:
	path.clear_points()
	
	# Fixed gravity calculation: multiply vector direction by gravity strength and scale
	var grav: Vector2 = (
		ProjectSettings.get_setting("physics/2d/default_gravity_vector")
		* ProjectSettings.get_setting("physics/2d/default_gravity")
		* gravity_scale
	)
	
	var fwddir := Vector2.RIGHT.rotated(rotation)
	var vel := (fwddir * shootSpeed) / mass
	var pos := global_position
	var spacestate := get_world_2d().direct_space_state

	var shape := CircleShape2D.new()
	shape.radius = 8.0

	for i in range(maxpoints):
		path.add_point(to_local(pos))
		vel += grav * timestep
		var step := vel * timestep
		var nextpos := pos + step

		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = shape
		query.transform = Transform2D(0, pos)
		query.motion = step
		query.exclude = [self]
		query.collision_mask = collision_mask

		var motionresult := spacestate.cast_motion(query)
		if motionresult[0] < 1.0:
			query.transform = Transform2D(0, pos + step * motionresult[1])
			var rest_info := spacestate.get_rest_info(query)
			if rest_info:
				path.add_point(to_local(rest_info.point))
			else:
				path.add_point(to_local(pos + step * motionresult[0]))
			break

		pos = nextpos
