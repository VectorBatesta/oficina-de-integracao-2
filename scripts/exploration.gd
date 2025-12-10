extends Control

var battery


func _ready():
	pass




func _on_cancel_pressed() -> void:
	self.queue_free()
