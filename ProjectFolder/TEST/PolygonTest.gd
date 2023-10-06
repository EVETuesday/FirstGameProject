extends Polygon2D


@onready var collision_polygon_2d = $".."
@onready var polygon_2d = $"."

func _ready():
	polygon_2d.polygon = collision_polygon_2d.polygon

