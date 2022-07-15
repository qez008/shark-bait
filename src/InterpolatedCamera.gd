extends Camera3D

@export var target_node: Node3D
@export var speed: float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


#if (has_node(target)) {
#		Spatial *node = Object::cast_to<Spatial>(get_node(target));
#		if (!node) {
#			break;
#		}
#
#		float delta = speed * get_process_delta_time();
#		Transform target_xform = node->get_global_transform();
#		Transform local_transform = get_global_transform();
#		local_transform = local_transform.interpolate_with(target_xform, delta);
#		set_global_transform(local_transform);
#		Camera *cam = Object::cast_to<Camera>(node);
#		if (cam) {
#			if (cam->get_projection() == get_projection()) {
#				float new_near = Math::lerp(get_znear(), cam->get_znear(), delta);
#				float new_far = Math::lerp(get_zfar(), cam->get_zfar(), delta);
#
#				if (cam->get_projection() == PROJECTION_ORTHOGONAL) {
#					float size = Math::lerp(get_size(), cam->get_size(), delta);
#					set_orthogonal(size, new_near, new_far);
#				} else {
#					float fov = Math::lerp(get_fov(), cam->get_fov(), delta);
#					set_perspective(fov, new_near, new_far);
#				}
#			}
#		}
#	}

func _process(delta):
	if not target_node:
		return
		
	global_transform = global_transform.interpolate_with(target_node.global_transform, delta * speed)
	
