extends Node

class_name Entity




@onready
var controller: EntityController = $controller


@onready
var body: EntityBody = $body


func map_move(dir: Vector3) -> Vector3:
    return dir


func map_turn(dir: Vector3) -> Vector3:
    return dir


func _ready():
    self._check_ready()
    self._connect_body_controller()

    self._reparent()


func _check_ready():
    if controller == null:
        push_error("Entity readied without controller")

    if body == null:
        push_error("Entity readied without body")


func _connect_body_controller():
    self.controller.connect(
        "moves",
        func (move: Vector3): self.body.pending_moves.push([
                move, EntityBody.MOVE_TYPE.CONTROLLED
            ])
    )

func _reparent():
    self.body.add_child(self)
