extends Node2D

@onready var grid_example = $GridExample
@onready var icon = $Icon
@onready var grid_label = $UI/GridLabel
@onready var icon_label = $UI/IconLabel
var shader_material: ShaderMaterial
var icon_shader_material: ShaderMaterial
var grid_shader_class = preload("res://16x16-grid-2d-shader/grid_shader_resource.gd")

func _ready():
	# 셰이더 머티리얼 가져오기
	shader_material = grid_example.material as ShaderMaterial
	icon_shader_material = icon.material as ShaderMaterial
	
	# 강제로 셰이더 파라미터 초기화 (TSCN에서 사라지는 문제 해결)
	if shader_material:
		shader_material.set_shader_parameter("grid_size", 4)
		shader_material.set_shader_parameter("grid_line_width", 0.02)
		shader_material.set_shader_parameter("grid_line_color", Color.BLACK)
		shader_material.set_shader_parameter("cell_alpha", 0.8)
		shader_material.set_shader_parameter("use_texture_blend", false)
		shader_material.set_shader_parameter("texture_blend_amount", 0.5)
	
	if icon_shader_material:
		icon_shader_material.set_shader_parameter("grid_size", 8)
		icon_shader_material.set_shader_parameter("grid_line_width", 0.01)
		icon_shader_material.set_shader_parameter("grid_line_color", Color.WHITE)
		icon_shader_material.set_shader_parameter("cell_alpha", 0.6)
		icon_shader_material.set_shader_parameter("use_texture_blend", true)
		icon_shader_material.set_shader_parameter("texture_blend_amount", 0.5)
	
	print("4x4 격자 셰이더가 적용되었습니다!")
	print("마우스 클릭으로 그리드 크기를 변경할 수 있습니다.")
	print("Icon에도 그리드 셰이더가 적용되었습니다!")
	print("스페이스바로 Icon 그리드 크기를 변경할 수 있습니다.")
	print("B키로 Icon의 텍스처 혼합 강도를 조절할 수 있습니다.")
	print("R키로 랜덤 색상 모드를 토글할 수 있습니다.")
	print("C키로 새로운 랜덤 색상을 생성할 수 있습니다.")
	
	# 디버깅: 셰이더 파라미터 상태 출력
	print("=== 셰이더 파라미터 상태 ===")
	if icon_shader_material:
		print("Icon 텍스처 혼합 모드: ", icon_shader_material.get_shader_parameter("use_texture_blend"))
		print("Icon 혼합 강도: ", icon_shader_material.get_shader_parameter("texture_blend_amount"))
		print("Icon 그리드 크기: ", icon_shader_material.get_shader_parameter("grid_size"))
	else:
		print("Icon 셰이더 머티리얼을 찾을 수 없습니다!")
	
	# 초기 UI 업데이트
	update_ui_labels()

func setup_default_colors():
	# 기본 색상 배열 설정 (이미 셰이더에 정의되어 있지만 코드로도 설정 가능)
	var colors = [
		Color.RED,      Color.GREEN,    Color.BLUE,     Color.YELLOW,
		Color.MAGENTA,  Color.CYAN,     Color.ORANGE,   Color.PURPLE,
		Color.LIME,     Color.PINK,     Color.CORNFLOWER_BLUE, Color.LIGHT_GRAY,
		Color.GRAY,     Color.SADDLE_BROWN, Color.MISTY_ROSE, Color.LIGHT_GREEN
	]
	
	# 셰이더에 색상 배열 전달
	shader_material.set_shader_parameter("cell_colors", colors)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# 그리드 크기 변경 (2x2, 4x4, 8x8 순환)
			var current_size = shader_material.get_shader_parameter("grid_size")
			var new_size = 2 if current_size == 8 else (current_size * 2)
			shader_material.set_shader_parameter("grid_size", new_size)
			print("그리드 크기 변경: ", new_size, "x", new_size)
			update_ui_labels()
		
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# 그리드 라인 두께 변경
			var current_width = shader_material.get_shader_parameter("grid_line_width")
			var new_width = 0.01 if current_width >= 0.05 else (current_width + 0.01)
			shader_material.set_shader_parameter("grid_line_width", new_width)
			print("그리드 라인 두께: ", new_width)
	
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_B:
			# B 키로 Icon의 텍스처 혼합 강도 조절
			adjust_icon_blend_amount()
		
		elif event.keycode == KEY_R:
			# R 키로 랜덤 색상 모드 토글
			toggle_random_colors()
		
		elif event.keycode == KEY_C:
			# C 키로 새로운 랜덤 색상 생성
			randomize_colors()

