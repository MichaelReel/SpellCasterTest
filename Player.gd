extends CharacterBody3D

const _ANIM_LERP: float = 0.15
const _SQUARED_DRAW_RESOLUTION: float = 20.0

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

@onready var spell_view_port: SubViewport = $SpellPanel/SubViewport
@onready var wand_cursor: Node2D = $SpellPanel/SubViewport/WandCursor
@onready var wand_trail: Line2D = $SpellPanel/SubViewport/Line2D
@onready var spell_grid: Node2D = $SpellPanel/SubViewport/SpellGrid

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
			wand_cursor.position = Vector2(spell_view_port.size / 2)
			spell_draw_display.set_visible(true)
			mouse_look_on = false
			casting = true
		
		if mouse_event.is_action_released("player_cast"):
			# Stop drawing and cast spell
			spell_draw_display.set_visible(false)
			var casting_travel: int = wand_trail.get_point_count()
			wand_trail.clear_points()
			wand_cursor.position = Vector2(spell_view_port.size / 2)
			var spell_casting: Array[Globals.MagicType] = spell_grid.complete_spell()
			mouse_look_on = true
			casting = false
			
			_trigger_spell(spell_casting, casting_travel)
		
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
			# Move the spell cursor
			wand_cursor.position += event.relative
			wand_cursor.position.x = clamp(
				wand_cursor.position.x, Vector2.ZERO.x, spell_view_port.size.x
			)
			wand_cursor.position.y = clamp(
				wand_cursor.position.y, Vector2.ZERO.y, spell_view_port.size.y
			)
			
			# Draw on the spell surface
			if (
				wand_trail.get_point_count() == 0
				or wand_trail.points[-1].distance_squared_to(
					wand_cursor.position
				) >= _SQUARED_DRAW_RESOLUTION
			):
				wand_trail.add_point(wand_cursor.position)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	# Add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration
	var input_dir: Vector2 = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, _ANIM_LERP)
		velocity.z = lerp(velocity.z, direction.z * speed, _ANIM_LERP)
	else:
		velocity.x = lerp(velocity.x, 0.0, _ANIM_LERP)
		velocity.z = lerp(velocity.z, 0.0, _ANIM_LERP)

	anim_tree.set("parameters/BlendSpace1D/blend_position", velocity.length() / speed)

	move_and_slide()

func _trigger_spell(spell_casting: Array[Globals.MagicType], casting_travel: int) -> void:
	var spell_key: String = _get_spell_key(spell_casting)
	print("Spell Key: " + spell_key + ", Casting Travel: " + str(casting_travel))
	

func _get_spell_key(spell_casting: Array[Globals.MagicType]) -> String:
	var key: String = ""
	for cast_point in spell_casting:
		key += Globals.KEY_COMPONENTS[cast_point]
	return key
