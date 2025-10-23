extends Node2D

@onready var animatable_body = $AnimatableBody2D
var tween: Tween
var original_scale: Vector2

func _ready():
	# 원본 스케일 저장
	original_scale = animatable_body.scale
	
	# 애니메이션 시작
	start_scale_animation()

func start_scale_animation():
	# 기존 트윈이 있으면 중지
	if tween:
		tween.kill()
	
	# 새 트윈 생성
	tween = create_tween()
	tween.set_loops() # 무한 반복
	
	# y 스케일을 원본에서 1.5배로 커지게 (1초 동안)
	tween.tween_property(animatable_body, "scale:y", original_scale.y * 1.5, 1.0)
	tween.tween_property(animatable_body, "scale:y", original_scale.y, 1.0)
	
	# 트윈 설정 (부드러운 애니메이션을 위한 이징)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
