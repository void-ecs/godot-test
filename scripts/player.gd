extends KinematicBody2D

export var gravity = 1000
export var acceleration = 2000
export var deceleration = 4000
export var maxSpeed = 500
export var jumpForce = 800
export var maxJump = 2

var velocity = Vector2(0, 0)
var moveLeft = false
var moveRight = false
var jumpCount = 0

func _ready():
  set_fixed_process(true)
  set_process_unhandled_input(true)

func _unhandled_input(event):
  if event.is_action_pressed('move_left'):
    moveLeft = true
    moveRight = false
  elif event.is_action_released('move_left'):
    moveLeft = false
    if Input.is_action_pressed('move_right'): moveRight = true
  elif event.is_action_pressed('move_right'):
    print('RIGHT')
    moveRight = true
    moveLeft = false
  elif event.is_action_released('move_right'):
    moveRight = false
    if Input.is_action_pressed('move_left'): moveLeft = true
  elif event.is_action_pressed('jump'):
    if jumpCount < maxJump:
      velocity.y = -jumpForce
      jumpCount += 1

func _fixed_process(delta):
  velocity.y = min(velocity.y + gravity * delta, maxSpeed)

  if moveLeft:
    velocity.x = max(velocity.x - acceleration * delta, -maxSpeed)
  elif moveRight:
    velocity.x = min(velocity.x + acceleration * delta, maxSpeed)
  else:
    if velocity.x > 0:
      velocity.x = max(0, velocity.x - deceleration * delta)
    elif velocity.x < 0:
      velocity.x = min(0, velocity.x + deceleration * delta)

  var movement = velocity * delta
  var remainder = move(movement)

  while is_colliding():
    jumpCount = 0
    var normal = get_collision_normal()
    movement = normal.slide(remainder)
    velocity = normal.slide(velocity)
    remainder = move(movement)
