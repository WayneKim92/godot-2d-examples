extends Node2D

## GridShaderResource 사용 예제

var grid_shader_class = preload("res://16x16-grid-2d-shader/grid_shader_resource.gd")

func _ready():
	# 예제 1: 기본 4x4 격자
	create_basic_grid_example()
	
	# 예제 2: 커스텀 색상 2x2 격자
	create_custom_grid_example()
	
	# 예제 3: 그라디언트 8x8 격자
	create_gradient_grid_example()

func create_basic_grid_example():
	var color_rect = ColorRect.new()
	color_rect.size = Vector2(200, 200)
	color_rect.position = Vector2(50, 50)
	add_child(color_rect)
	
	# GridShaderResource 사용
	var grid_resource = grid_shader_class.new()
	grid_resource.apply_to_node(color_rect)
	
	# 레이블 추가
	var label = Label.new()
	label.text = "기본 4x4 격자"
	label.position = Vector2(50, 20)
	add_child(label)

func create_custom_grid_example():
	var color_rect = ColorRect.new()
	color_rect.size = Vector2(150, 150)
	color_rect.position = Vector2(300, 50)
	add_child(color_rect)
	
	# 커스텀 설정으로 셰이더 리소스 생성
	var grid_resource = grid_shader_class.new()
	grid_resource.set_grid_size(2)  # 2x2 격자
	grid_resource.grid_line_width = 0.05  # 두꺼운 라인
	grid_resource.grid_line_color = Color.WHITE  # 흰색 라인
	
	grid_resource.apply_to_node(color_rect)
	
	# 레이블 추가
	var label = Label.new()
	label.text = "커스텀 2x2 격자"
	label.position = Vector2(300, 20)
	add_child(label)

func create_gradient_grid_example():
	var color_rect = ColorRect.new()
	color_rect.size = Vector2(250, 250)
	color_rect.position = Vector2(500, 50)
	add_child(color_rect)
	
	# 8x8 격자 설정
	var grid_resource = grid_shader_class.new()
	grid_resource.set_grid_size(8)  # 8x8 격자
	grid_resource.grid_line_width = 0.01  # 얇은 라인
	
	grid_resource.apply_to_node(color_rect)
	
	# 레이블 추가
	var label = Label.new()
	label.text = "8x8 격자"
	label.position = Vector2(500, 20)
	add_child(label)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			# R 키로 모든 격자 색상 랜덤화
			randomize_all_grids()

func randomize_all_grids():
	# 모든 ColorRect 자식 노드 찾아서 그리드 라인 색상 변경
	for child in get_children():
		if child is ColorRect and child.material is ShaderMaterial:
			var current_material = child.material as ShaderMaterial
			# 랜덤 그리드 라인 색상 적용
			var random_color = Color(randf(), randf(), randf(), 1.0)
			current_material.set_shader_parameter("grid_line_color", random_color)
	
	print("모든 격자 라인 색상이 랜덤화되었습니다! (R 키로 다시 랜덤화 가능)")