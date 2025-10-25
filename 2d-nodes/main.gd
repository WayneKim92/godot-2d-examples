extends Node2D

# Unique Name (%) 사용 - 계층구조 변경에 독립적! ⭐
@onready var animatable_body = %AnimatableBody2D
@onready var pin_joint_bulb = %PinJointBulb
@onready var bouncy_spring_bulb = %BouncySpringBulb
@onready var groove_joint_bulb = %GrooveJointBulb
@onready var area_2d = %Area2D
@onready var status_label = %StatusLabel
@onready var canvas_modulate = %CanvasModulate
@onready var character_body = $CharacterBody2D
@onready var animatable_body_with = %AnimatableBodyWithLight

var time_elapsed: float = 0.0
# 각 노드의 원본 위치를 저장하는 딕셔너리
var original_positions: Dictionary = {}
# 각 노드의 tween을 저장하는 딕셔너리
var tweens: Dictionary = {}

# 조명 색상 상수
const COLOR_OUTSIDE = Color("#454545")  # 어두운 색상
const COLOR_INSIDE = Color("#ffffff")   # 밝은 색상

# Area2D 크기 (씬에서 설정된 크기와 일치시켜야 함)
var area_radius: float = 0.0

func _ready():
	# Area2D 반경 계산
	calculate_area_radius()
	
	# 애니메이션 시작
	# 원본 위치 저장
	start_position_animation(animatable_body)
	start_position_animation(animatable_body_with, Vector2(100, 0))
	
	# 조인트별 특별한 설정 적용
	setup_joint_behaviors()
	
	# Area2D 신호 연결
	setup_area_detection()
	
	# 초기 조명 색상 설정
	update_lighting_based_on_distance()

func _process(delta):
	time_elapsed += delta
	
	# GrooveJoint의 초기 오프셋을 시간에 따라 변경
	if groove_joint_bulb:
		var offset_variation = sin(time_elapsed * 0.3) * 20.0
		groove_joint_bulb.initial_offset = 50.0 + offset_variation
	
	# 실시간으로 거리 기반 조명 업데이트
	update_lighting_based_on_distance()

func setup_joint_behaviors():
	# PinJoint 전구에 초기 임펄스 적용
	if pin_joint_bulb and pin_joint_bulb.get_node("RigidBody2D"):
		var pin_body = pin_joint_bulb.get_node("RigidBody2D") as RigidBody2D
		# 0.1초 후에 임펄스 적용 (씬이 완전히 로드된 후)
		await get_tree().create_timer(0.1).timeout
		pin_body.apply_impulse(Vector2(100, 0))
	
	# 바운시 스프링에도 초기 임펄스 적용
	if bouncy_spring_bulb and bouncy_spring_bulb.get_node("RigidBody2D"):
		var bouncy_body = bouncy_spring_bulb.get_node("RigidBody2D") as RigidBody2D
		await get_tree().create_timer(0.2).timeout
		bouncy_body.apply_impulse(Vector2(150, -50))
	
	# GrooveJoint 전구에 초기 흔들림 적용
	if groove_joint_bulb and groove_joint_bulb.get_node("RigidBody2D"):
		var groove_body = groove_joint_bulb.get_node("RigidBody2D") as RigidBody2D
		await get_tree().create_timer(0.3).timeout
		groove_body.apply_impulse(Vector2(80, 0))

func start_position_animation(node, direction: Vector2 = Vector2(0, -100)):
	# 처음 호출 시 원본 위치 저장
	if not original_positions.has(node):
		original_positions[node] = node.position
	
	# 해당 노드의 기존 트윈이 있으면 중지
	if tweens.has(node) and tweens[node]:
		tweens[node].kill()
	
	# 새 트윈 생성 및 저장
	var tween = create_tween()
	tweens[node] = tween
	tween.set_loops() # 무한 반복ㅎ
	
	# 저장된 원본 위치 사용
	var original_position = original_positions[node]
	# 지정된 방향으로 이동했다가 다시 돌아오기 (1초 동안)
	var target_position = original_position + direction
	tween.tween_property(node, "position", target_position, 0.5)
	tween.tween_property(node, "position", original_position, 0.5)
	
	# 트윈 설정 (부드러운 애니메이션을 위한 이징)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)

