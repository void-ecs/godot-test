extends KinematicBody2D

var Wall = load('res://scripts/Wall.gd')
var Ground = load('res://scripts/Ground.gd')

export var gravity = 1000
export var acceleration = 2000
export var deceleration = 4000
export var maxSpeed = 500
export var speedOnWall = 100
export var jumpForce = 800
export var maxJump = 2

var velocity = Vector2(0, 0)
var moveLeft = false
var moveRight = false
var jumpCount = 0
var jumping = false
var falling = true
var onWall = false

var playerState = 'in-air'

func jump():
  if jumpCount < maxJump or onWall:
    velocity.y = -jumpForce
    jumpCount += 1
    playerState = 'in-air'
    jumping = true

    if onWall:
      if moveRight:
        velocity.x = -jumpForce * 0.6
      elif moveLeft:
        velocity.x = jumpForce * 0.6

func _ready():
  set_fixed_process(true)
  set_process_unhandled_input(true)

func _unhandled_input(event):
  if event.is_action_pressed('move_left'):
    moveLeft = true
    moveRight = false
    prints('LEFT +', moveLeft, moveRight)
  elif event.is_action_released('move_left'):
    moveLeft = false
    if Input.is_action_pressed('move_right'): moveRight = true
    prints('Left -', moveLeft, moveRight)
  elif event.is_action_pressed('move_right'):
    moveRight = true
    moveLeft = false
    prints('RIGHT +', moveLeft, moveRight)
  elif event.is_action_released('move_right'):
    moveRight = false
    if Input.is_action_pressed('move_left'): moveLeft = true
    prints('RIGHT -', moveLeft, moveRight)
  elif event.is_action_pressed('jump'): jump()

func _fixed_process(delta):
  if playerState == 'landed':
    landedState(delta)
  elif playerState == 'in-air':
    inAirState(delta)

func landedState(delta):
  if moveLeft:
    velocity.x = max(velocity.x - acceleration * delta, -maxSpeed)
  elif moveRight:
    velocity.x = min(velocity.x + acceleration * delta, maxSpeed)
  else:
    if velocity.x > 0:
      velocity.x = max(0, velocity.x - deceleration * delta)
    elif velocity.x < 0:
      velocity.x = min(0, velocity.x + deceleration * delta)

  velocity.y = 0

  var movement = velocity * delta
  var remainder = move(movement)

  if is_colliding():
    var normal = get_collision_normal()
    movement = normal.slide(remainder)
    velocity = normal.slide(velocity)
    move(movement)

func inAirState(delta):
  velocity.y = min(velocity.y + gravity * delta, maxSpeed)

  if velocity.y > 0:
    jumping = false
    falling = true

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

  onWall = false

  if is_colliding():
    var collider = get_collider()
    
    if collider extends Ground:
      playerState = 'landed'
      jumpCount = 0
      falling = false
      var normal = get_collision_normal()
      velocity = normal.slide(velocity)
      movement = normal.slide(remainder)
      move(movement)
    elif collider extends Wall:
      if jumping:
        var normal = get_collision_normal()
        velocity = normal.slide(velocity)
        movement = normal.slide(remainder)
        move(movement)
      elif falling:
        onWall = true
        velocity.x = 0
        if velocity.y > speedOnWall:
          velocity.y = speedOnWall
        else:
          velocity.y = lerp(velocity.y, speedOnWall, delta)
        move(velocity * delta)
