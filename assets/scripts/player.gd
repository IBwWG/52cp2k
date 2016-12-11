extends RigidBody

var view_sensitivity = 0.3;
var sighted = null;
var last = ""

const walk_speed = 5;
const jump_speed = 3;
const max_accel = 0.02;
const air_accel = 0.1;

func _input(ie):
	if ie.type == InputEvent.MOUSE_MOTION:
		var body = get_node("body")
		var camera = get_node("body/camera")
		var yaw = rad2deg(body.get_rotation().y);
		var pitch = rad2deg(camera.get_rotation().x);
		
		yaw = fmod(yaw - ie.relative_x * view_sensitivity, 360);
		pitch = max(min(pitch + ie.relative_y * view_sensitivity, 90), -90);
		
		body.set_rotation(Vector3(0, deg2rad(yaw), 0));
		camera.set_rotation(Vector3(deg2rad(pitch), 0, 0));
		
		check_ray()
	elif (ie.type == InputEvent.MOUSE_BUTTON and ie.pressed and sighted != null):
		var green_mat = FixedMaterial.new()
		green_mat.set_parameter(green_mat.PARAM_DIFFUSE, Color(0, 1, 0, 1))
		sighted.get_node("mesh").set_material_override(green_mat)


func check_ray():
	sighted = null
	var camRay = get_node("body/camera/camRay")
	if (camRay.is_colliding()):
		printNoRepeat(camRay.get_collider().get_name())
		var collider = camRay.get_collider()
#		if (collider.has_meta("is_card")):
		sighted = collider
	elif (camRay.get_collider() != null):
		printNoRepeat("noncol " + camRay.get_collider().get_name())

func printNoRepeat(what):
	if (last != what):
		print(what)
		last = what

func _integrate_forces(state):
	
	var aim = get_node("body").get_global_transform().basis;
	var direction = Vector3();
	
	if Input.is_key_pressed(KEY_W):
		direction -= aim[2];
	if Input.is_key_pressed(KEY_S):
		direction += aim[2];
	if Input.is_key_pressed(KEY_A):
		direction -= aim[0];
	if Input.is_key_pressed(KEY_D):
		direction += aim[0];
	direction = direction.normalized();
	if (direction.length() > 0):
		check_ray()
	
	var ray = get_node("ray");
	if ray.is_colliding():
		var up = state.get_total_gravity().normalized();
		var normal = ray.get_collision_normal();
		var floor_velocity = Vector3();
		
		var speed = walk_speed;
		var diff = floor_velocity + direction * walk_speed - state.get_linear_velocity();
		var vertdiff = aim[1] * diff.dot(aim[1]);
		diff -= vertdiff;
		diff = diff.normalized() * clamp(diff.length(), 0, max_accel / state.get_step());
		diff += vertdiff;
		apply_impulse(Vector3(), diff * get_mass());
		
		if Input.is_key_pressed(KEY_SPACE):
			#apply_impulse(Vector3(), normal * jump_speed * get_mass());
			apply_impulse(Vector3(), Vector3(0,1,0) * jump_speed * get_mass());
		if Input.is_key_pressed(KEY_M):
			get_node("body/camera").set_translation(Vector3(0,0.5,0))
		else:
			get_node("body/camera").set_translation(Vector3(0,1.4,0))
	else:
		apply_impulse(Vector3(), direction * air_accel * get_mass());
	state.integrate_forces();

func _ready():
	set_process_input(true)
	set_fixed_process(true)
	get_node("body/camera/camRay").add_exception(self)

func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
