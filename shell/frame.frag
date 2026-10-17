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

float gaussian(float x, float sigma) {
	const float pi = 3.141592653589793;
	return exp(-(x * x) / (2.0 * sigma * sigma)) / (sqrt(2.0 * pi) * sigma);
}

vec2 erfApprox(vec2 x) {
	vec2 s = sign(x);
	vec2 a = abs(x);
	x = 1.0 + (0.278393 + (0.230389 + 0.078108 * (a * a)) * a) * a;
	x *= x;
	return s - s / (x * x);
}

float roundedBoxShadowX(float x, float y, float sigma, float corner, vec2 halfSize) {
	float delta = min(halfSize.y - corner - abs(y), 0.0);
	float curved = halfSize.x - corner + sqrt(max(0.0, corner * corner - delta * delta));
	vec2 integral = 0.5 + 0.5 * erfApprox((x + vec2(-curved, curved)) * (sqrt(0.5) / sigma));
	return integral.y - integral.x;
}

// Blurred rounded-rect coverage. Same approximation as niri's shadow shader.
float roundedBoxShadow(vec2 lower, vec2 upper, vec2 point, float sigma, float corner) {
	vec2 center = (lower + upper) * 0.5;
	vec2 halfSize = (upper - lower) * 0.5;
	point -= center;

	float low = point.y - halfSize.y;
	float high = point.y + halfSize.y;
	float start = clamp(-3.0 * sigma, low, high);
	float end = clamp(3.0 * sigma, low, high);

	float step = (end - start) / 4.0;
	float y = start + step * 0.5;
	float value = 0.0;
	for (int i = 0; i < 4; i++) {
		value += roundedBoxShadowX(point.x, point.y - y, sigma, corner, halfSize) * gaussian(y, sigma) * step;
		y += step;
	}
	return value;
}

float panelShadow(vec4 box, float r, vec2 point) {
	if (box.z < 1.0 || box.w < 1.0)
		return 0.0;
	vec2 lower = box.xy - vec2(shadowSpread);
	vec2 upper = box.xy + box.zw + vec2(shadowSpread);
	return roundedBoxShadow(lower, upper, point, shadowSigma, max(r + shadowSpread, 0.0));
}

float frameShadow(vec2 point) {
	if (thickness < 0.5)
		return 0.0;
	vec2 size = vec2(fieldWidth, fieldHeight);
	float outer = roundedBoxShadow(vec2(-shadowSpread), size + vec2(shadowSpread), point, shadowSigma, 0.0);

	float inset = thickness + shadowSpread;
	vec2 innerLower = vec2(inset);
	vec2 innerUpper = size - vec2(inset);
	float inner = 0.0;
	if (innerUpper.x > innerLower.x && innerUpper.y > innerLower.y)
		inner = roundedBoxShadow(innerLower, innerUpper, point, shadowSigma, max(radius - shadowSpread, 0.0));

	return clamp(outer - inner, 0.0, 1.0);
}

void main() {
	vec2 p = qt_TexCoord0 * vec2(fieldWidth, fieldHeight);
	float d = sdFrame(p);
	d = smin(d, sdPanel(p, panel0, panelRadius.x), smoothing);
	d = smin(d, sdPanel(p, panel1, panelRadius.y), smoothing);
	d = smin(d, sdPanel(p, panel2, panelRadius.z), smoothing);

	float fill = smoothstep(1.25, -0.75, d);
	vec2 shadowPoint = p - shadowOffset;
	float shade = frameShadow(shadowPoint);
	shade = max(shade, panelShadow(panel0, panelRadius.x, shadowPoint));
	shade = max(shade, panelShadow(panel1, panelRadius.y, shadowPoint));
	shade = max(shade, panelShadow(panel2, panelRadius.z, shadowPoint));

	vec4 frame = vec4(surface.rgb, surface.a) * fill;
	vec4 drop = shadowColor * shade * (1.0 - fill);
	fragColor = (frame + drop * (1.0 - frame.a)) * qt_Opacity;
	fragColor.r += qt_Matrix[3][3] * 0.0;
}
