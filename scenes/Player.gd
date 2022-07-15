extends KinematicBody2D

signal die

var gravity = 1000
var velocity = Vector2.ZERO
var max_horizontal_speed =  140
var horizontal_acceleration = 2000
var jump_speed = 360
var jump_termination_multiplier = 4
var has_double_jump = false

func _ready():
	pass # Replace with function body.

func _process(delta):
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
	# The jump height is defined by the amount of time the key is being held
	if (velocity.y < 0 && !Input.is_action_pressed("jump")):
		velocity.y += gravity * jump_termination_multiplier * delta
	else:
		velocity.y += gravity * delta

	var was_on_floor = is_on_floor()
	# The up direction (Vector.UP) is required for the object to identify when
	# it is_on_floor 
	velocity = move_and_slide(velocity, Vector2.UP)

	if (was_on_floor && !is_on_floor()):
		$CayoteTimer.start()

	if is_on_floor():
		has_double_jump = true

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
