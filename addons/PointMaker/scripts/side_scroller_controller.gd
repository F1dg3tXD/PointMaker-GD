extends CharacterBody2D
class_name PointSideScroller2D

@export var speed: float = 200.0
@export var sprint_speed: float = 300.0
@export var jump_force: float = -400.0
@export var gravity: float = 1000.0
@export var animated_sprite_path: NodePath

var sprite: AnimatedSprite2D
var is_sprinting := false
var is_crouching := false
var is_attacking := false

func _ready():
	sprite = get_node_or_null(animated_sprite_path)
	if not sprite:
		push_error("❌ AnimatedSprite2D not found.")

func _physics_process(delta):
	is_sprinting = Input.is_action_pressed("sprint")
	is_crouching = Input.is_action_pressed("crouch")
	is_attacking = Input.is_action_pressed("attack")

	var h_input = Input.get_action_strength("walk-right") - Input.get_action_strength("walk-left")

	velocity.y += gravity * delta
	velocity.x = h_input * (sprint_speed if is_sprinting else speed)

	if is_on_floor() and Input.is_action_just_pressed("jump") and not is_crouching:
		velocity.y = jump_force

	# Flip sprite for left/right
	if sprite and h_input != 0:
		sprite.flip_h = h_input < 0

	# Animations
	if is_attacking:
		_play("attack")
	elif is_crouching:
		_play("crouch")
	elif not is_on_floor():
		_play("jump")
	elif velocity.x != 0:
		_play("sprint" if is_sprinting else "walk")
	else:
		_play("idle")

	move_and_slide()

func _play(anim_name: String):
	if sprite and sprite.sprite_frames.has_animation(anim_name):
		if sprite.animation != anim_name:
			sprite.play(anim_name)
