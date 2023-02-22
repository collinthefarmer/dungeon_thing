extends RigidBody3D

class_name EntityBody


signal move_commands(vec: Vector3, oomph_str: float)

var command_sum: Vector3 = Vector3.ZERO

func _ready():
    move_commands

func _integrate_forces(state: PhysicsDirectBodyState3D):
    pass
