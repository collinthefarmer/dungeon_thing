extends Control

class_name PlayerDebugPanel

@onready
var player: RigidBody3D

@onready
var player_velocity_label: Label

@onready
var linear_velocity_label: Label

@onready
var is_grounded_label: Label

@onready
var message_queue_container: VBoxContainer

var message_queue: Queue = Queue.new(24)


func vector3_repr(vector: Vector3, vector_name: String) -> String:
    return "%s: [%+5.3f, %+5.3f, %+5.3f]; mag: %+8.3f" % [
        vector_name,
        snapped(vector.x, 0.01),
        snapped(vector.y, 0.01),
        snapped(vector.z, 0.01),
        snapped(vector.length_squared(), 0.01)
    ]


func _ready():
    self._initialize_panel()


func _initialize_panel():
    self.player_velocity_label = self.get_node("PanelContainer/ControlContainer/PlayerVelocityLabel")
    self.linear_velocity_label = self.get_node("PanelContainer/ControlContainer/LinearVelocityLabel")
    self.is_grounded_label = self.get_node("PanelContainer/ControlContainer/IsGroundedLabel")

    self.message_queue_container = self.get_node("PanelContainer/MessageQueueScrollContainer/MessageQueueContainer")


func _process(delta):
    self._update_values()


func _update_values():
    self.player_velocity_label.text = self.vector3_repr(self.player.player_velocity, "player_vel")
    self.linear_velocity_label.text = self.vector3_repr(self.player.linear_velocity, "linear_vel")
    self.is_grounded_label.text = "is_grounded: %s" % self.player.is_grounded

    while self.message_queue.has_elements():
        var message_label = Label.new()

        self.message_queue_container.add_child(message_label)
        self.message_queue_container.move_child(message_label, 0)

        message_label.text = self.message_queue.next()
