extends EntityController

class_name PlayerController


const MOVE_ACTIONS = [
    "mv_x_neg",
    "mv_x_pos",
    "mv_z_neg",
    "mv_z_pos"
]

const JUMP_ACTION = "mv_jump"


func _unhandled_input(event: InputEvent):
    if event is InputEventMouseMotion:
        self._push_turn_input(event)

    if event.is_action_released(JUMP_ACTION):
        self._push_jump_input()


func _process(_delta):
    super._process(_delta)
    self._stream_move_inputs()


func _push_turn_input(event: InputEventMouseMotion):
    self.turn_queue.push(Vector3(event.velocity.x, event.velocity.y, 0.))


func _push_jump_input():
    self.move_queue.push(Vector3.UP)


func _stream_move_inputs():
    var input_axes: Vector2 = Input.get_vector(
        "mv_x_neg", "mv_x_pos",
        "mv_z_neg", "mv_z_pos"
    )

    if input_axes == Vector2.ZERO: return

    self.move_queue.push(Vector3(input_axes.x, 0., input_axes.y))
