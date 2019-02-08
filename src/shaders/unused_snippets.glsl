// TODO - Junk below here:

// TODO - remove if unused
/*
vec2 compute_dist(vec3 pos) {
  vec2 min_dist = vec2(1e10, -1);
  for (int i = 0; i < num_objects; ++i) {
    float obj_id = float(i);
    float obj_dist = sdf_for_object(obj_id, pos);  
    if (obj_dist < min_dist.x) {
      min_dist = vec2(obj_dist, obj_id);
    }
  }
  return min_dist;
}
*/

// TODO - remove if unused
/*
vec2 compute_dist_old(vec3 pos,
  float[num_objects] active_objs, int num_active) {

  vec2 min_dist = vec2(1e10, -1);
  for (int i = 0; i < num_active; ++i) {
    float obj_id = active_objs[i];
    float obj_dist = sdf_for_object(obj_id, pos);  
    if (obj_dist < min_dist.x) {
      min_dist = vec2(obj_dist, obj_id);
    }
  }
  return min_dist;
}
*/

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
