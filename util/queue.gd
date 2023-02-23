class_name Queue

var elements: Array = []
var elements_n: int = 0

var size: int

var size_exceed_f: Callable

func _init(queue_size: int, on_size_exceeded: Callable = self.next):
    self.size = queue_size
    self.size_exceed_f = on_size_exceeded

func push(el):
    self.elements.append(el)
    self.elements_n += 1
    if (self.elements_n > self.size):
        self.size_exceed_f.call(elements, elements_n, size)

func next():
    var el = self.elements.pop_front()
    self.elements_n -= 1
    return el

func empty():
    var cur_elements = self.elements
    self.elements = []
    self.elements_n = 0
    return cur_elements

func has_elements():
    return self.elements_n > 0

# uses a standard '(acc, cur) => X' -style function to reduce the elements array
func reduce(f: Callable, default):
    var itr = self.elements
    itr.reverse()

    var acc = default
    for cur in itr:
        acc = f.call(acc, cur)

    return acc
