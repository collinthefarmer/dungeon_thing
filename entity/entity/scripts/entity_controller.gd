extends Node

class_name EntityController


var move_queue: Queue = Queue.new(8)
var turn_queue: Queue = Queue.new(8)

signal moves(dir: Vector3)
signal turns(dir: Vector3)


func move(dir: Vector3):
    self.move_queue.push(dir)


func turn(dir: Vector3):
    self.turn_queue.push(dir)


func _process(_delta):
    if self.move_queue.has_elements(): self._emit_move()
    if self.turn_queue.has_elements(): self._emit_turn()


func _emit_move():
    var move: Vector3 = self.move_queue.reduce(self._coalesce, Vector3.ZERO)
    self.move_queue.empty()

    self.moves.emit(move.normalized())


func _emit_turn():
    var turn: Vector3 = self.turn_queue.elements.back()
    self.turn_queue.empty()

    self.turns.emit(turn.normalized())


# ignore previous values if they're very different (cleans up movement reqs.)
func _coalesce(merged: Vector3, vec: Vector3) -> Vector3:
    var this_diff = merged.normalized().dot(vec.normalized())
    return merged + vec if (this_diff > 0) else vec
