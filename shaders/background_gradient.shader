shader_type canvas_item;

// =============================================
// ФОН КАК В ОРИГИНАЛЕ (почти однотонный градиент)
// =============================================

uniform float time_scale = 1.0;

// Цвета градиента — из HTML (в 4 углах)
uniform vec4 color_tl = vec4(0.039, 0.031, 0.125, 1.0);   // #0a0820 (верх-лево)
uniform vec4 color_tr = vec4(0.071, 0.039, 0.180, 1.0);   // #120a2e (верх-право)
uniform vec4 color_bl = vec4(0.118, 0.067, 0.271, 1.0);   // #1e1145 (низ-лево)
uniform vec4 color_br = vec4(0.165, 0.086, 0.333, 1.0);   // #2a1655 (низ-право)

void fragment() {
    vec2 uv = UV;
    
    // === ГРАДИЕНТ (медленно переливается) ===
    float t = TIME * 0.1 * time_scale;
    
    // Лёгкое смещение — чтобы градиент «дышал», но не был резким
    vec2 shifted_uv = vec2(
        0.5 + (uv.x - 0.5) * cos(t * 0.3) - (uv.y - 0.5) * sin(t * 0.3),
        0.5 + (uv.x - 0.5) * sin(t * 0.3) + (uv.y - 0.5) * cos(t * 0.3)
    );
    
    // Билинейная интерполяция 4 углов — плавный градиент
    vec4 top = mix(color_tl, color_tr, shifted_uv.x);
    vec4 bottom = mix(color_bl, color_br, shifted_uv.x);
    vec4 gradient = mix(top, bottom, shifted_uv.y);
    
    // === ОЧЕНЬ ЛЁГКИЙ ОТТЕНОК (едва заметен, для «дыхания») ===
    // Это не аврора, а просто лёгкое изменение яркости
    float breathe = 0.5 + 0.5 * sin(TIME * 0.5 * time_scale);
    gradient.rgb += vec3(0.02, 0.01, 0.03) * breathe;
    
    COLOR = vec4(gradient.rgb, 1.0);
}