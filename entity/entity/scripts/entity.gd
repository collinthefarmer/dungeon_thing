extends Node3D

class_name Entity


@onready
var controller: EntityController = $controller

@onready
var body: EntityBody = $body

@onready
var body_collider: CollisionShape3D = $body_collider


func _ready():
    self._check_ready()


func _process(delta):
    self.global_position = self.body.global_position


func _check_ready():
    if controller == null:
        push_error("Entity readied without controller.")

    if body == null:
        push_error("Entity readied without body.")

    if body_collider == null:
        push_error("Entity readied without body_collider.")
