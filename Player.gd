extends CharacterBody3D

const _ANIM_LERP: float = 0.15

@export var speed: float = 10.0
@export var jump_velocity: float = 10.0
@export var turn_speed: float = 0.005

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera: Camera3D = $Camera3D
@onready var anim_tree: AnimationTree = $AnimationTree

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	if not is_multiplayer_authority(): return

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		# Actual model rotation
		rotate_y(-event.relative.x * turn_speed)
		
		# 1st Person Camera rotation
		camera.rotate_x(-event.relative.y * turn_speed)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
		# # Potential for 3rd party Rotations
		# #   If a camera is nested under a `spring_arm` SpringArm3D
		# #   which is itself nested under a `spring_arm_pivot` Node2D
		# spring_arm_pivot.rotate.y(-event.relative.x * turn_speed)
		# spring_arm.rotate_x(-event.relative.y * turn_speed)
		# spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)

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
