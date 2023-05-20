extends CharacterBody3D

const _ANIM_LERP: float = 0.15

@export var speed: float = 10.0
@export var jump_velocity: float = 10.0
@export var turn_speed: float = 0.005

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_look_on: bool = true
var casting: bool = false

@onready var camera: Camera3D = $Camera3D
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var spell_draw_display: MeshInstance3D = $Camera3D/SpellDrawDisplay

@onready var wand_cursor: Node2D = $SpellPanel/SubViewport/WandCursor
@onready var wand_trail: Line2D = $SpellPanel/SubViewport/Line2D

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	if not is_multiplayer_authority(): return

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.is_action_pressed("player_cast"):
			# Start a new spell draw
			wand_trail.clear_points()
			spell_draw_display.set_visible(true)
			mouse_look_on = false
			casting = true
		
		if mouse_event.is_action_released("player_cast"):
			# Stop drawing and cast spell
			spell_draw_display.set_visible(false)
			wand_trail.clear_points()
			mouse_look_on = true
			casting = false
		
		if mouse_event.is_action_pressed("player_look_while_casting"):
			# Pause casting so we can look around
			if casting: mouse_look_on = true
		
		if mouse_event.is_action_released("player_look_while_casting"):
			# Commence casting
			if casting: mouse_look_on = false

	if event is InputEventMouseMotion: 
		if mouse_look_on:
			# Actual model rotation
			rotate_y(-event.relative.x * turn_speed)
			
			# 1st Person Camera rotation
			camera.rotate_x(-event.relative.y * turn_speed)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
		else:
			# Draw on the spell surface
			pass

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector2 = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
#		velocity.x = direction.x * speed
#		velocity.z = direction.z * speed
		velocity.x = lerp(velocity.x, direction.x * speed, _ANIM_LERP)
		velocity.z = lerp(velocity.z, direction.z * speed, _ANIM_LERP)
	else:
#		velocity.x = move_toward(velocity.x, 0, speed)
#		velocity.z = move_toward(velocity.z, 0, speed)
		velocity.x = lerp(velocity.x, 0.0, _ANIM_LERP)
		velocity.z = lerp(velocity.z, 0.0, _ANIM_LERP)

	anim_tree.set("parameters/BlendSpace1D/blend_position", velocity.length() / speed)

	move_and_slide()
