#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;

in vec2 fs_Pos;
out vec4 out_Col;

const float pi = 3.14159;
const float v_fov = pi / 4.0;

struct AABB {
  vec3 min;
  vec3 max;
};

// SDF functions

const int num_objects = 2;

const vec3 sphere_center = vec3(0.0);
const vec3 sphere_center_b = vec3(10.0);
const vec3 box_center = vec3(-4.0, 0.0, 10.0);
const vec3 torus_center = vec3(4.0, 0.0, 10.0);

float sd_sphere(vec3 p, float r) {
  return length(p) - r;
}

float sd_box(vec3 p, vec3 span) {
  vec3 d = abs(p) - span;
  return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

// path circle is on xz plane
float sd_torus(vec3 p, float path_r, float slice_r) {
  vec2 ring_delta = vec2(length(p.xz) - path_r, p.y);
  return length(ring_delta) - slice_r;
}

// aligned with y axis, through the origin
float sd_cylinder(vec3 p, float r) {
  return length(p.xz) - r;
}

// TODO - skip, do not understand the math yet
float sd_cone(vec3 p, vec2 c) {
  return 1000.0;
}

float sd_plane(vec3 p, vec3 plane_pt, vec3 n) {
  // n must be normalized
  return dot(p - plane_pt, n);
}

float sd_capsule(vec3 p, vec3 a, vec3 b, float r) {
  vec3 pa = p - a;
  vec3 ba = b - a;
  float norm_dist = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
  return length(pa - norm_dist * ba) - r;
}

// aligned with the y-axis
float sd_cylinder(vec3 p, vec2 span) {
  vec2 d = vec2(length(p.xz), abs(p.y)) - span;
  return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

vec4 op_elongate(vec3 pos, vec3 extents) {
  vec3 q = abs(pos) - extents;
  return vec4(max(q, 0.0), min(max(max(extents.x, extents.y), extents.z), 0.0));
}

float dot2(vec3 v) {
  return dot(v, v);
}

// Not working. Issue may be that since it is planar there is no -ve part of the field
// return to later.
/*
float sd_quad(vec3 p, vec3 a, vec3 span_u, vec3 span_v) {
  // if projection is on quad, return dist to plane.
  // otherwise ret the min dist to a line on the plane
  vec3 pa = p - a;
  vec3 pb = p - (a + span_v);
  vec3 pc = p - (a + span_u + span_v);
  vec3 pd = p - (a + span_u);
  vec3 nor = cross(span_u, span_v);
  return 
    (
      sign(dot(cross(span_v, nor), pa)) +
      sign(dot(cross(span_u, nor), pb)) +
      sign(dot(cross(-span_v, nor), pc)) +
      sign(dot(cross(-span_u, nor), pd)) == 4.0
    ) ? abs(dot(pa, normalize(nor))) :
    sqrt(min(min(min(
      dot2(pa - span_u * clamp(dot(pa, span_u) / dot2(span_u), 0.0, 1.0)),
      dot2(pa - span_v * clamp(dot(pa, span_v) / dot2(span_v), 0.0, 1.0))),
      dot2(pb - span_u * clamp(dot(pb, span_u) / dot2(span_u), 0.0, 1.0))),
      dot2(pd - span_v * clamp(dot(pd, span_v) / dot2(span_v), 0.0, 1.0))))
    ;
}
*/

// Engine functions

float sdf_for_object_old(float obj_id, vec3 pos) {
  switch (int(obj_id)) {
  case 0:
    return sd_sphere(pos - sphere_center, 1.0);
  case 1:
    return sd_sphere(pos - sphere_center_b, 2.0);
  case 2:
    return sd_box(pos - box_center, vec3(2.0, 1.0, 1.0));
  case 3:
    return sd_torus(pos - torus_center, 2.0, 1.0);
  case 4:
    return sd_cylinder(pos - vec3(3.0,0.0,20.0), 1.0);
  case 5:
    return sd_cone(pos, vec2(1.0, 0.0));
  case 6:
    return sd_plane(pos, vec3(0.0, -3.0, 0.0), vec3(0.0, 1.0, 0.0));
  case 7:
    vec3 offset = vec3(4.0, 0.0, 4.0);
    return sd_capsule(pos, offset, offset + vec3(0.0, 3.0, 0.0), 1.0);
  case 8:
    return sd_cylinder(pos - vec3(-2.0, 0.0, 4.0), vec2(1.0, 3.0));
  }
  return 0.0;
}

float sdf_for_object(float obj_id, vec3 pos) {
  switch (int(obj_id)) {
  case 0: {
    // elongation
    vec4 elo = op_elongate(pos, vec3(2.0, 1.0, 1.0));
    return elo.w + sd_sphere(elo.xyz, 1.0);
  }
  case 1: {
    vec4 elo = op_elongate(pos, vec3(3.0, 0.0, 3.0));
    return elo.w + sd_torus(elo.xyz, 1.0, 0.2);
  }
  }
}

vec3 world_normal(float obj_id, vec3 pos) {
  vec3 normal = vec3(0.0, 1.0, 0.0);

  // assumes that the sdf is 0.0 at the given pos
  vec2 delta = vec2(0.0, 1.0) * 0.0005;
  normal = normalize(vec3(
    sdf_for_object(obj_id, pos + delta.yxx) -
      sdf_for_object(obj_id, pos - delta.yxx),
    sdf_for_object(obj_id, pos + delta.xyx) -
      sdf_for_object(obj_id, pos - delta.xyx),
    sdf_for_object(obj_id, pos + delta.xxy) -
      sdf_for_object(obj_id, pos - delta.xxy)
  ));

  return normal;
}

vec3 world_color(float obj_id, vec3 pos, vec3 normal) {
  vec3 material_color = vec3(0.5, 0.0, 0.0);
  switch (int(obj_id)) {
    case 0:
      material_color = vec3(0.5, 0.0, 0.0);
      break;
    case 1:
      material_color = vec3(0.0, 0.5, 0.0);
      break;
    case 2:
      material_color = vec3(0.0, 0.0, 0.5);
      break;
    case 6:
      material_color = vec3(0.2);
      break;
  }

  vec3 light_dir = normalize(vec3(-1.0, 1.0, -1.0));
  float diffuse_factor = clamp(dot(light_dir, normal), 0.0, 1.0);
  float ambient_factor = 0.2;

  return material_color * (diffuse_factor + ambient_factor);

  //return vec3(1.0) * (normal.x + 1.0) * 0.5;
}

vec3 background_color(vec3 ro, vec3 rd) {
  return vec3(0.5);
}

vec2 compute_dist(vec3 pos,
  float[num_objects] active_objs, int num_active) {

  vec2 min_dist = vec2(100000.0, -1);
  for (int i = 0; i < num_active; ++i) {
    float obj_id = active_objs[i];
    float obj_dist = sdf_for_object(obj_id, pos);  
    if (obj_dist < min_dist.x) {
      min_dist = vec2(obj_dist, obj_id);
    }
  }
  return min_dist;
}

vec2 world_intersect(vec3 ro, vec3 rd) {
  /*
  // TODO - safe to assume that they are default-initialized?
  AABB[num_objects] boxes;
  // TODO - set the boxes for the objects that have them,
  // and leave the rest uninitialized

  // use the BB to compute the list of active object ids
  int num_active = 0;
  float[num_objects] active_objects;
  for (int i = 0; i < boxes.length(); ++i) {
    AABB box = boxes[i];
    if (box.max - box.min != vec3(0.0) || intersects_bb(ro, rd, box)) {
      active_objects[num_active] = i;  
    }
  }
  */
  // activate all objects
  float[num_objects] active_objects;
  for (int i = 0; i < num_objects; ++i) {
    active_objects[i] = float(i);
  }
  int num_active = num_objects;

  float t = 0.0;
  int max_steps = 64;
  float min_step = 0.001;
  for (int i = 0; i < max_steps; ++i) {
    vec3 pt = ro + t * rd;
    vec2 dist_result = compute_dist(pt, active_objects, num_active);
    float obj_dist = dist_result.x;
    float obj_id = dist_result.y;
    if (obj_dist - 0.0001 < 0.0) {
      // TODO - lerp with the previous value of t, perhaps
      return vec2(t, obj_id);  
    }
    t += max(obj_dist, min_step);
  }
  return vec2(0.0, -1.0);
}

void ray_for_pixel(vec2 ndc, inout vec3 ro, inout vec3 rd) {
  vec3 look_vec = u_Ref - u_Eye;
  float len = length(look_vec);
  float aspect_ratio = u_Dimensions.x / u_Dimensions.y;
  float v = tan(v_fov) * len;
  float h = aspect_ratio * v; 
  vec3 v_vec = ndc.y * v * u_Up;
  vec3 h_vec = ndc.x * h * cross(look_vec / len, u_Up);

  ro = u_Eye;
  rd = normalize((u_Ref + h_vec + v_vec) - u_Eye);
}

void main() {
  vec3 ro, rd;
  ray_for_pixel(fs_Pos, ro, rd);

  vec2 intersect = world_intersect(ro, rd);
  float t = intersect.x;
  float obj_id = intersect.y;
  vec3 color;
  if (obj_id == -1.0) {
    color = background_color(ro, rd);  
  } else {
    vec3 inter_pos = ro + t * rd;
    vec3 world_nor = world_normal(obj_id, inter_pos);  
    color = world_color(obj_id, inter_pos, world_nor); 
  }

  //vec3 col = 0.5 * (rd + vec3(1.0));

  out_Col = vec4(color, 1.0);
  //out_Col = vec4(0.5 * (fs_Pos + vec2(1.0)), 0.5 * (sin(u_Time * 3.14159 * 0.01) + 1.0), 1.0);
}

