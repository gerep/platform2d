extends Node2D

func _on_Area2D_area_entered(_area):
	$AnimationPlayer.play("pickup")
	call_deferred("disable_pickup")
	# The queue_free call is made by the AnimationPlayer.

func disable_pickup():
	$Area2D/CollisionShape2D.disabled = true
