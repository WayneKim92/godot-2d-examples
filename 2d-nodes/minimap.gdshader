shader_type canvas_item;

// 미니맵용 셰이더 - 화면을 축소하고 경계선 추가
uniform float zoom : hint_range(0.1, 1.0) = 0.3;
uniform vec2 camera_position = vec2(0.5, 0.5);
uniform float border_width : hint_range(0.0, 0.05) = 0.01;
uniform vec4 border_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);

void fragment() {
	// UV 중심을 기준으로 축소
	vec2 centered_uv = (UV - vec2(0.5)) / zoom + vec2(0.5);
	
	// 카메라 위치 오프셋 적용
	centered_uv += (camera_position - vec2(0.5));
	
	// 경계선 체크
	float dist_to_edge = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	
	if (centered_uv.x < 0.0 || centered_uv.x > 1.0 || centered_uv.y < 0.0 || centered_uv.y > 1.0) {
		// 범위 밖은 검은색
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else if (dist_to_edge < border_width) {
		// 경계선
		COLOR = border_color;
	} else {
		// 화면 복사 내용 표시
		vec4 screen_color = texture(SCREEN_TEXTURE, centered_uv);
		COLOR = screen_color * 0.9; // 약간 어둡게
	}
}
