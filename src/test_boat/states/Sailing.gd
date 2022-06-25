extends StateMachine.State


var body: Boat


func _init(sm).(sm, "sailing"):
    pass


func _unhandled_input(event: InputEvent):
    if not event.is_action_pressed("ui_up"):
        sm.transition("idle")
