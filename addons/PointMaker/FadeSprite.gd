extends Sprite2D

@export var fade_duration: float = 2.0
@export var is_playing: bool = true
@export var is_looping: bool = true

# Internal fade control
var fading_in := true
var timer := 0.0

# This allows the Animation Editor to override the opacity manually
@export var fade_opacity: float:
	get:
		return modulate.a
	set(value):
		modulate.a = clamp(value, 0.0, 1.0)

func _process(delta):
	if not is_playing or fade_duration <= 0.0:
		return

	timer += delta
	var t := timer / fade_duration
	t = clamp(t, 0.0, 1.0)

	var alpha := t if fading_in else 1.0 - t
	fade_opacity = alpha

	if timer >= fade_duration:
		if is_looping:
			fading_in = !fading_in
			timer = 0.0
		else:
			is_playing = false
