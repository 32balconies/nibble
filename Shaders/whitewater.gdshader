shader_type canvas_item;

uniform float wave_strength : hint_range(0.0, 3.0) = 1.0;
uniform float wave_speed : hint_range(0.0, 5.0) = 1.0;
uniform float wave_frequency : hint_range(0.0, 20.0) = 6.0;

void fragment() {
    vec2 uv = UV;

    // Convert UV to 32x32 pixel coordinates.
    vec2 pixel = floor(uv * 16.0);

    // Make the wave operate on whole pixel rows.
    float wave = sin(
        pixel.y * wave_frequency / 16.0 +
        TIME * wave_speed
    );

    // Shift by whole pixels.
    pixel.x += floor(wave * wave_strength);

    // Wrap around horizontally.
    pixel.x = mod(pixel.x, 16.0);

    // Convert back to UV.
    uv = (pixel + 0.5) / 16.0;

    // Explicit texture lookup.
    COLOR = texture(TEXTURE, uv);
}