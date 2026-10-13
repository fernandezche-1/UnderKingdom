extends CanvasLayer
class_name UnderkingdomPlayerHUD

## HUD del Player: vida en cuartos de corazón, carga de Ultimate y llave.
## Va como hijo del Player y lee sus señales; no guarda estado propio.

@export_range(0.0, 1.0, 0.05) var ultimate_charging_alpha: float = 0.55

@onready var health_bar: TextureProgressBar = $Raiz/BarraVida
@onready var ultimate_bar: TextureProgressBar = $Raiz/BarraUltimate
@onready var key_icon: TextureRect = $Raiz/IconoLlave

var _player: Node = null


func _ready() -> void:
    _player = get_parent()

    if _player != null and _player.has_signal("health_changed"):
        _player.connect("health_changed", _on_health_changed)

    GameManager.world1_boss_key_changed.connect(_on_key_changed)
    key_icon.visible = GameManager.has_world1_boss_key()


func _process(_delta: float) -> void:
    if not is_instance_valid(_player) or not _player.has_method("get_ultimate_ready_ratio"):
        return

    var ratio := float(_player.call("get_ultimate_ready_ratio"))
    ultimate_bar.value = ratio
    ultimate_bar.modulate.a = 1.0 if ratio >= 1.0 else ultimate_charging_alpha


func _on_health_changed(current_health: float, max_health: float) -> void:
    health_bar.max_value = max_health
    health_bar.value = current_health


func _on_key_changed(has_key: bool) -> void:
    key_icon.visible = has_key
