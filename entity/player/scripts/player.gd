extends Entity

class_name Player


enum MOVE_TYPE {
    CONTROLLED,
    CONTROLLED_FAST
}

@onready
var camera: Camera3D = $camera


func _ready():
    super._ready()
    self._connect_controller()



func _connect_controller():
    self.controller.moves.connect(
        func (move: Vector3): self.body.add_move(
            MOVE_TYPE.CONTROLLED,
            move
        )
    )

    self.body.add_move_type(
        MOVE_TYPE.CONTROLLED,
        PlayerControlledMove.new()
    )



class PlayerControlledMove extends EntityBody.EntityForceIntegrator:

    func integrate(moves: Array, state: PhysicsDirectBodyState3D):
        state.apply_central_force(moves[0] * 1000)
