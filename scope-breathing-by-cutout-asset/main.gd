extends CharacterBody2D

var chest_node: Sprite2D

# 숨쉬는 효과를 위한 변수들
var tween: Tween
var min: float = 1.0
var max: float = 1.12
var duration: float = 2 # 한 번의 숨쉬기 사이클 지속시간

func _ready():
	# Chest 노드 참조 가져오기
	chest_node = $Chest
	
	# 숨쉬는 애니메이션 시작
	start_breathing_animation()

func start_breathing_animation():
	# 새로운 Tween 생성 및 무한 루프 설정
	tween = create_tween()
	tween.set_loops()  # 무한 반복
	
	# Chest 노드의 스케일을 min -> max -> min 으로 변화
	tween.tween_method(update_chest_scale, min, max, duration)
	tween.tween_method(update_chest_scale, max, min, duration)

func update_chest_scale(scale_value: float):
	if chest_node:
		chest_node.scale = Vector2(scale_value, scale_value)
