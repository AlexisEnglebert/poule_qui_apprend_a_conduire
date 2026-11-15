extends CanvasLayer
## Effet "bourré" plein écran.
##
## Installation : Projet > Paramètres du projet > Globals (Autoload),
## ajoute ce script avec le nom « Ivresse ». drunk.gdshader doit être
## dans le même dossier que ce script.
##
## Utilisation depuis n'importe quel script :
##     Ivresse.intensity = 1.0   # réglage direct (0 = sobre, 1 = bourré, 2 = ivre mort)
##     Ivresse.boire()           # +0.25, monte en douceur
##     Ivresse.boire(0.5, 3.0)   # +0.5 sur 3 secondes
##     Ivresse.degriser()        # retour à 0 en douceur

const DRUNK_SHADER := preload("drunk.gdshader")
const MAX_INTENSITY := 3.0

## Intensité de l'effet : 0 = sobre, 0.5 = pompette, 1 = bourré, 2 = ivre mort.
@export_range(0.0, 3.0, 0.01) var intensity: float = 0.0:
	set(value):
		intensity = clampf(value, 0.0, MAX_INTENSITY)
		_apply()

## Intensité perdue par seconde (0 = on ne dessoûle jamais tout seul).
@export var vitesse_degrisement: float = 0.02

var _rect: ColorRect
var _mat: ShaderMaterial
var _tween: Tween


func _init() -> void:
	# L'effet s'applique à tout ce qui est dessiné SOUS ce calque.
	# 100 = par-dessus tout, interface comprise. Pour garder ton UI nette,
	# mets une valeur plus petite que le layer du CanvasLayer de ton UI.
	layer = 100


func _ready() -> void:
	_mat = ShaderMaterial.new()
	_mat.shader = DRUNK_SHADER
	_rect = ColorRect.new()
	_rect.material = _mat
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # ne bloque pas les clics
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_rect)
	_apply()


func _process(delta: float) -> void:
	var tween_actif := _tween != null and _tween.is_running()
	if vitesse_degrisement > 0.0 and intensity > 0.0 and not tween_actif:
		intensity -= vitesse_degrisement * delta


## Ajoute de l'ivresse progressivement.
func boire(quantite: float = 0.25, duree: float = 2.0) -> void:
	_vers(minf(intensity + quantite, MAX_INTENSITY), duree)


## Revient à la sobriété progressivement.
func degriser(duree: float = 1.5) -> void:
	_vers(0.0, duree)


func _vers(cible: float, duree: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	var step := _tween.tween_property(self, "intensity", cible, duree)
	step.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _apply() -> void:
	if _mat == null:
		return
	_mat.set_shader_parameter("intensity", intensity)
	# Quand on est sobre, on coupe le shader : zéro coût GPU.
	_rect.visible = intensity > 0.001
