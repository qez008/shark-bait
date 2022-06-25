class_name StateMachine
extends Node

export (Array, GDScript) var state_scripts = []

var _states: Dictionary
var _state: State

func _ready():
    for script in state_scripts:
        var inst: State = script.new()
        _states[inst.name] = inst

    enter_state(_states[0])


func enter_state(next:State):
    _state = next
    _state._on_enter()


func exit_state():
    _state._on_exit()


func transition(next: String):
    exit_state()
    enter_state(_states[next])



func _process(delta):
    _state._process(delta)


func _physics_process(delta):
    _state._physics_process(delta)


func _input(event):
    _state._input(event)


func _unhandled_input(event):
    _state._unhandled_input(event)


func _unhandled_key_input(event):
    _state._unhandled_key_input(event)





class State:

    var name: String

    func _init(name=""):
        self.name = name


    # virtual methods:

    func _on_enter():
        pass

    func _on_exit():
        pass

    func _process(delta):
        pass

    func _physics_process(delta):
        pass

    func _input(event):
        pass

    func _unhandled_input(event):
        pass

    func _unhandled_key_input(event):
        pass
