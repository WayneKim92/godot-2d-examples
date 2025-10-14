extends Sprite2D

var shader_material: ShaderMaterial

func _ready():
	# 셰이더 머티리얼 가져오기
	shader_material = material as ShaderMaterial
	print("Icon에 그리드 셰이더가 적용되었습니다!")
	print("스페이스바로 Icon의 그리드 크기를 변경할 수 있습니다.")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			# 그리드 크기 변경 (4x4, 8x8, 16x16 순환)
			var current_size = shader_material.get_shader_parameter("grid_size")
			var new_size = 4 if current_size == 16 else (current_size * 2)
			shader_material.set_shader_parameter("grid_size", new_size)
			print("Icon 그리드 크기 변경: ", new_size, "x", new_size)
			get_parent().update_ui_labels()

# 외부에서 Icon의 셰이더 파라미터를 조정할 수 있는 함수들
func set_grid_size(size: int):
	shader_material.set_shader_parameter("grid_size", clamp(size, 1, 16))

func set_grid_line_width(width: float):
	shader_material.set_shader_parameter("grid_line_width", clamp(width, 0.0, 0.1))

func set_grid_line_color(color: Color):
	shader_material.set_shader_parameter("grid_line_color", color)
