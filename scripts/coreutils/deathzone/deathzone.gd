extends Area2D

func _ready() -> void:
	self.body_entered.connect(func (body):
		if body is Player:
			Player.instance.global_position = Player.init_position
	)
