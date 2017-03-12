
extends KinematicBody2D

# Member variables
const MAX_SPEED = 300.0
const IDLE_SPEED = 10.0
const ACCEL = 5.0
const SHOOT_INTERVAL = 0.3

var speed = Vector2()
var shoot_countdown = 0
var joydir
var debugLabel
var blockMouse = false
var joystickInUse = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	set_process_input(true)
	debugLabel = get_node("/root/Main Node/CanvasLayer/DebugLabel")
	debugLabel.set_text("Hello")
	pass
	
	
func _input(event):

	if event.type == InputEvent.SCREEN_TOUCH:
		if (shoot_countdown <= 0):
			shoot(event)
		debugLabel.set_text(str(event.index))
		blockMouse = true
		#shoot(event)
	if (!blockMouse and event.type == InputEvent.MOUSE_BUTTON and event.button_index == 1 and event.pressed and shoot_countdown <= 0):
		debugLabel.set_text("MOUSE")
		shoot(event)
	

func shoot(event):
	var pos = get_canvas_transform().affine_inverse()*event.pos
	var dir = (pos - get_global_pos()).normalized()
	var bullet = preload("res://bullet.tscn").instance()
	bullet.advance_dir = dir
	bullet.set_pos(get_global_pos() + dir*60)
	get_parent().add_child(bullet)
	shoot_countdown = SHOOT_INTERVAL

func analog_force_change(inForce, inAnalog):	
	if(inAnalog.get_name()=="Analog"):
		# uh oh
		joydir = inForce
		joydir.y *= -1
		pass
		

func _fixed_process(delta):
	
	shoot_countdown = shoot_countdown - delta

	var dir = Vector2()
	if (Input.is_action_pressed("up")):
		dir += Vector2(0, -1)
	if (Input.is_action_pressed("down")):
		dir += Vector2(0, 1)
	if (Input.is_action_pressed("left")):
		dir += Vector2(-1, 0)
	if (Input.is_action_pressed("right")):
		dir += Vector2(1, 0)
	if (joydir != null):
		dir = joydir
	
	if (dir != Vector2()):
		dir = dir.normalized()
	speed = speed.linear_interpolate(dir*MAX_SPEED, delta*ACCEL)
	var motion = speed*delta
	motion = move(motion)
	
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		move(motion)
