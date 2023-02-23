extends RigidBody3D

class_name EntityBody

signal move(dir: Vector3, type: MOVE_TYPE)
signal turn(dir: Vector3, type: TURN_TYPE)


enum MOVE_TYPE {
    CONTROLLED = 0,
    CONTROLLED_FAST = 1
}


enum TURN_TYPE {
    CONTROLLED = 0
}


var pending_moves: Queue = Queue.new(64)

var _integrators: Array[EntityMoveIntegrator] = []
func add_move_integrator(type: MOVE_TYPE, integrator: EntityMoveIntegrator):
    if self._integrators.size() <= type: self._integrators.resize(type)
    self._integrators.insert(type, integrator)


func _integrate_forces(state: PhysicsDirectBodyState3D):
    self._integrate_moves(state)


func _integrate_moves(state: PhysicsDirectBodyState3D):
    var grouped: Array = self.pending_moves.reduce(self._group_moves, [])

    for type in grouped.size():
        var integrator = self._integrators[type]

        if integrator == null:
            continue

        var moves = grouped[type]
        integrator.integrate(moves, state)

    self.pending_moves.empty()


func _group_moves(groups: Array, this_move: Array):
    var move = this_move[0]
    var type = this_move[1]

    if groups.size() > type:
        # we've had a move of this type
        groups[type].append(move)
        return groups

    groups.resize(type)
    groups.insert(type, [move])
    return groups



