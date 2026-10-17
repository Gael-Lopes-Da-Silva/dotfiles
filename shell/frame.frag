#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
	mat4 qt_Matrix;
	float qt_Opacity;
	float fieldWidth;
	float fieldHeight;
	float thickness;
	float radius;
	float smoothing;
	vec4 panel0;
	vec4 panel1;
	vec4 panel2;
	vec4 panelRadius;
	vec4 surface;
};

float sdRoundBox(vec2 p, vec2 halfSize, float r) {
	vec2 box = max(halfSize, vec2(0.0));
	float cr = min(max(r, 0.0), min(box.x, box.y));
	vec2 q = abs(p) - box + vec2(cr);
	return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - cr;
}

float sdFrame(vec2 p) {
	if (thickness < 0.5)
		return 1e4;
	vec2 halfSize = vec2(fieldWidth, fieldHeight) * 0.5;
	float innerRadius = max(radius - thickness, 0.0);
	vec2 innerHalf = max(halfSize - vec2(thickness), vec2(0.0));
	float outer = sdRoundBox(p - halfSize, halfSize, radius);
	float inner = sdRoundBox(p - halfSize, innerHalf, innerRadius);
	return max(outer, -inner);
}

float sdPanel(vec2 p, vec4 box, float r) {
	if (box.z < 1.0 || box.w < 1.0)
		return 1e4;
	vec2 center = box.xy + box.zw * 0.5;
	return sdRoundBox(p - center, box.zw * 0.5, r);
}

float smin(float a, float b, float k) {
	if (k < 0.001)
		return min(a, b);
	float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
	return mix(b, a, h) - k * h * (1.0 - h);
}

void main() {
	vec2 p = qt_TexCoord0 * vec2(fieldWidth, fieldHeight);
	float d = sdFrame(p);
	d = smin(d, sdPanel(p, panel0, panelRadius.x), smoothing);
	d = smin(d, sdPanel(p, panel1, panelRadius.y), smoothing);
	d = smin(d, sdPanel(p, panel2, panelRadius.z), smoothing);

	float fill = smoothstep(1.25, -0.75, d);
	float shadow = (1.0 - fill) * smoothstep(22.0, 0.0, d) * 0.38;
	float alpha = clamp(max(fill * surface.a, shadow), 0.0, 1.0);
	vec3 rgb = mix(vec3(0.0), surface.rgb, fill / max(alpha, 1e-4));
	fragColor = vec4(rgb * alpha, alpha) * qt_Opacity;
	fragColor.r += qt_Matrix[3][3] * 0.0;
}
