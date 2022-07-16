extends KinematicBody2D

signal die

enum State { NORMAL, DASHING }

var gravity = 1000
var velocity = Vector2.ZERO
var max_horizontal_speed =  140
var max_dash_speed = 500
var min_dash_speed = 200
var horizontal_acceleration = 2000
var jump_speed = 360
var jump_termination_multiplier = 4
var has_double_jump = false
var current_state = State.NORMAL
var is_state_new = true

func _process(delta):
	match current_state:
		State.NORMAL:
			process_normal(delta)
		State.DASHING:
			process_dash(delta)
	is_state_new = false

func change_state(new_state):
	current_state = new_state
	is_state_new = true

func process_dash(delta):
	if (is_state_new):
		$AnimatedSprite.play("jump")

		var move_vector = get_movement_vector()
		var velocity_mod = 1
		if (move_vector.x != 0):
			# sign will return 1 or -1 if x is positive or negative.
			velocity_mod = sign(move_vector.x)
		else:
			# when the player is not moving, the dash direction is defined
			# by the animation horizontal position.
			velocity_mod = 1 if $AnimatedSprite.flip_h else -1

		# set the velocity impacted by the modifier value, 1 or -1.
		velocity = Vector2(max_dash_speed * velocity_mod, 0)

	velocity = move_and_slide(velocity, Vector2.UP)
	# decelerate the dash.
	velocity.x = lerp(0, velocity.x, pow(2, -8 * delta))

	# abs is used to return the absolute value to deal with positive and
	# negative values of X.
	if (abs(velocity.x) <= min_dash_speed):
		call_deferred("change_state", State.NORMAL)

func process_normal(delta):
	var move_vector = get_movement_vector()
	
	velocity.x += move_vector.x * horizontal_acceleration * delta
	if (move_vector.x == 0):
		velocity.x = lerp(0, velocity.x, pow(2, -50 * delta))
	
	velocity.x = clamp(velocity.x, -max_horizontal_speed, max_horizontal_speed)

	if (move_vector.y < 0 && (is_on_floor() || !$CayoteTimer.is_stopped() || has_double_jump)):
		velocity.y = move_vector.y * jump_speed
		if !is_on_floor() && $CayoteTimer.is_stopped():
			has_double_jump = false

		$CayoteTimer.stop()

	### This controls the jump height.
	# The jump height is defined by the amount of time the key is being held.
	if (velocity.y < 0 && !Input.is_action_pressed("jump")):
		velocity.y += gravity * jump_termination_multiplier * delta
	else:
		velocity.y += gravity * delta

	var was_on_floor = is_on_floor()
	# The up direction (Vector.UP) is required for the object to identify when
	# it is_on_floor.
	velocity = move_and_slide(velocity, Vector2.UP)

	if (was_on_floor && !is_on_floor()):
		$CayoteTimer.start()

	if is_on_floor():
		has_double_jump = true

	if (Input.is_action_just_pressed("dash")):
		# call_deferred will be called only when the frame process is finished.
		call_deferred("change_state", State.DASHING)

	update_animation()

func get_movement_vector() -> Vector2:
	var move_vector = Vector2.ZERO
	move_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")	
	# Multiply by -1 because we want to go up in Y.
	move_vector.y = -1 if Input.is_action_just_pressed("jump") else 0
	return move_vector

func update_animation():
	var move_vector = get_movement_vector()
	
	if (!is_on_floor()):
		$AnimatedSprite.play("jump")
	elif (move_vector.x != 0):
		$AnimatedSprite.flip_h = true if move_vector.x > 0 else false
		$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.play("idle")

func _on_HazardArea_area_entered(_area):
	emit_signal("die")
