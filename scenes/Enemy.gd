extends KinematicBody2D

enum Direction { RIGHT, LEFT }
export (Direction) var start_direction

var max_speed = 25
var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var gravity = 500

func _ready():
	direction = Vector2.RIGHT if start_direction == Direction.RIGHT else Vector2.LEFT
	$AnimatedSprite.play("run")

func _process(delta):
	velocity.x = (direction * max_speed).x
	
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	$AnimatedSprite.flip_h = true if direction.x > 0 else false

func _on_GoalDetector_area_entered(_area):
	direction *= -1
