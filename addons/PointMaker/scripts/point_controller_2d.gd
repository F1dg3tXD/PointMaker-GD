@tool
extends CharacterBody2D

@export_enum("side_scroller", "top_loader") var mode: String = "side_scroller" # "side_scroller" or "top_loader"
@export var speed: float = 200.0
@export var sprint_speed: float = 300.0
@export var jump_force: float = -400.0
@export var gravity: float = 1000.0
@export var animation_player_path: NodePath

var is_sprinting := false
var is_crouching := false
var is_attacking := false

func _physics_process(delta):
	is_sprinting = Input.is_action_pressed("sprint")
	is_attacking = Input.is_action_just_pressed("attack")
	is_crouching = Input.is_action_pressed("crouch")

	match mode:
		"side_scroller":
			_side_scroller_movement(delta)
		"top_loader":
			_top_loader_movement(delta)

func _side_scroller_movement(delta):
	velocity.y += gravity * delta
	var h_input := Input.get_action_strength("walk-right") - Input.get_action_strength("walk-left")
	velocity.x = h_input * (sprint_speed if is_sprinting else speed)

	if is_on_floor() and Input.is_action_just_pressed("jump") and not is_crouching:
		velocity.y = jump_force

	if is_attacking:
		_play_animation("attack")
	elif is_crouching:
		_play_animation("crouch")
	elif not is_on_floor():
		_play_animation("jump")
	elif velocity.x != 0:
		_play_animation("sprint" if is_sprinting else "walk")
	else:
		_play_animation("idle")

	move_and_slide()

func _top_loader_movement(delta):
	var move_vec := Vector2.ZERO
	move_vec.x = Input.get_action_strength("walk-right") - Input.get_action_strength("walk-left")
	move_vec.y = Input.get_action_strength("walk-down") - Input.get_action_strength("walk-up")
	move_vec = move_vec.normalized() * (sprint_speed if is_sprinting else speed)
	velocity = move_vec
	
	if move_vec.length() > 0:
		_play_animation("sprint" if is_sprinting else "walk")
	else:
		_play_animation("idle")

	if is_attacking:
		_play_animation("attack")

	look_at(get_global_mouse_position())
	move_and_slide()

func _play_animation(anim: String):
	var anim_player := get_node_or_null(animation_player_path)
	if anim_player and anim_player is AnimationPlayer:
		if anim_player.has_animation(anim):
			if anim_player.current_animation != anim:
				anim_player.play(anim)
