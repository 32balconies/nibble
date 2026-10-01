extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var fish_name: String
var sell_price: int

func set_fish_data(fish_data: FishData):
	
	fish_name = fish_data.name
	sell_price = fish_data.sell_value
	animated_sprite.sprite_frames = fish_data.sprite_frames
	animated_sprite.play()
	
