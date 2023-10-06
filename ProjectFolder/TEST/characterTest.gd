extends CharacterBody2D

#Константы
const SPEED = 100.0
const JUMP_VELOCITY = -250.0
const ACCELERATION = 600
const FRICTION = 1200
const COYOTE_JUMP_DELAY = 0.15

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer

#Ф-я вызывается при нициализации
func _ready():
	coyote_jump_timer.wait_time = COYOTE_JUMP_DELAY
	
#Ф-я стремления вниз апри гравитации
func apply_gravity(delta):
		if not is_on_floor():
			velocity.y += gravity * delta
			
#Ф-я уменьшения скорости при отсутствии нажатия клавиш
func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
#Ф-я увеличения скорости при нажатии клавиш
func apply_acceleration(delta, direction):
	velocity.x = move_toward(velocity.x, SPEED * direction, ACCELERATION * delta)

#Ф-я обновления анимаций
func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	if not is_on_floor():
		animated_sprite_2d.play("jump")

#Физика и основное
func _physics_process(delta):
	apply_gravity(delta)

	#Прыжок
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("CharacterJump"):
			velocity.y = JUMP_VELOCITY

	#Считывание клавиш
	var direction = Input.get_axis("CharacterLeft", "CharacterRight")
	if direction != 0:
		apply_acceleration(delta, direction)
	else:
		apply_friction(delta)
	update_animations(direction)
	var was_on_floor = is_on_floor() #Я хз зачем столько переменных, но иначе оно не работает
	move_and_slide()
	var just_left_edge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_edge:
		coyote_jump_timer.start()

