extends Node2D

@onready var animatable_body = $Platforms/AnimatableBody2D
@onready var pin_joint_bulb = $ElectricBulbs/PinJointBulb
@onready var spring_joint_bulb = $ElectricBulbs/SpringJointBulb
@onready var hinge_joint_bulb = $ElectricBulbs/HingeJointBulb
@onready var chain_bulb = $ElectricBulbs/ChainBulb
@onready var bouncy_spring_bulb = $ElectricBulbs/BouncySpringBulb

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
	
	# 힌지 조인트 모터 방향 주기적으로 변경 (진자 운동)
	if hinge_joint_bulb:
		var motor_velocity = sin(time_elapsed * 0.5) * 3.0
		hinge_joint_bulb.motor_target_velocity = motor_velocity

func setup_joint_behaviors():
	# 스프링 조인트에 초기 임펄스 적용하여 흔들기 시작
	if spring_joint_bulb and spring_joint_bulb.get_node("RigidBody2D"):
		var spring_body = spring_joint_bulb.get_node("RigidBody2D") as RigidBody2D
		# 0.1초 후에 임펄스 적용 (씬이 완전히 로드된 후)
		await get_tree().create_timer(0.1).timeout
		spring_body.apply_impulse(Vector2(100, 0))
	
	# 바운시 스프링에도 초기 임펄스 적용
	if bouncy_spring_bulb and bouncy_spring_bulb.get_node("RigidBody2D"):
		var bouncy_body = bouncy_spring_bulb.get_node("RigidBody2D") as RigidBody2D
		await get_tree().create_timer(0.2).timeout
		bouncy_body.apply_impulse(Vector2(150, -50))
	
	# 체인 전구에 초기 흔들림 적용
	if chain_bulb and chain_bulb.get_node("ChainLink1"):
		var chain_link = chain_bulb.get_node("ChainLink1") as RigidBody2D
		await get_tree().create_timer(0.3).timeout
		chain_link.apply_impulse(Vector2(80, 0))

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
				# Spring Joint 강성도 조정
				adjust_spring_stiffness()
			KEY_3:
				# Hinge Joint 각도 제한 토글
				toggle_hinge_limits()
			KEY_4:
				# Chain Bulb에 흔들림 적용
				shake_chain_bulb()
			KEY_5:
				# Bouncy Spring 강성도 조정
				adjust_bouncy_spring()

func apply_impulse_to_bulb(joint_node):
	if joint_node and joint_node.get_node("RigidBody2D"):
		var body = joint_node.get_node("RigidBody2D") as RigidBody2D
		var random_impulse = Vector2(randf_range(-200, 200), randf_range(-100, 100))
		body.apply_impulse(random_impulse)

func adjust_spring_stiffness():
	if spring_joint_bulb:
		# 강성도를 20에서 80 사이로 순환
		var current_stiffness = spring_joint_bulb.stiffness
		spring_joint_bulb.stiffness = 20.0 if current_stiffness > 50.0 else 80.0
		print("Spring stiffness: ", spring_joint_bulb.stiffness)

func toggle_hinge_limits():
	if hinge_joint_bulb:
		hinge_joint_bulb.angular_limit_enabled = !hinge_joint_bulb.angular_limit_enabled
		print("Hinge limits: ", "ON" if hinge_joint_bulb.angular_limit_enabled else "OFF")

func shake_chain_bulb():
	if chain_bulb:
		# 체인의 각 링크에 랜덤 임펄스 적용
		for node_name in ["ChainLink1", "ChainLink2", "FinalBulb"]:
			var node = chain_bulb.get_node(node_name)
			if node and node is RigidBody2D:
				var body = node as RigidBody2D
				var random_impulse = Vector2(randf_range(-150, 150), randf_range(-50, 50))
				body.apply_impulse(random_impulse)
		print("Chain shaken!")

func adjust_bouncy_spring():
	if bouncy_spring_bulb:
		# 바운시 스프링의 강성도를 50에서 150 사이로 순환
		var current_stiffness = bouncy_spring_bulb.stiffness
		bouncy_spring_bulb.stiffness = 50.0 if current_stiffness > 100.0 else 150.0
		print("Bouncy spring stiffness: ", bouncy_spring_bulb.stiffness)
