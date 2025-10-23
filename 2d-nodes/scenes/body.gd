extends Node2D

@onready var animatable_body = $Platforms/AnimatableBody2D
var tween: Tween
var original_position: Vector2

func _ready():
	# 원본 위치 저장
	original_position = animatable_body.position
	
	# 애니메이션 시작
	start_position_animation()

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
