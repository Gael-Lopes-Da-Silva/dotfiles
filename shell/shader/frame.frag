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
	vec4 panel3;
	vec4 panelRadius;
	vec4 surface;
	vec4 panel4;
	float panel4Radius;
	vec4 panel5;
	float panel5Radius;
	vec4 panel6;
	float panel6Radius;
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
	vec2 innerHalf = max(halfSize - vec2(thickness), vec2(0.0));
	// The outer edge is the screen rectangle, extended past the pixels so the
	// antialiased fringe falls off-screen and the corners stay filled.
	float outer = sdRoundBox(p - halfSize, halfSize + vec2(1.0), 0.0);
	float inner = sdRoundBox(p - halfSize, innerHalf, radius);
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

// Niri layout.shadow: softness 4, spread 2, offset (0, 2), #00000070.
// Sigma is softness / 2, the same conversion niri uses for CSS box-shadow.
const float shadowSigma = 2.0;
const float shadowSpread = 2.0;
const vec2 shadowOffset = vec2(0.0, 2.0);
const vec4 shadowColor = vec4(0.0, 0.0, 0.0, 112.0 / 255.0);

float erfApprox(float x) {
	float s = sign(x);
	float a = abs(x);
	float t = 1.0 + (0.278393 + (0.230389 + 0.078108 * (a * a)) * a) * a;
	t *= t;
	return s - s / (t * t);
}

float shapeDistance(vec2 p) {
	float d = sdFrame(p);
	d = smin(d, sdPanel(p, panel0, panelRadius.x), smoothing);
	d = smin(d, sdPanel(p, panel1, panelRadius.y), smoothing);
	d = smin(d, sdPanel(p, panel2, panelRadius.z), smoothing);
	d = smin(d, sdPanel(p, panel3, panelRadius.w), smoothing);
	d = smin(d, sdPanel(p, panel4, panel4Radius), smoothing);
	d = smin(d, sdPanel(p, panel5, panel5Radius), smoothing);
	d = smin(d, sdPanel(p, panel6, panel6Radius), smoothing);
	return d;
}

// Smooth-union distances are not Euclidean, so recover a unit distance
// before blurring. The shadow then follows the visible outline.
float unitDistance(vec2 p) {
	float d = shapeDistance(p);
	float gx = shapeDistance(p + vec2(1.0, 0.0)) - shapeDistance(p - vec2(1.0, 0.0));
	float gy = shapeDistance(p + vec2(0.0, 1.0)) - shapeDistance(p - vec2(0.0, 1.0));
	float grad = max(length(vec2(gx, gy)) * 0.5, 0.001);
	return d / grad;
}

void main() {
	vec2 p = qt_TexCoord0 * vec2(fieldWidth, fieldHeight);
	float d = shapeDistance(p);
	float fill = smoothstep(1.25, -0.75, d);

	float shadowDistance = unitDistance(p - shadowOffset) - shadowSpread;
	float shade = 0.5 * (1.0 - erfApprox(shadowDistance / (shadowSigma * 1.41421356)));

	vec4 frame = vec4(surface.rgb, surface.a) * fill;
	vec4 drop = shadowColor * shade * (1.0 - fill);
	fragColor = (frame + drop * (1.0 - frame.a)) * qt_Opacity;
	fragColor.r += qt_Matrix[3][3] * 0.0;
}
