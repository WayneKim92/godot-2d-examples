shader_type canvas_item;

// 콜라병 변형 강도
uniform float bottle_strength : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	// 현재 픽셀의 UV 좌표
	vec2 uv = UV;
	float y = uv.y;
	
	// 콜라병 모양 곡선 계산 - 각 높이에서의 병 너비
	float bottle_width;
	
	if (y < 0.2) {
		// 병목 부분 (위쪽): 매우 좁음
		bottle_width = 0.5 + sin(y * 3.14159 * 2.5) * 0.1;
	} else if (y < 0.45) {
		// 어깨에서 허리로 내려오는 부분: 점점 넓어짐
		float t = (y - 0.2) / 0.25;
		bottle_width = 0.6 + sin(t * 3.14159) * 0.2;
	} else if (y < 0.55) {
		// 허리 부분 (중간): 가장 잘록함
		bottle_width = 0.65;
	} else if (y < 0.85) {
		// 허리에서 엉덩이로: 점점 넓어짐
		float t = (y - 0.55) / 0.3;
		bottle_width = 0.65 + sin(t * 3.14159 * 0.5) * 0.35;
	} else {
		// 바닥 부분: 약간 좁아짐
		float t = (y - 0.85) / 0.15;
		bottle_width = 1.0 - t * 0.15;
	}
	
	// UV.x를 중심(0.5)을 기준으로 변형
	float x_offset = (uv.x - 0.5);
	
	// 콜라병 너비에 따라 UV.x 조정
	// bottle_width가 작으면 더 압축되어 샘플링
	float modified_x = 0.5 + (x_offset / (bottle_width * bottle_strength));
	
	// 변형된 UV로 텍스처 샘플링
	vec2 modified_uv = vec2(modified_x, y);
	
	// UV 범위를 벗어나면 투명 처리
	if (modified_x < 0.0 || modified_x > 1.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		COLOR = texture(TEXTURE, modified_uv);
	}
}
