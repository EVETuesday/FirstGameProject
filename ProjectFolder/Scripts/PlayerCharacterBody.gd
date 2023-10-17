extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var speed = 150.0
@export var jump_velocity = -250.0
@export var acceleration = 1200.0
@export var coyote_jump_delay = 0.15
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var label = $Label
var is_able_to_double_jump = true

#Ф-я при запуске
func _ready():
	coyote_jump_timer.wait_time = coyote_jump_delay


#Ф-ии персонажа
#Ф-я гравитации
func apply_gravity(delta):
		if not is_on_floor():
			velocity.y += gravity * delta

#Ф-я движения
func process_movement(delta):
	var input_axis = Input.get_axis("PlayerLeft", "PlayerRight")
	if input_axis:
		apply_acceleration(delta, input_axis)
	else:
		apply_friction(delta)

#Ф-я ускорения
func apply_acceleration(delta, direction):
	velocity.x = move_toward(velocity.x, speed * direction, acceleration * delta)

#Ф-я остановки
func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, acceleration * delta)

#Ф-я прыжка
func handle_jump():
	if Input.is_action_just_pressed("PlayerJump"):
		if is_on_floor() or coyote_jump_timer.time_left > 0.0:
			velocity.y = jump_velocity
		if is_able_to_double_jump and not (is_on_floor() or coyote_jump_timer.time_left > 0.0):
			velocity.y = jump_velocity
			is_able_to_double_jump = false

#Ф-я восстановления двойного прыжка
func restore_double_jump():
	if is_on_floor_only():
		is_able_to_double_jump = true
#Ф-я физики
func _physics_process(delta):
	apply_gravity(delta)
	process_movement(delta)
	restore_double_jump()
	handle_jump()
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_edge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_edge:
		coyote_jump_timer.start()
		
	if is_able_to_double_jump:
		label.text = "Могу"
	else:
		label.text = "Не могу"
