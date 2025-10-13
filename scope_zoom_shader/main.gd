extends Node2D

@onready var icon: Sprite2D = $Icon
var tween: Tween

func _ready():
	print("=== 스크립트 시작 ===")
	print("아이콘 노드: ", icon)
	
	# 셰이더 머티리얼 설정
	setup_zoom_shader()
	
	# 부분 확대 효과 시작
	if icon.material:
		start_partial_zoom_effect()
	else:
		print("셰이더 설정 실패 - 애니메이션 시작 안 함")

func setup_zoom_shader():
	print("\n=== 셰이더 설정 시작 ===")
	
	# 셰이더 리소스 로드
	var shader = load("res://zoom_shader.gdshader")
	print("셰이더 로드 결과: ", shader)
	
	if not shader:
		print("❌ 셰이더 로드 실패!")
		return
	
	# ShaderMaterial 생성
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	print("✅ ShaderMaterial 생성됨")
	
	# 아이콘에 머티리얼 적용
	icon.material = shader_material
	print("✅ 아이콘에 머티리얼 적용됨")
	
	# uniform 파라미터 설정 (아이콘 정중앙으로 변경)
	icon.material.set_shader_parameter("zoom_factor", 1.0)
	icon.material.set_shader_parameter("zoom_area_min", Vector2(0.1, 0.1))  # 중앙 영역 시작
	icon.material.set_shader_parameter("zoom_area_max", Vector2(0.9, 0.9))  # 중앙 영역 끝
	icon.material.set_shader_parameter("edge_softness", 0.08)
	icon.material.set_shader_parameter("show_border", true)
	# icon.material.set_shader_parameter("border_width", 0.01)
	print("✅ 셰이더 파라미터 설정 완료")
	
	print("=== 셰이더 설정 완료 ===\n")

func start_partial_zoom_effect():
	print("=== 줌 애니메이션 시작 ===")
	
	# 기존 Tween이 있다면 제거
	if tween:
		tween.kill()
	
	# 새로운 Tween 생성
	tween = create_tween()
	tween.set_loops() # 무한 반복
	
	# 줌 팩터 애니메이션 (1.0 → 1.25 → 1.0)
	tween.tween_method(update_zoom_factor, 1.0, 1.15, 1.25)
	tween.tween_method(update_zoom_factor, 1.15, 1.0, 1.25)
	
	# 부드러운 효과
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	print("✅ Tween 설정 완료\n")

func update_zoom_factor(zoom_value: float):
	if icon.material:
		icon.material.set_shader_parameter("zoom_factor", zoom_value)