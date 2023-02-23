extends RigidBody3D

class_name EntityBody


var pending_moves: Queue = Queue.new(64)
var move_integrators = EntityForceIntegratorSet.new()


func _ready():
    self.top_level = true


func _integrate_forces(state: PhysicsDirectBodyState3D):
    if self.pending_moves.has_elements():
        self.move_integrators.integrate(state, self.pending_moves.elements)
        self.pending_moves.empty()


func add_move(type: int, move: Vector3):
    self.pending_moves.push([type, move])


func add_move_type(type: int, integrator: EntityForceIntegrator):
    self.move_integrators.add(type, integrator)



class EntityForceIntegratorSet:
    var _set: Array = []


    func add(type: int, integrator: EntityForceIntegrator):
        Util.push_at_index(type, integrator, self._set)


    func remove(type: int, integrator: EntityForceIntegrator):
        Util.drop_at_index(type, integrator, self._set)

    # forces: Array[[int, Vector3]]
    func integrate(state: PhysicsDirectBodyState3D, forces: Array) -> void:
        var groups: Array = []
        for force in forces:
            Util.push_at_index(force[0], force[1], groups)

        for type in (groups.size() - 1):
            var integrators: Array[EntityForceIntegrator] = self._set[type]
            if integrators == null: continue

            var type_forces: Array[Vector3] = groups[type]
            self._integrate_type(type_forces, integrators, state)


    func _integrate_type(
        forces: Array[Vector3],
        integrators: Array[EntityForceIntegrator],
        state: PhysicsDirectBodyState3D
    ) -> void:
        var scaled = forces.map(func (v): return v * state.step)

        for integr in integrators:
            integr.integrate(scaled, state)



class EntityForceIntegrator:


    func integrate(forces: Array, state: PhysicsDirectBodyState3D):
        push_error("integrate() should be overridden!")



class Util:


    static func push_at_index(idx: int, val: Variant, arr: Array) -> void:
        if arr.size() <= idx:
            arr.resize(idx + 1)
            arr.insert(idx, [val])
        else:
            arr[idx].append(val)


    static func drop_at_index(idx: int, val: Variant, arr: Array) -> void:
        if arr.size() <= idx:
            return

        var pos = arr[idx].find(val)
        if pos < 0: return

        arr[idx][pos] = null
