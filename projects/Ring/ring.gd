extends Sprite2D
class_name Ring

var effect := "effect_none"

func _ready() -> void:
	scale = Vector2.ONE*0.1

func _process(delta: float) -> void:
	scale += Vector2.ONE* 1/scale.x * 3 * delta


func _on_timer_timeout() -> void:
	queue_free()



## Effects ##
static func effect_none(bit: Bit) -> void:
	pass

func effect_A(bit: Bit) -> void:
	if !"mana" in bit.states:
		bit.states["mana"] = 0.0
	bit.states["mana"] += 100.0

func effect_B(bit: Bit) -> void:
	bit.states["nature"] = 1.0 # seconds

func effect_C(bit: Bit) -> void:
	if !"earth" in bit.states:
		bit.states["earth"] = 1.0
	bit.states["earth"] *= 1.1
	bit.states["earth"] += 0.1
