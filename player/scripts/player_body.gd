extends RigidBody3D

class_name PlayerBody


signal move_commands(vec: Vector3, rel_impulse_str: float)


func _integrate_forces(state: PhysicsDirectBodyState3D):
    pass
