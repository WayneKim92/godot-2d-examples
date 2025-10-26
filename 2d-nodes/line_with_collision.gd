extends Line2D

## Line2D에 충돌 영역을 추가하는 스크립트
## Line2D의 points를 기반으로 자동으로 CollisionPolygon2D를 생성함

@export var collision_thickness: float = 10.0  # 충돌 영역의 두께

var static_body: StaticBody2D
var collision_polygon: CollisionPolygon2D

func _ready():
	# StaticBody2D와 CollisionPolygon2D 생성
	setup_collision()
	
	# Line2D의 points가 변경될 때 충돌 영역 업데이트
	update_collision_shape()

func setup_collision():
	# StaticBody2D 생성
	static_body = StaticBody2D.new()
	add_child(static_body)
	
	# CollisionPolygon2D 생성
	collision_polygon = CollisionPolygon2D.new()
	static_body.add_child(collision_polygon)
	
	print("Line2D에 충돌 영역이 추가되었습니다.")

func update_collision_shape():
	if points.size() < 2:
		return
	
	# Line2D의 points를 기반으로 폴리곤 생성
	var polygon_points: PackedVector2Array = []
	
	# 라인을 따라 양쪽에 두께를 가진 폴리곤 생성
	for i in range(points.size()):
		var point = points[i]
		
		# 법선 벡터 계산
		var normal: Vector2
		if i == 0:
			# 첫 번째 점
			var direction = (points[i + 1] - point).normalized()
			normal = Vector2(-direction.y, direction.x)
		elif i == points.size() - 1:
			# 마지막 점
			var direction = (point - points[i - 1]).normalized()
			normal = Vector2(-direction.y, direction.x)
		else:
			# 중간 점
			var direction1 = (point - points[i - 1]).normalized()
			var direction2 = (points[i + 1] - point).normalized()
			var avg_direction = (direction1 + direction2).normalized()
			normal = Vector2(-avg_direction.y, avg_direction.x)
		
		# 양쪽 점 추가
		polygon_points.append(point + normal * collision_thickness / 2.0)
	
	# 역방향으로 반대쪽 점 추가
	for i in range(points.size() - 1, -1, -1):
		var point = points[i]
		
		# 법선 벡터 계산 (위와 동일한 로직)
		var normal: Vector2
		if i == 0:
			var direction = (points[i + 1] - point).normalized()
			normal = Vector2(-direction.y, direction.x)
		elif i == points.size() - 1:
			var direction = (point - points[i - 1]).normalized()
			normal = Vector2(-direction.y, direction.x)
		else:
			var direction1 = (point - points[i - 1]).normalized()
			var direction2 = (points[i + 1] - point).normalized()
			var avg_direction = (direction1 + direction2).normalized()
			normal = Vector2(-avg_direction.y, avg_direction.x)
		
		# 반대쪽 점 추가
		polygon_points.append(point - normal * collision_thickness / 2.0)
	
	# CollisionPolygon2D에 폴리곤 적용
	if collision_polygon:
		collision_polygon.polygon = polygon_points
		print("충돌 폴리곤 업데이트 완료: ", polygon_points.size(), "개 점")

# 런타임에서 points가 변경될 때 호출
func refresh_collision():
	update_collision_shape()
