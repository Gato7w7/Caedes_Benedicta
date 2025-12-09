extends Control
@onready var controls: Node2D = $controls

func _on_attack_pressed() -> void:
	$Attack.modulate= Color(1, 0.5, 0.5)

func _on_attack_released() -> void:
	$Attack.modulate= Color(1, 1, 1)

func _on_left_pressed() -> void:
	$Left.modulate= Color(1, 0.5, 0.5)

func _on_right_pressed() -> void:
	$Right.modulate= Color(1, 0.5, 0.5)

func _on_down_pressed() -> void:
	$Down.modulate= Color(1, 0.5, 0.5)

func _on_up_pressed() -> void:
	$Up.modulate= Color(1, 0.5, 0.5)

func _on_left_released() -> void:
	$Left.modulate= Color(1, 1, 1)

func _on_right_released() -> void:
	$Right.modulate= Color(1, 1, 1)

func _on_down_released() -> void:
	$Down.modulate= Color(1, 1, 1)

func _on_up_released() -> void:
	$Up.modulate= Color(1, 1, 1)

func _ready():
	if OS.get_name() == "Android":
		controls.show()
	else:
		controls.hide()
