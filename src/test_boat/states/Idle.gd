extends StateMachine.State


var body: Boat


func _init(sm).(sm, "climbing"):
    pass


func _unhandled_input(event: InputEvent):
    if event.is_action_pressed("ui_up"):
        sm.transition("sailing")

