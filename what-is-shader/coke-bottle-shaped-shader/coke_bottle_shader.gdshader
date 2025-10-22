shader_type canvas_item;

// 콜라병 변형 강도
uniform float bottle_strength : hint_range(0.0, 2.0) = 1.0;
uniform vec4 bottle_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // 기본 빨간색

void fragment() {
	// UV.y는 0(위)에서 1(아래)로 감
	float y = UV.y;
	
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
	
	// 현재 픽셀이 병 영역 안에 있는지 확인
	// UV.x가 중심(0.5)으로부터 얼마나 떨어져 있는지
	float x_from_center = abs(UV.x - 0.5);
	
	// 병의 실제 반경 계산 (bottle_strength 적용)
	float bottle_radius = bottle_width * bottle_strength * 0.5;
	
	// 병 영역 안이면 빨간색, 밖이면 투명
	if (x_from_center <= bottle_radius) {
		COLOR = bottle_color;
	} else {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0); // 투명
	}
}
