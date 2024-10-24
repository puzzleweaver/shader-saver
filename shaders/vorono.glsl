vec3[] points = vec3[](
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), 
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), 
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), 
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), 
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0),
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), 
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), 
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), 
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), 
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0),
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), 
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), 
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), 
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), 
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0),
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), 
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), 
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), 
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), 
    vec3(0), vec3(0), vec3(0), vec3(0), vec3(0)
);
int numPoints = 36;

float smin(float a, float b, float r) {
  float h;
  h = clamp (0.5 + 0.5 * (b - a) / r, 0., 1.);
  return mix (b, a, h) - r * h * (1. - h);
}

vec3 closestTo(in vec2 p) {
    float firstDist = 100.0, curDist;
    vec3 first, cur;
    float r;
    for(int i = 0; i < numPoints; i++) {
        cur = points[i];
		curDist = dot(cur.xy-p, cur.xy-p);
        if(curDist < firstDist) {
            firstDist = curDist;
            first = cur;
        }
	}
    
    return first;
}



vec4 getBorder(in vec2 p) {
    // float d = Voronoi2(p);
    // return 1.0 - smoothstep(0.0, 0.05, d);
    return vec4(0);
}

float dist(vec2 a, vec2 b) {
    vec2 c = a-b;
    return c.x*c.x + c.y*c.y;
}

vec4 getCol(vec2 uv) {
    vec3 closest = closestTo(uv);
    vec3 col = vec3(closest.z);
    
    for(int i = 0; i < numPoints; i++) {
        vec3 cur = points[i];
        if(dist(uv, cur.xy) < 0.0001) col = vec3(1.0-points[i].z);
    }
    return vec4(col, 1);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    
    numPoints = 20;
    int row = 6;
    for(int i = 0; i < numPoints; i++) {
        points[i] = vec3(
            (float(i%(row)) + 0.4*cos(0.5*iTime * 6.28*float(i)/float(numPoints)))/float(row-1),
            (float(i/(row)) + 0.3654*sin(0.5*iTime * 6.28*float(i)/float(numPoints)))/float(row-1),
            i%2 == 0 ? 0 : 1
        );
    }
    
    vec4 col = getCol(uv);
    // vec4 col = vec4(0);
    // int radius = 7;
    // float totalWeight = 0.0;
    // for(int x = -radius; x <= radius; x++){
    //     for(int y = -radius; y <= radius; y++){
    //         float weight = exp(-float(x*x + y*y) / 2.0) / 6.28;
    //         col += getCol(uv+7.0*vec2(x, y)/iResolution.xy)*weight;
    //         totalWeight += weight;
    //     }
    // }
    // col /= totalWeight;
    
    fragColor = col; // vec4(col,1.0);
}