# 조인트 특성을 실시간으로 조정하는 함수들
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				# Pin Joint 전구에 임펄스 적용
				apply_impulse_to_bulb(pin_joint_bulb)
			KEY_2:
				# Bouncy Spring 강성도 조정
				adjust_bouncy_spring()
			KEY_3:
				# Groove Joint에 임펄스 적용
				apply_impulse_to_bulb(groove_joint_bulb)
			KEY_4:
				# 모든 전구에 흔들림 적용
				shake_all_bulbs()
			KEY_5:
				# Bouncy Spring 감쇠 조정
				adjust_spring_damping()

func apply_impulse_to_bulb(joint_node):
	if joint_node and joint_node.get_node("RigidBody2D"):
		var body = joint_node.get_node("RigidBody2D") as RigidBody2D
		var random_impulse = Vector2(randf_range(-200, 200), randf_range(-100, 100))
		body.apply_impulse(random_impulse)

func adjust_bouncy_spring():
	if bouncy_spring_bulb:
		# 바운시 스프링의 강성도를 50에서 150 사이로 순환
		var current_stiffness = bouncy_spring_bulb.stiffness
		bouncy_spring_bulb.stiffness = 50.0 if current_stiffness > 100.0 else 150.0
		print("Bouncy spring stiffness: ", bouncy_spring_bulb.stiffness)

func adjust_spring_damping():
	if bouncy_spring_bulb:
		# 감쇠값을 0.2에서 1.0 사이로 순환
		var current_damping = bouncy_spring_bulb.damping
		bouncy_spring_bulb.damping = 0.2 if current_damping > 0.6 else 1.0
		print("Bouncy spring damping: ", bouncy_spring_bulb.damping)

func shake_all_bulbs():
	# 모든 전구에 랜덤 임펄스 적용
	apply_impulse_to_bulb(pin_joint_bulb)
	apply_impulse_to_bulb(bouncy_spring_bulb)
	apply_impulse_to_bulb(groove_joint_bulb)
	print("All bulbs shaken!")

# Area2D 감지 설정
func setup_area_detection():
	if area_2d:
		area_2d.body_entered.connect(_on_area_2d_body_entered)
		area_2d.body_exited.connect(_on_area_2d_body_exited)
		print("Area2D 감지 시스템 초기화 완료")

# Area2D의 반경 계산
func calculate_area_radius():
	if area_2d and area_2d.get_node("CollisionShape2D"):
		var collision_shape = area_2d.get_node("CollisionShape2D")
		var shape = collision_shape.shape
		
		if shape is RectangleShape2D:
			var rect_shape = shape as RectangleShape2D
			# 사각형의 경우 대각선의 절반을 반경으로 사용
			area_radius = rect_shape.size.length() / 2.0
		elif shape is CircleShape2D:
			var circle_shape = shape as CircleShape2D
			area_radius = circle_shape.radius
		
		print("Area2D 반경: ", area_radius)

# 거리 기반으로 조명 업데이트
func update_lighting_based_on_distance():
	if not area_2d or not character_body or not canvas_modulate:
		return
	
	# Area2D 중심과 캐릭터 사이의 거리 계산
	var area_center = area_2d.global_position
	var character_position = character_body.global_position
	var distance = area_center.distance_to(character_position)
	
	# 거리를 0~1 범위로 정규화 (0 = 중심, 1 = 반경 밖)
	var normalized_distance = clamp(distance / area_radius, 0.0, 1.0)
	
	# 거리에 따라 색상 보간 (lerp)
	# normalized_distance가 0이면 밝은 색, 1이면 어두운 색
	var target_color = COLOR_INSIDE.lerp(COLOR_OUTSIDE, normalized_distance)
	canvas_modulate.color = target_color
	
	# 상태 라벨 업데이트
	update_status_label(normalized_distance)

# 상태 라벨 업데이트
func update_status_label(normalized_distance: float):
	if normalized_distance < 0.3:
		status_label.text = "캐릭터가 영역 중심에 있습니다!"
		status_label.modulate = Color.GREEN
	elif normalized_distance < 1.0:
		status_label.text = "캐릭터가 영역 가장자리에 있습니다!"
		status_label.modulate = Color.YELLOW
	else:
		status_label.text = "캐릭터가 영역 밖에 있습니다!"
		status_label.modulate = Color.RED

# 캐릭터가 Area2D에 진입했을 때
func _on_area_2d_body_entered(body):
	if body.name == "CharacterBody2D":
		pass  # 실시간 업데이트로 처리됨

# 캐릭터가 Area2D에서 나갔을 때
func _on_area_2d_body_exited(body):
	if body.name == "CharacterBody2D":
		pass  # 실시간 업데이트로 처리됨
