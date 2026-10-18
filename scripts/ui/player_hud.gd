extends CanvasLayer
class_name UnderkingdomPlayerHUD

## HUD del Player: vida, Ultimate, llave y contadores de inventario.
## Va como hijo del Player y lee sus señales; no guarda estado propio.

@export_range(0.0, 1.0, 0.05) var ultimate_charging_alpha: float = 0.55

@onready var health_bar: TextureProgressBar = $Raiz/BarraVida
@onready var ultimate_bar: TextureProgressBar = $Raiz/BarraUltimate
@onready var key_icon: TextureRect = $Raiz/IconoLlave
@onready var coins_label: Label = $Inventario/MonedasTexto
@onready var potions_label: Label = $Inventario/PocionesTexto

var _player: Node = null


func _ready() -> void:
    _player = get_parent()

    if _player != null and _player.has_signal("health_changed"):
        _player.connect("health_changed", _on_health_changed)

    GameManager.world1_boss_key_changed.connect(_on_key_changed)
    GameManager.key_changed.connect(_on_named_key_changed)
    key_icon.visible = GameManager.has_any_key()
    GameManager.coins_changed.connect(_on_coins_changed)
    GameManager.potions_changed.connect(_on_potions_changed)
    _on_coins_changed(GameManager.coins)
    _on_potions_changed(GameManager.potions)


func _process(_delta: float) -> void:
    if not is_instance_valid(_player) or not _player.has_method("get_ultimate_ready_ratio"):
        return

    var ratio := float(_player.call("get_ultimate_ready_ratio"))
    ultimate_bar.value = ratio
    ultimate_bar.modulate.a = 1.0 if ratio >= 1.0 else ultimate_charging_alpha


func _on_health_changed(current_health: float, max_health: float) -> void:
    health_bar.max_value = max_health
    health_bar.value = current_health


func _on_key_changed(_has_key: bool) -> void:
    key_icon.visible = GameManager.has_any_key()


func _on_named_key_changed(_key_id: String, _has_key: bool) -> void:
    key_icon.visible = GameManager.has_any_key()


func _on_coins_changed(value: int) -> void:
    coins_label.text = "Monedas: %d" % value


func _on_potions_changed(value: int) -> void:
    potions_label.text = "Pociones: %d [C]" % value
