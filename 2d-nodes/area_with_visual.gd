@tool
extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var color_rect: ColorRect = $CollisionShape2D/ColorRect

func _ready() -> void:
	sync_color_rect_to_collision()
	
	# CollisionShape2D의 shape가 변경될 때마다 동기화 (선택사항)
	# 런타임에 크기가 바뀔 경우에만 필요
	if collision_shape.shape:
		collision_shape.shape.changed.connect(sync_color_rect_to_collision)

func sync_color_rect_to_collision() -> void:
	if not collision_shape or not collision_shape.shape or not color_rect:
		return
	
	var shape = collision_shape.shape
	
	if shape is RectangleShape2D:
		var rect_shape = shape as RectangleShape2D
		var shape_size = rect_shape.size
		
		# ColorRect의 크기를 CollisionShape2D와 동일하게 설정
		color_rect.size = shape_size
		
		# ColorRect를 중앙에 배치 (pivot을 중심으로)
		color_rect.position = -shape_size / 2.0
		
	elif shape is CircleShape2D:
		var circle_shape = shape as CircleShape2D
		var diameter = circle_shape.radius * 2.0
		
		color_rect.size = Vector2(diameter, diameter)
		color_rect.position = Vector2(-circle_shape.radius, -circle_shape.radius)
