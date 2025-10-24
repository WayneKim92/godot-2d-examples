extends Node2D

@onready var animatable_body = $Platforms/AnimatableBody2D
@onready var pin_joint_bulb = $ElectricBulbs/PinJointBulb
@onready var bouncy_spring_bulb = $ElectricBulbs/BouncySpringBulb
@onready var groove_joint_bulb = $ElectricBulbs/GrooveJointBulb

var tween: Tween
var original_position: Vector2
var time_elapsed: float = 0.0

func _ready():
	# 원본 위치 저장
	original_position = animatable_body.position
	
	# 애니메이션 시작
	start_position_animation()
	
	# 조인트별 특별한 설정 적용
	setup_joint_behaviors()

func _process(delta):
	time_elapsed += delta
	
	# GrooveJoint의 초기 오프셋을 시간에 따라 변경
	if groove_joint_bulb:
		var offset_variation = sin(time_elapsed * 0.3) * 20.0
		groove_joint_bulb.initial_offset = 50.0 + offset_variation

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

func start_position_animation():
	# 기존 트윈이 있으면 중지
	if tween:
		tween.kill()
	
	# 새 트윈 생성
	tween = create_tween()
	tween.set_loops() # 무한 반복
	
	# y 위치를 원본에서 50픽셀 위로 올렸다가 다시 내리기 (1초 동안)
	tween.tween_property(animatable_body, "position:y", original_position.y - 100, 0.5)
	tween.tween_property(animatable_body, "position:y", original_position.y, 0.5)
	
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