extends KinematicBody

export var speed = 10
export var max_speed = 15
export var acceleration = 70
export var friction = 6
export var air_friction = 10
export var gravity = -40
export var jump_force = 20
export var mouse_sensitivity = .1
export var controller_sensitivity = 3
export var rot_speed = 5
export var de_acceleration = 10
export (float, 0.05, 1.0) var zoom_speed = 0.5
var camera
var pivot_rot

export (int, 0, 10) var push = 1

var velocity = Vector3.ZERO
var snap_vector = Vector3.ZERO

onready var spring_arm = $SpringArm
onready var pivot = $Pivot
export var cameraMode = "ThirdPerson"


func _ready():
	camera = get_node("SpringArm/Camera").get_global_transform()
	pivot_rot = get_node("Pivot").get_global_transform()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _unhandled_input(event):
	if event.is_action_pressed("click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event.is_action_pressed("toggle_mouse_captured"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		spring_arm.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		

func _physics_process(delta):
	var dir = Vector3()
	
	if Input.is_action_pressed("camera_one"):
		cameraMode = "thirdPerson"
		get_node("SpringArm/Camera").make_current()
		if get_node("OVRFirstPerson/ARVRCamera/"):
			get_node("OVRFirstPerson/ARVRCamera").clear_current()
		get_node("FirstPersonCamera").clear_current()
		
	if Input.is_action_pressed("camera_two"):
		cameraMode = "firstPerson"
		get_node("FirstPersonCamera").make_current()
		if get_node("OVRFirstPerson/ARVRCamera"):
			get_node("OVRFirstPerson/ARVRCamera").clear_current()
		get_node("SpringArm/Camera").clear_current()
	if Input.is_action_pressed("camera_three"):
		cameraMode = "firstPersonVR"
		if get_node("OVRFirstPerson/ARVRCamera/"):
			get_node("OVRFirstPerson/ARVRCamera/").make_current()
		get_node("FirstPersonCamera").clear_current()
		get_node("SpringArm/Camera").clear_current()
	
	if Input.is_action_pressed("move_forward"):
		dir += -spring_arm.get_global_transform().basis.z
	if Input.is_action_pressed("move_backward"):
		dir += spring_arm.get_global_transform().basis.z
	if Input.is_action_pressed("move_left"):
		dir += -spring_arm.get_global_transform().basis.x
	if Input.is_action_pressed("move_right"):
		dir += spring_arm.get_global_transform().basis.x
	if is_on_floor():
		if Input.is_action_pressed("ui_select"):
			velocity.y = jump_force	
	if Input.is_action_pressed("cam_zoom_in"):
		#get_node("SpringArm/Camera").fov -= zoom_speed
		var spring_length = get_node("SpringArm").spring_length
		var new_length = clamp(spring_length-zoom_speed, 1, 30)
		get_node("SpringArm").spring_length = new_length
		
	if Input.is_action_pressed("cam_zoom_out"):
		#get_node("SpringArm/Camera").fov += zoom_speed
		var spring_length = get_node("SpringArm").spring_length
		var new_length = clamp(spring_length+zoom_speed, 1, 30)
		get_node("SpringArm").spring_length = new_length
		
	dir.y = 0
	dir = dir.normalized()
	
	velocity.y += delta * gravity
	
	var hv = velocity
	hv.y = 0
	
	var new_pos = dir * speed
	var accel = de_acceleration
	
	if (dir.dot(hv) > 0):
		accel = acceleration
		
	hv = hv.linear_interpolate(new_pos, accel * delta)
	
	velocity.x = hv.x
	velocity.z = hv.z
	
	velocity = move_and_slide(velocity, Vector3(0,1,0))
