extends Node2D

@onready var man: Sprite2D = $Man
var tween: Tween

func _ready():
	print("=== 스크립트 시작 ===")
	print("Man 노드: ", man)
	
	# 셰이더 머티리얼 설정
	setup_zoom_shader()
	
	# 부분 확대 효과 시작
	if man.material:
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
	
	# man 스프라이트에 머티리얼 적용
	man.material = shader_material
	print("✅ man 스프라이트에 머티리얼 적용됨")
	
	# uniform 파라미터 설정 (32x32 작은 애셋에 맞게 조정)
	man.material.set_shader_parameter("zoom_factor", 1.0)
	man.material.set_shader_parameter("zoom_area_min", Vector2(0.405, 0.45))  # 더 넓은 범위로
	man.material.set_shader_parameter("zoom_area_max", Vector2(0.595, 0.575))  # 더 넓은 범위로
	man.material.set_shader_parameter("show_border", false)  # 경계선 표시
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
	tween.tween_method(update_zoom_factor, 1.0, 1.3, 0.75)
	tween.tween_method(update_zoom_factor, 1.3, 1.0, 0.75)
	
	# 부드러운 효과
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	print("✅ Tween 설정 완료\n")

func update_zoom_factor(zoom_value: float):
	if man.material:
		man.material.set_shader_parameter("zoom_factor", zoom_value)
