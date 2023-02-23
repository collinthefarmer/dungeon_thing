extends RigidBody3D

# class_name Player

var controller: PlayerController
var debugpanel: PlayerDebugPanel

var debugpanel_scene: PackedScene = load("res://player_debugpanel.tscn")


var GLOBAL_PLAYER_MOVE_FORCE = 100000.
var GLOBAL_PLAYER_OOMPH_CHECK_THRESHOLD = 0.1
var GLOBAL_PLAYER_OOMPH_IMPULSE_FACTOR = 2.2


@export
var player_moveforce_multiplier: float = 5.

@export
var player_moveforce_air_factor: float = .2

@export
var player_jumpforce_multiplier: float = 50.

@export
var player_max_vel_mag: float = 8

@export
var player_use_debugpanel: bool = true


@onready
var head: Node3D = self.get_child(0)

@export
var player_velocity_threshold: float = 0.0;
var player_velocity : get = get_player_velocity
func get_player_velocity() -> Vector3:
    return Vector3(
        snapped(self.linear_velocity.x, 0.01),
        snapped(self.linear_velocity.y, 0.01),
        snapped(self.linear_velocity.z, 0.01)
    )


@export
var is_grounded_radius: float = 0.0;

var is_grounded_ray: RayCast3D
var is_grounded : get = get_is_grounded
func get_is_grounded() -> bool:
    return self.is_grounded_ray.is_colliding()


func _ready():
    self.create_controller()
    self.create_is_grounded_ray();
    if (self.player_use_debugpanel): self.create_debugpanel()


func create_controller() -> void:
    self.controller = PlayerController.new(self)
    self.add_child(self.controller)

    self.controller.move_requests.connect(self.handle_player_move)
    self.controller.turn_requests.connect(self.handle_player_turn)


func create_is_grounded_ray() -> void:
    self.is_grounded_ray = RayCast3D.new()
    self.add_child(self.is_grounded_ray)


func create_debugpanel() -> void:
    self.debugpanel = debugpanel_scene.instantiate()
    self.debugpanel.player = self

    self.add_child(self.debugpanel)


func player_can_move(dir: Vector3) -> bool:
    var ground_vel = Vector3(self.player_velocity.x, 0, self.player_velocity.z)
    var ground_dir = Vector3(dir.x, 0, dir.z)

    # i.e., is player attempting to travel in same direction they're already going
    if ground_dir.normalized().dot(ground_vel.normalized()) >= 0:
        return ground_vel.length_squared() < self.player_max_vel_mag

    return true


func player_can_jump() -> bool:
    return self.is_grounded


func handle_player_move(dir: Vector3) -> void:
    if (dir.y != 0.):
        self.apply_player_jump(dir)
        return

    var head_dir = dir.rotated(Vector3.UP, self.head.rotation.y)
    if (!self.player_can_move(head_dir)): return

    self.apply_player_force(
        head_dir
        * self.player_moveforce_multiplier
        * (1 if self.is_grounded else player_moveforce_air_factor)
    )


func handle_player_turn(dir: Vector3):
    self.head.rotation -= dir


func apply_player_jump(dir: Vector3) -> void:
    if (!self.player_can_jump()): return
    var jump_vector = Vector3(0, dir.y, 0)
    self.apply_player_force(jump_vector * self.player_jumpforce_multiplier)


func should_apply_oomph(dir: Vector3) -> bool:
    var travel_dir = self.player_velocity.normalized()
    var pforce_dir = dir.normalized()

    return (
        travel_dir.dot(pforce_dir) < self.GLOBAL_PLAYER_OOMPH_CHECK_THRESHOLD
        and self.is_grounded
    )


func apply_player_oomph(dir: Vector3) -> void:
    var vel_dir = self.player_velocity.normalized()
    var mov_dir = dir.normalized()

    var impulse_force = ((mov_dir - vel_dir)
        * mov_dir.length_squared()
        * self.mass
        * self.GLOBAL_PLAYER_OOMPH_IMPULSE_FACTOR
    )

    if self.player_use_debugpanel:
        self.debugpanel.message_queue.push(
            self.debugpanel.vector3_repr(impulse_force, "oomph applied")
        )

    self.apply_central_impulse(impulse_force)


func apply_player_force(dir: Vector3) -> void:
    if (self.should_apply_oomph(dir)): self.apply_player_oomph(dir)
    self.apply_central_force(dir * self.GLOBAL_PLAYER_MOVE_FORCE)

