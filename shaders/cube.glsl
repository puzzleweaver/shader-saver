
// 距離関数
float sphereSDF(vec3 p) {
	//p -= vec3(sin(time*2.),0.,0.);
	return length(p) - 1.0;
}

// 立方体の距離関数
float boxSDF(vec3 p) {

	vec3 d = abs(p) - vec3(1.5);
	float outsideDistance = length(max(d, 0.0));
	float insideDistance = min(max(d.x, max(d.y, d.z)), 0.0);
	return outsideDistance + insideDistance;
}

vec3 calculateNormal(vec3 p) {
	float epsilon = 0.0001;
	vec3 n;
	float a = boxSDF(p + vec3(epsilon, 0.0, 0.0));
	float b = boxSDF(p - vec3(epsilon, 0.0, 0.0));
	
	n.x = max(a - b , b - a);
	
	float c = boxSDF(p + vec3(0.0, epsilon, 0.0));
	float d = boxSDF(p - vec3(0.0, epsilon, 0.0));
	n.y = max(c - d, d - c);
	
	float e = boxSDF(p + vec3(0.0, 0.0, epsilon));
	float f = boxSDF(p - vec3(0.0, 0.0, epsilon));
	n.z = max(e - f, f - e);
	
	return normalize(n);
}

vec3 palette3D(vec3 t)
{
	vec3 a = vec3(0.8, 0., 0.8);
	vec3 b = vec3(0.5, 0.5, 0.5);
	vec3 c = vec3(0.2, 1.0, 1.0);
	vec3 d = vec3(0.263, 0.8, 0.557);

	vec3 e = vec3(0.28, 1, 0.41);
	vec3 f = vec3(0.73, 0.56, 0.85);
	vec3 g = vec3(1, 0.25, 0.63);
	vec3 h = vec3(0.263, 0.8, 0.557);
	
	vec3 xNearBottom = mix(a, b,  t.x);
	vec3 xNearTop = mix(c, d , t.x );
	vec3 yNear = mix(xNearBottom, xNearTop, t.y );

	vec3 xFarBottom = mix(e, f, t.x );
	vec3 xFarTop = mix(g, h, t.x );	
	vec3 yFar = mix(xFarBottom, xFarTop, t.y );
	vec3 z = mix(yNear, yFar, t.z );
	
	return z;
}
vec3 palette(vec3 t)
{
	vec3 a = vec3(0.8, 0., 0.8);
	vec3 b = vec3(0.5, 0.5, 0.5);
	vec3 c = vec3(0.2, 1.0, 1.0);
	vec3 d = vec3(0.263, 0.8, 0.557);

	return a + b * cos(6.28318 * (c * t + d));
}

uvec2 uhash22(uvec2 n)
{
	uvec2 k = uvec2(0x456789abu, 0x6789ab45);
	uvec3 u = uvec3(13, 17 ,15);
	n ^= (n.yx << u.xy);
	n ^= (n.yx >> u.yz);
	n *= k.xy;
	n ^= (n.yx << u.zx);
	return n * k.xy;
}


// Get random value
float random(in vec2 st)
{
	// return frac(sin(dot(st.xy, half2(12.9898, 78.233))) * 43758.5453123);
	uint x = floatBitsToUint(st.x);
	uint y = floatBitsToUint(st.y);
	uvec2 n = uvec2(x,y);
	return vec2( uhash22(n)).x /  float(0xffffffffu) ;
}
// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 _st) {
	vec2 i = floor(_st);
	vec2 f = fract(_st);

	// Four corners in 2D of a tile
	float a = random(i);
	float b = random(i + vec2(1.0, 0.0));
	float c = random(i + vec2(0.0, 1.0));
	float d = random(i + vec2(1.0, 1.0));

	vec2 u = f * f * (3.0 - 2.0 * f);

	return mix(a, b, u.x) +
	(c - a)* u.y * (1.0 - u.x) +
	(d - b) * u.x * u.y;
}

#define NUM_OCTAVES 8

