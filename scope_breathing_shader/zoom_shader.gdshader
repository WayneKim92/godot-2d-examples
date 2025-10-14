shader_type canvas_item;

uniform float zoom_factor : hint_range(0.5, 3.0) = 1.0;
uniform vec2 zoom_area_min = vec2(0.6, 0.0);
uniform vec2 zoom_area_max = vec2(1.0, 0.4);
uniform float edge_softness : hint_range(0.0, 0.2) = 0.05;
uniform bool show_border = true;
uniform float border_width : hint_range(0.001, 0.05) = 0.01;

void fragment() {
    vec2 uv = UV;
    
    // 줌 영역 내에 있는지 확인
    bool in_zoom_area = uv.x >= zoom_area_min.x && uv.x <= zoom_area_max.x && 
                       uv.y >= zoom_area_min.y && uv.y <= zoom_area_max.y;
    
    // 경계선 검사
    bool is_border = false;
    if (show_border && in_zoom_area) {
        float dist_left = uv.x - zoom_area_min.x;
        float dist_right = zoom_area_max.x - uv.x;
        float dist_top = uv.y - zoom_area_min.y;
        float dist_bottom = zoom_area_max.y - uv.y;
        
        float min_dist = min(min(dist_left, dist_right), min(dist_top, dist_bottom));
        is_border = min_dist < border_width;
    }
    
    if (is_border) {
        // 빨간색 경계선
        COLOR = vec4(1.0, 0.0, 0.0, 1.0);
    } else if (in_zoom_area) {
        // 줌 영역 내에서의 상대적 위치 (0.0 ~ 1.0)
        vec2 area_size = zoom_area_max - zoom_area_min;
        vec2 local_uv = (uv - zoom_area_min) / area_size;
        
        // 경계에서의 부드러운 전환
        float edge_x = min(smoothstep(0.0, edge_softness, local_uv.x), 
                          smoothstep(1.0, 1.0 - edge_softness, local_uv.x));
        float edge_y = min(smoothstep(0.0, edge_softness, local_uv.y), 
                          smoothstep(1.0, 1.0 - edge_softness, local_uv.y));
        float edge_factor = edge_x * edge_y;
        
        // 줌 팩터 적용 (경계에서는 줌 효과 감소)
        float current_zoom = mix(1.0, zoom_factor, edge_factor);
        
        // 줌 영역의 중심을 기준으로 확대
        vec2 local_center = vec2(0.5, 0.5);
        vec2 zoomed_local_uv = local_center + (local_uv - local_center) / current_zoom;
        
        // 전체 텍스처 좌표로 변환
        vec2 final_uv = zoom_area_min + zoomed_local_uv * area_size;
        
        // 텍스처에서 색상 읽기
        COLOR = texture(TEXTURE, final_uv);
    } else {
        // 줌 영역 밖은 원본
        COLOR = texture(TEXTURE, uv);
    }
}