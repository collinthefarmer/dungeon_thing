extends Entity

class_name Player


func _ready():
    super._ready()

    self.body.add_move_integrator(
        EntityBody.MOVE_TYPE.CONTROLLED,
        PlayerControlledMove.new()
    )




class PlayerControlledMove extends EntityMoveIntegrator:

    func integrate(moves: Array, state: PhysicsDirectBodyState3D):
        print(moves)
