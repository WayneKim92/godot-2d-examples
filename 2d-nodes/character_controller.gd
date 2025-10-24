extends CharacterBody2D

# 물리 상수
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const PUSH_FORCE = 80.0  # 밀어내는 힘

# 중력값 (project settings에서 가져오기)
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# 스프라이트 참조
@onready var sprite = $CollisionShape2D/Sprite2D

func _physics_process(delta):
	# 중력 적용
	if not is_on_floor():
		velocity.y += gravity * delta

	# 점프 처리 (스페이스바)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 좌우 이동 처리 (A, D키)
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		# 이동 방향에 따라 스프라이트 뒤집기
		if direction > 0:  # 오른쪽 이동
			sprite.flip_h = true
		elif direction < 0:  # 왼쪽 이동
			sprite.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# 충돌한 객체들을 밀어내기
	push_objects()

func push_objects():
	# 충돌 정보를 순회하면서 RigidBody2D를 밀어냄
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# RigidBody2D인 경우에만 밀어냄
		if collider is RigidBody2D:
			var push_vector = collision.get_normal() * -PUSH_FORCE
			collider.apply_central_impulse(push_vector)

func _ready():
	# CharacterBody2D 초기화
	print("캐릭터 컨트롤러 준비 완료!")