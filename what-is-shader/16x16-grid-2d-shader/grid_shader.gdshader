shader_type canvas_item;

uniform int grid_size : hint_range(1, 16) = 4;
uniform float grid_line_width : hint_range(0.0, 0.1) = 0.02;
uniform vec4 grid_line_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float cell_alpha : hint_range(0.0, 1.0) = 0.7;
uniform bool use_texture_blend = false;
uniform float texture_blend_amount : hint_range(0.0, 1.0) = 0.5;
uniform bool use_random_colors = false;
uniform float random_seed = 0.0;

// 기본 색상들을 하드코딩하여 안정성 확보
const vec4 default_colors[16] = {
    vec4(1.0, 0.0, 0.0, 1.0),  // 빨강
    vec4(0.0, 1.0, 0.0, 1.0),  // 초록
    vec4(0.0, 0.0, 1.0, 1.0),  // 파랑
    vec4(1.0, 1.0, 0.0, 1.0),  // 노랑
    vec4(1.0, 0.0, 1.0, 1.0),  // 마젠타
    vec4(0.0, 1.0, 1.0, 1.0),  // 시안
    vec4(1.0, 0.5, 0.0, 1.0),  // 주황
    vec4(0.5, 0.0, 1.0, 1.0),  // 보라
    vec4(0.5, 1.0, 0.0, 1.0),  // 라임
    vec4(1.0, 0.0, 0.5, 1.0),  // 핑크
    vec4(0.0, 0.5, 1.0, 1.0),  // 연파랑
    vec4(0.8, 0.8, 0.8, 1.0),  // 연회색
    vec4(0.4, 0.4, 0.4, 1.0),  // 회색
    vec4(0.6, 0.3, 0.0, 1.0),  // 갈색
    vec4(1.0, 0.8, 0.8, 1.0),  // 연분홍
    vec4(0.8, 1.0, 0.8, 1.0)   // 연초록
};

// 랜덤 해시 함수
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7)) + random_seed) * 43758.5453123);
}

// 랜덤 색상 생성 함수
vec4 get_random_color(vec2 cell_pos) {
    float r = hash(cell_pos);
    float g = hash(cell_pos + vec2(1.0, 0.0));
    float b = hash(cell_pos + vec2(0.0, 1.0));
    return vec4(r, g, b, 1.0);
}

void fragment() {
    vec2 grid_pos = UV * float(grid_size);
    vec2 cell_pos = floor(grid_pos);
    vec2 local_pos = fract(grid_pos);
    
    // 원본 텍스처 색상 가져오기
    vec4 texture_color = texture(TEXTURE, UV);
    
    // 그리드 라인 그리기
    bool is_grid_line = (local_pos.x < grid_line_width || local_pos.x > (1.0 - grid_line_width) ||
                        local_pos.y < grid_line_width || local_pos.y > (1.0 - grid_line_width));
    
    if (use_texture_blend) {
        if (is_grid_line) {
            // 그리드 라인: 텍스처와 라인 색상 혼합
            COLOR = mix(texture_color, grid_line_color, 0.8);
        } else {
            // 셀 색상 결정 (랜덤 또는 기본)
            vec4 cell_color;
            if (use_random_colors) {
                cell_color = get_random_color(cell_pos);
            } else {
                int cell_index = int(cell_pos.y) * grid_size + int(cell_pos.x);
                cell_index = cell_index % 16;
                cell_color = default_colors[cell_index];
            }
            
            // 텍스처와 셀 색상을 texture_blend_amount 비율로 혼합
            COLOR = mix(texture_color, cell_color, texture_blend_amount);
            COLOR.a = mix(texture_color.a, cell_alpha, texture_blend_amount);
        }
    } else {
        // 텍스처 블렌드 비활성화 시: 순수 그리드만 표시
        if (is_grid_line) {
            COLOR = grid_line_color;
        } else {
            // 셀 색상 결정 (랜덤 또는 기본)
            vec4 cell_color;
            if (use_random_colors) {
                cell_color = get_random_color(cell_pos);
            } else {
                int cell_index = int(cell_pos.y) * grid_size + int(cell_pos.x);
                cell_index = cell_index % 16;
                cell_color = default_colors[cell_index];
            }
            cell_color.a = cell_alpha;
            COLOR = cell_color;
        }
    }
}