float fbm ( in vec2 _st) {
	float v = 0.0;
	float a = 0.5;
	vec2 shift = vec2(100.0);
	// Rotate to reduce axial bias
	mat2 rot = mat2(cos(0.5), sin(0.5),
	-sin(0.5), cos(0.50));
	for (int i = 0; i < NUM_OCTAVES; ++i) {
		v += a * noise(_st);
		_st = rot * _st * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

vec4 getFbmFinalColor(vec2 st) {
	// st += st * abs(sin(time*0.1)*3.0);
	vec3 color = vec3(0.0);

	vec2 q = vec2(0.);
	q.x = fbm( st + 0.00*iTime);
	q.y = fbm( st + vec2(1.0));

	vec2 r = vec2(0.);
	r.x = fbm( st + 1.0*q + vec2(1.7,9.2)+ 0.15*iTime );
	r.y = fbm( st + 1.0*q + vec2(8.3,2.8)+ 0.126*iTime);

	float f = fbm(st+r);

	color = mix(vec3(0.935,0.336,0.054),
	vec3(0.666667,0.666667,0.498039),
	clamp((f*f)*4.0,0.0,1.0));

	color = mix(color,
	vec3(0.000,0.940,0.070),
	clamp(length(q),0.0,1.0));

	color = mix(color,
	vec3(0.214,0.302,1.000),
	clamp(length(r.x),0.0,1.0));

	return vec4((f*f*f+.6*f*f+.5*f)*color,1.);
}
mat2 rot(float angle) {
	float s = sin(angle);
	float c = cos(angle);
	mat2 m = mat2(c, -s, s, c);
	return m;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// カメラの設定
	vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

	// カメラの設定
	vec3 target = vec3(0.0, 0.0, 0.0);      // カメラが注目するターゲット位置
	vec3 cp = vec3(0.0, -7.0, -15.0);       // カメラの位置
	vec3 cd = normalize(target - cp);       // カメラの視線方向
	vec3 cs = normalize(cross(cd, vec3(0.0, 1.0, 0.0))); // 右方向
	vec3 cu = normalize(cross(cd, cs));     // 上方向

	//最初は真っ黒にする
	vec3 col = vec3(0.0);

	float fov = 2.5; // 視野角
	vec3 rd = normalize(cs * p.x + cu * p.y + cd * fov); // レイの方向

	// レイマーチングのループ
	float t = 0.0;
	int maxSteps = 800;
	float maxDistance = 20.0;
	float epsilon = 0.00001;
	vec3 innerCol = vec3(0.0);
	vec3 baseColor = vec3(1.0);
	
	for (int i = 0; i < maxSteps; i++) {
		vec3 currentPos = cp + t * rd;
//		vec3 originPos = currentPos;
		mat2 rotationY = rot(iTime);
		mat2 rotationX = rot(iTime*.2);
		mat2 rotationZ = rot(iTime*.7);
		
		currentPos.xz *= rotationY;
		currentPos.yz *= rotationX;
		currentPos.xy *= rotationZ;
		
		vec2 rotateP = p.xy * rotationX;
		
		float distance = boxSDF(currentPos); // 各辺1.0の箱
		
		if (distance < 0.0) {
			float depth = distance;
			distance = 0.12;
			vec4 rotatePRandom = getFbmFinalColor(rotateP.xy);
			vec4 rotatePRandom2 = getFbmFinalColor(vec2(rotatePRandom.x, rotatePRandom.y + depth));
			innerCol += rotatePRandom.xyz * 0.1;
            
            currentPos += innerCol -0.5 ;
			float sphereDistance = sphereSDF(currentPos); // 半径1.0の球
			if(sphereDistance < epsilon )
			{
				innerCol += vec3( pow(abs(sphereDistance) ,3.)*0.1) * vec3(0.9, 0.2, 0.1);
			}
		}
		else if(distance < epsilon)
		{
			distance = 0.06;
			vec3 normal = calculateNormal(currentPos);
			float normalAdd = normal.x+ normal.y+normal.z;
			
			innerCol += vec3 (.2) * normalAdd * palette3D(normal);
		}
		
		t += distance;
		if (t > maxDistance) break;
	}
	
	
	// フラグメントカラーを設定
	fragColor = vec4(innerCol, 1.0);
}