@tool
extends CharacterBody2D
class_name PointController2D

@export_enum("side_scroller", "top_loader") var mode: String = "side_scroller"
@export_enum("4-way", "8-way") var direction_mode: String = "4-way"

@export var speed: float = 200.0
@export var sprint_speed: float = 300.0
@export var jump_force: float = -400.0
@export var gravity: float = 1000.0
@export var animated_sprite_path: NodePath
@export var face_mouse: bool = true

var sprite: AnimatedSprite2D
var _last_direction: Vector2 = Vector2.DOWN
var is_attacking := false
var attack_timer := 0.0
var jump_timer := 0.0

func _ready():
	sprite = get_node_or_null(animated_sprite_path)
	if not sprite:
		push_error("AnimatedSprite2D not found at: " + str(animated_sprite_path))

func _physics_process(delta):
	var input_vec = Vector2(
		Input.get_action_strength("walk-right") - Input.get_action_strength("walk-left"),
		Input.get_action_strength("walk-down") - Input.get_action_strength("walk-up")
	)

	var is_sprinting = Input.is_action_pressed("sprint")
	var is_crouching = Input.is_action_pressed("crouch")
	var attack_pressed = Input.is_action_pressed("attack")
	var jump_pressed = Input.is_action_just_pressed("jump")

	# Handle attack logic
	if attack_pressed and not is_attacking:
		is_attacking = true
		attack_timer = _get_animation_length(_get_directional_anim("attack", _last_direction))
		_play_directional("attack", _last_direction)
	elif is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false

	# Handle jump logic
	if jump_pressed and is_on_floor():
		velocity.y = jump_force
		jump_timer = _get_animation_length(_get_directional_anim("jump", _last_direction))
	elif jump_timer > 0:
		jump_timer -= delta

	# Handle modes
	match mode:
		"side_scroller":
			_side_scroller_move(input_vec.x, is_sprinting, is_crouching, delta)
		"top_loader":
			_top_loader_move(input_vec, is_sprinting, is_crouching)

	move_and_slide()

func _side_scroller_move(h_input: float, is_sprinting: bool, is_crouching: bool, delta: float):
	velocity.y += gravity * delta
	velocity.x = h_input * (sprint_speed if is_sprinting else speed)

	if h_input != 0:
		sprite.flip_h = h_input < 0

	if is_attacking or jump_timer > 0:
		return
	elif is_crouching:
		_play("crouch")
	elif not is_on_floor():
		_play("jump")
	elif velocity.x != 0:
		_play("sprint" if is_sprinting else "walk")
	else:
		_play("idle")

func _top_loader_move(input_vec: Vector2, is_sprinting: bool, is_crouching: bool):
	var move_dir = input_vec.normalized()
	velocity = move_dir * (sprint_speed if is_sprinting else speed)

	if move_dir != Vector2.ZERO:
		_last_direction = move_dir

	if face_mouse:
		look_at(get_global_mouse_position())

	if is_attacking or jump_timer > 0:
		return
	elif is_crouching:
		_play_directional("crouch", _last_direction)
	elif not is_on_floor():
		_play_directional("jump", _last_direction)
	elif move_dir.length() > 0:
		var base = "sprint" if is_sprinting else "walk"
		_play_directional(base, move_dir)
	else:
		_play_directional("idle", _last_direction)

func _get_direction_label(vec: Vector2) -> String:
	if vec == Vector2.ZERO:
		return "down"

	if direction_mode == "8-way":
		var angle = vec.angle()
		var deg = rad_to_deg(angle)
		if deg < 0: deg += 360

		if deg >= 337.5 or deg < 22.5:
			return "right"
		elif deg < 67.5:
			return "down-right"
		elif deg < 112.5:
			return "down"
		elif deg < 157.5:
			return "down-left"
		elif deg < 202.5:
			return "left"
		elif deg < 247.5:
			return "up-left"
		elif deg < 292.5:
			return "up"
		else:
			return "up-right"
	else:
		if abs(vec.x) > abs(vec.y):
			return "right" if vec.x > 0 else "left"
		else:
			return "down" if vec.y > 0 else "up"

func _get_directional_anim(base: String, dir: Vector2) -> String:
	return base + "-" + _get_direction_label(dir)

func _play(anim: String):
	if sprite and sprite.sprite_frames.has_animation(anim):
		if sprite.animation != anim or not sprite.is_playing():
			sprite.play(anim)

func _play_directional(base: String, dir: Vector2):
	var anim = _get_directional_anim(base, dir)
	_play(anim)

func _get_animation_length(anim: String) -> float:
	if sprite and sprite.sprite_frames.has_animation(anim):
		var frames = sprite.sprite_frames.get_frame_count(anim)
		var fps = sprite.sprite_frames.get_animation_speed(anim)
		return frames / fps if fps > 0 else 0.5
	return 0.5
