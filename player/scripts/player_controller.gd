extends Node

# class_name PlayerController

var player: Player

var turn_invert_x: bool = false
var turn_invert_y: bool = false
var turn_sensitivity: float = 0.5

signal move_requests(dir: Vector3)
signal turn_requests(dir: Vector3)

var move_queue: Queue = Queue.new(8)
var turn_queue: Queue = Queue.new(8)

var _vector_sum = func (acc, cur): return acc + cur

func _init(controls: Player):
    self.player = controls

func _physics_process(delta):
    self.check_move_input()
    self.check_jump_input()
    self.emit_controller_requests(delta)

func _unhandled_input(event: InputEvent):
    if (event is InputEventMouseMotion):
        self.check_turn_input(event)

func check_move_input():
    var inputs = Input.get_vector(
        "mv_x_neg", "mv_x_pos",
        "mv_z_neg", "mv_z_pos")

    var move = Vector3(inputs.x, 0., -inputs.y) # negative z comp. cuz Godot
    if move != Vector3.ZERO: move_queue.push(move)

func check_turn_input(event: InputEventMouseMotion):
    var x_turn = event.relative.x
    var y_turn = event.relative.y

    var turn = Vector3(
        (1 - (2 * int(self.turn_invert_y))) * y_turn,
        (1 - (2 * int(self.turn_invert_x))) * x_turn,
        0.)

    if turn != Vector3.ZERO: turn_queue.push(turn)

func check_jump_input():
    var input = Input.is_action_just_released("mv_jump")
    if (input): move_queue.push(Vector3.UP)

func emit_controller_requests(delta: float):
    if self.move_queue.has_elements():
        self.move_requests.emit(
            self.move_queue.reduce(_vector_sum, Vector3.ZERO).normalized()
            * delta
        )

    if self.turn_queue.has_elements():
        self.turn_requests.emit(
            self.turn_queue.reduce(_vector_sum, Vector3.ZERO)
            * delta
            * self.turn_sensitivity
        )