# 셰이더 파라미터를 외부에서 조정할 수 있는 함수들
func set_grid_size(size: int):
	shader_material.set_shader_parameter("grid_size", clamp(size, 1, 16))

func set_grid_line_width(width: float):
	shader_material.set_shader_parameter("grid_line_width", clamp(width, 0.0, 0.1))

func set_grid_line_color(color: Color):
	shader_material.set_shader_parameter("grid_line_color", color)

func set_cell_color(_index: int, _color: Color):
	# 기본 색상은 셰이더에 하드코딩되어 있음
	# 이 함수는 호환성을 위해 유지하지만 실제로는 작동하지 않음
	print("셀 색상 변경 기능은 현재 하드코딩된 색상을 사용합니다")

# Icon의 텍스처 혼합 강도를 조절하는 함수
func adjust_icon_blend_amount():
	var current_amount = icon_shader_material.get_shader_parameter("texture_blend_amount")
	if current_amount == null:
		current_amount = 0.5
	var new_amount = 0.2 if current_amount >= 0.8 else (current_amount + 0.2)
	icon_shader_material.set_shader_parameter("texture_blend_amount", new_amount)
	print("Icon 텍스처 혼합 강도: ", new_amount)
	update_ui_labels()

# Icon의 텍스처 혼합 설정을 외부에서 제어할 수 있는 함수들
func set_icon_texture_blend(enabled: bool):
	icon_shader_material.set_shader_parameter("use_texture_blend", enabled)

func set_icon_blend_amount(amount: float):
	icon_shader_material.set_shader_parameter("texture_blend_amount", clamp(amount, 0.0, 1.0))

# 랜덤 색상 모드 토글
func toggle_random_colors():
	var grid_random = shader_material.get_shader_parameter("use_random_colors")
	
	var new_random = not (grid_random if grid_random != null else false)
	shader_material.set_shader_parameter("use_random_colors", new_random)
	icon_shader_material.set_shader_parameter("use_random_colors", new_random)
	print("랜덤 색상 모드: ", "ON" if new_random else "OFF")
	update_ui_labels()

# 새로운 랜덤 색상 생성
func randomize_colors():
	var new_seed = randf() * 1000.0
	shader_material.set_shader_parameter("random_seed", new_seed)
	icon_shader_material.set_shader_parameter("random_seed", new_seed)
	print("새로운 랜덤 색상 생성됨! (seed: ", new_seed, ")")
	update_ui_labels()

# UI 라벨 업데이트 함수
func update_ui_labels():
	if grid_label and shader_material:
		var grid_size = shader_material.get_shader_parameter("grid_size")
		var random_mode = shader_material.get_shader_parameter("use_random_colors")
		grid_label.text = "GridExample (ColorRect)\nSize: %dx%d | Random: %s" % [
			grid_size, grid_size,
			"ON" if random_mode else "OFF"
		]
	
	if icon_label and icon_shader_material:
		var icon_size = icon_shader_material.get_shader_parameter("grid_size")
		var blend_enabled = icon_shader_material.get_shader_parameter("use_texture_blend")
		var blend_amount = icon_shader_material.get_shader_parameter("texture_blend_amount")
		var random_mode = icon_shader_material.get_shader_parameter("use_random_colors")
		
		if blend_enabled:
			icon_label.text = "Icon (Sprite2D)\nSize: %dx%d | Blend: ON (%d%%) | Random: %s" % [
				icon_size, icon_size,
				int(blend_amount * 100),
				"ON" if random_mode else "OFF"
			]
		else:
			icon_label.text = "Icon (Sprite2D)\nSize: %dx%d | Blend: OFF | Random: %s" % [
				icon_size, icon_size,
				"ON" if random_mode else "OFF"
			]

# 랜덤 색상 설정을 외부에서 제어할 수 있는 함수들
func set_random_colors(enabled: bool):
	shader_material.set_shader_parameter("use_random_colors", enabled)
	icon_shader_material.set_shader_parameter("use_random_colors", enabled)

func set_random_seed(seed_value: float):
	shader_material.set_shader_parameter("random_seed", seed_value)
	icon_shader_material.set_shader_parameter("random_seed", seed_value)
