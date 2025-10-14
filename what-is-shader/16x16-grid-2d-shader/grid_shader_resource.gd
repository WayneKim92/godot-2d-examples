class_name GridShaderResource
extends Resource

## 4x4 격자 셰이더를 쉽게 재사용할 수 있게 해주는 리소스 클래스

@export var grid_size: int = 4
@export var grid_line_width: float = 0.02
@export var grid_line_color: Color = Color.BLACK

func _init():
	pass

## 노드에 셰이더를 적용하는 함수
func apply_to_node(node: CanvasItem) -> ShaderMaterial:
	var shader = load("res://grid_shader.gdshader") as Shader
	var material = ShaderMaterial.new()
	material.shader = shader
	
	# 파라미터 설정
	material.set_shader_parameter("grid_size", grid_size)
	material.set_shader_parameter("grid_line_width", grid_line_width)
	material.set_shader_parameter("grid_line_color", grid_line_color)
	
	node.material = material
	return material

## 셰이더 머티리얼 생성 (노드에 적용하지 않고 반환만)
func create_material() -> ShaderMaterial:
	var shader = load("res://grid_shader.gdshader") as Shader
	var material = ShaderMaterial.new()
	material.shader = shader
	
	# 파라미터 설정
	material.set_shader_parameter("grid_size", grid_size)
	material.set_shader_parameter("grid_line_width", grid_line_width)
	material.set_shader_parameter("grid_line_color", grid_line_color)
	
	return material

## 그리드 크기 설정
func set_grid_size(size: int):
	grid_size = clamp(size, 1, 16)