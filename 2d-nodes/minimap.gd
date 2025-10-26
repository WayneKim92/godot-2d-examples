extends ColorRect

## 미니맵 스크립트 - 카메라 위치에 따라 미니맵 업데이트

@onready var character = get_node("/root/Main/CharacterBody2D")
@onready var fruits_container = get_node("/root/Main/Fruits")
@onready var player_marker = $PlayerMarker

var viewport_size: Vector2
var fruit_markers: Array = []

func _ready():
	viewport_size = get_viewport().get_visible_rect().size
	
	# 과일 마커들 생성
	create_fruit_markers()
	
	print("미니맵 초기화 완료")

func create_fruit_markers():
	if not fruits_container:
		return
	
	# 모든 과일(RigidBody2D) 찾기
	for fruit in fruits_container.get_children():
		if fruit is RigidBody2D:
			# 과일마다 마커 생성
			var marker = ColorRect.new()
			marker.custom_minimum_size = Vector2(4, 4)
			marker.color = Color(1, 0.5, 0, 1)  # 오렌지색
			add_child(marker)
			fruit_markers.append({"fruit": fruit, "marker": marker})
	
	print("과일 마커 생성 완료: ", fruit_markers.size(), "개")

func _process(_delta):
	if character and material:
		# 캐릭터의 화면 상 위치를 0~1 범위로 정규화
		var char_pos = character.global_position
		var normalized_x = char_pos.x / viewport_size.x
		var normalized_y = char_pos.y / viewport_size.y
		
		# 셰이더에 카메라 위치 전달
		material.set_shader_parameter("camera_position", Vector2(normalized_x, normalized_y))
		
		# 플레이어 마커 위치 업데이트
		update_player_marker(normalized_x, normalized_y)
	
	# 과일 마커 위치 업데이트
	update_fruit_markers()

func update_player_marker(normalized_x: float, normalized_y: float):
	if not player_marker:
		return
	
	var minimap_size = size
	
	# 미니맵 내 위치 계산
	var minimap_x = normalized_x * minimap_size.x - 3  # 마커 크기 절반만큼 오프셋
	var minimap_y = normalized_y * minimap_size.y - 3
	
	# 플레이어 마커 위치 설정
	player_marker.position = Vector2(minimap_x, minimap_y)

func update_fruit_markers():
	var minimap_size = size
	
	for item in fruit_markers:
		var fruit = item["fruit"]
		var marker = item["marker"]
		
		if not is_instance_valid(fruit):
			# 과일이 삭제되었으면 마커도 숨김
			marker.visible = false
			continue
		
		# 과일의 화면 상 위치를 미니맵 좌표로 변환
		var fruit_pos = fruit.global_position
		var normalized_x = fruit_pos.x / viewport_size.x
		var normalized_y = fruit_pos.y / viewport_size.y
		
		# 미니맵 내 위치 계산 (0~1 범위를 미니맵 크기로 변환)
		var minimap_x = normalized_x * minimap_size.x - 2  # 마커 크기 절반만큼 오프셋
		var minimap_y = normalized_y * minimap_size.y - 2
		
		# 마커 위치 설정
		marker.position = Vector2(minimap_x, minimap_y)
		marker.visible = true
