extends Area2D

@onready var game_manager: Node = %GameManager

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	game_manager.add_point()
	queue_free()
