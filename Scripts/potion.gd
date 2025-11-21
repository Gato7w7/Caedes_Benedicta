extends Area2D

@onready var sprite = $AnimatedSprite2D
@export var heal_amount := 40

func _ready():
	sprite.play("idle")
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.has_method("heal"):
		body.heal(heal_amount)
		queue_free()
