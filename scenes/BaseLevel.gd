extends Node2D

var player_scene = preload("res://scenes/Player.tscn")
var current_player_node = null
var spawn_position = Vector2.ZERO

func _ready():
	spawn_position = $Player.global_position
	register_player($Player)

func register_player(player):
	current_player_node = player
	current_player_node.connect("die", self, "on_player_die", [], CONNECT_DEFERRED)

func create_player():
	var player_instance = player_scene.instance()
	add_child_below_node(current_player_node, player_instance)
	player_instance.global_position = spawn_position
	register_player(player_instance)

func on_player_die():
	current_player_node.queue_free()
	create_player()
