extends CharacterBody2D
class_name PointTopLoader2D

@export var speed: float = 100.0
@export var sprint_speed: float = 180.0
@export var animation_sprite: AnimatedSprite2D
@export var look_at_mouse: bool = false  # <-- New option to toggle mouse look

var is_attacking: bool = false
var is_crouching: bool = false
var is_jumping: bool = false
var is_sprinting: bool = false

var input_vector: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.DOWN

func _physics_process(delta: float) -> void:
	# Movement input
	input_vector = Vector2(
		Input.get_action_strength("walk-right") - Input.get_action_strength("walk-left"),
		Input.get_action_strength("walk-down") - Input.get_action_strength("walk-up")
	).normalized()

	# Update last_direction only if not looking at mouse and player moves
	if not look_at_mouse and input_vector != Vector2.ZERO:
		last_direction = input_vector

	# Extra action input
	is_attacking = Input.is_action_pressed("attack") or Input.is_action_pressed("click0")
	is_crouching = Input.is_action_pressed("crouch") or Input.is_action_pressed("click1")
	is_jumping = Input.is_action_just_pressed("jump")
	is_sprinting = Input.is_action_pressed("sprint")

	# Movement
	var current_speed = sprint_speed if is_sprinting else speed
	velocity = input_vector * current_speed
	move_and_slide()

	update_animation()

func update_animation() -> void:
	if animation_sprite == null:
		return

	var state_prefix := ""

	if is_attacking:
		state_prefix = "attack"
	elif is_jumping:
		state_prefix = "jump"
	elif is_crouching:
		state_prefix = "crouch"
	elif input_vector != Vector2.ZERO:
		state_prefix = "sprint" if is_sprinting else "walk"
	else:
		state_prefix = "idle"

	# Decide direction
	var dir_anim: Vector2
	if look_at_mouse:
		var mouse_pos = get_global_mouse_position()
		dir_anim = (mouse_pos - global_position).normalized()
		if dir_anim == Vector2.ZERO:
			dir_anim = last_direction
	else:
		dir_anim = last_direction

	var full_anim = state_prefix + "-" + get_direction_name(dir_anim)

	if animation_sprite.sprite_frames.has_animation(full_anim):
		if animation_sprite.animation != full_anim:
			animation_sprite.play(full_anim)

func get_direction_name(dir: Vector2) -> String:
	if dir == Vector2.ZERO:
		return "down"

	var angle = dir.angle()
	var pi_8 = PI / 8

	if angle >= -pi_8 and angle < pi_8:
		return "right"
	elif angle >= pi_8 and angle < 3 * pi_8:
		return "down-right"
	elif angle >= 3 * pi_8 and angle < 5 * pi_8:
		return "down"
	elif angle >= 5 * pi_8 and angle < 7 * pi_8:
		return "down-left"
	elif angle >= 7 * pi_8 or angle < -7 * pi_8:
		return "left"
	elif angle >= -7 * pi_8 and angle < -5 * pi_8:
		return "up-left"
	elif angle >= -5 * pi_8 and angle < -3 * pi_8:
		return "up"
	elif angle >= -3 * pi_8 and angle < -pi_8:
		return "up-right"
	else:
		return "down"
