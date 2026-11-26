extends RefCounted
## Catálogo del banco. Las afinaciones distinguen criaturas dentro de cada familia.

const MAPAS := {
	"menu_principal": "menu", "cinematica_inicial": "introduccion",
	"camara_sellado_alma": "prision", "tiles_calabozo": "calabozo",
	"tiles_castillo": "castillo", "tiles_cementerio": "cementerio",
	"tiles_mineria": "minas", "tiles_mazmorra": "mazmorra", "tiles_ruina": "ruina",
	"tiles_profundidades": "profundidades", "tiles_infierno": "infierno",
	"tiles_casa": "castillo", "tiles_jefe": "infierno", "jefe_final": "infierno",
	"mundo_1": "cementerio", "mundo_2": "mazmorra", "mundo_3": "profundidades",
	"primer_boss_mundo_1": "cementerio", "ruina": "ruina", "profundidades": "profundidades",
	"arena_enemigos": "pruebas", "prueba_tileset": "pruebas",
	"ejemplo_cueva": "minas", "ejemplo_nivel": "calabozo", "antorhca": "calabozo",
	"zona_pruebas_muestra_calabozo": "calabozo",
	"zona_pruebas_muestra_castillo": "castillo", "zona_pruebas_muestra_castillo_salas": "castillo",
	"zona_pruebas_muestra_cementerio": "cementerio", "zona_pruebas_muestra_infierno": "infierno",
	"zona_pruebas_muestra_mazmorra_reina": "mazmorra", "zona_pruebas_muestra_minas": "minas",
	"zona_pruebas_muestra_profundidades": "profundidades", "zona_pruebas_muestra_ruina": "ruina",
}

const ENEMIGOS := {
	"alma_condenada": ["espiritu", 0.79], "anima": ["espiritu", 1.26], "aprendis": ["hueso", 1.36],
	"ave_nieves": ["ala", 1.34], "bestia_infernal": ["demonio", 0.75],
	"calavera_fuego": ["hueso", 1.56], "carcelero": ["armadura", 0.73], "cuervo": ["ala", 0.84],
	"demonslime": ["viscoso", 0.75], "diablillo": ["demonio", 1.28], "enemis": ["armadura", 1.38],
	"esqueleto": ["hueso", 1.01], "esqueleto_lanza": ["hueso", 1.18], "esqueleto_tumba": ["hueso", 0.84],
	"guardia": ["armadura", 0.99], "kolbo": ["bestia", 1.30], "kolbo2": ["bestia", 1.55],
	"kolbo3": ["bestia", 1.15], "lobo_escarcha": ["bestia", 0.87], "mimic": ["viscoso", 0.92],
	"mino": ["bestia", 0.57], "murcielago": ["ala", 1.62], "murcielago_grande": ["ala", 0.68],
	"ogro": ["bestia", 0.72], "ojo_volador": ["espiritu", 1.60], "pesadilla": ["espiritu", 0.64],
	"rata": ["bestia", 1.81], "reina": ["espiritu", 1.18], "sapo": ["viscoso", 1.25],
	"slime": ["viscoso", 1.57], "vanguardia": ["armadura", 0.84],
	"bestia_mayor": ["demonio", 0.60], "caballero_reina": ["armadura", 1.19],
	"capitan": ["armadura", 0.63], "crystal_mauler": ["hueso", 0.62],
	"cthulhu_jefe": ["demonio", 0.47], "demon_slime_jefe": ["viscoso", 0.54],
	"diablillo_mayor": ["demonio", 1.05], "guardian_hielo": ["hueso", 0.72],
	"pesadilla_ceniza": ["espiritu", 0.52], "reina_jefe": ["espiritu", 1.41],
	"rey_caido": ["armadura", 0.52], "boss": ["armadura", 0.58], "boss_mina": ["hueso", 0.65],
}

const VOCES := {
	"player": ["grave", 0.86], "narrator": ["grave", 0.71], "capitán": ["metalica", 0.92],
	"reina": ["clara", 0.95], "el barquero": ["aire", 0.72],
	"anciano": ["aire", 0.89], "preso": ["grave", 1.12], "rey": ["grave", 0.66],
	"alma del rey caído": ["aire", 0.61], "soldado": ["metalica", 1.11],
	"carta de la primera reina": ["clara", 0.81], "diario de la reina, i": ["clara", 0.92],
	"diario de la reina, ii": ["clara", 0.87], "diario de la reina, iii": ["clara", 0.82],
}

static func zone(path: String) -> String:
	var file := path.get_file().get_basename().trim_suffix("_combate")
	if file.begins_with("zona_pruebas") and not MAPAS.has(file):
		return "pruebas"
	return MAPAS.get(file, "")


static func enemy_profile(path: String) -> Array:
	return ENEMIGOS.get(path.get_file().get_basename(), ["bestia", 1.0])


static func voice_profile(speaker: String, name_text: String) -> Array:
	var identity := name_text.strip_edges().to_lower()
	if speaker == "player" or speaker == "narrator":
		return VOCES[speaker]
	for character: String in VOCES:
		if identity == character or identity.begins_with(character + " ("):
			return VOCES[character]
	var code: int = posmod((identity if not identity.is_empty() else speaker).hash(), 997)
	var timbres := ["grave", "clara", "metalica", "aire"]
	return [timbres[code % timbres.size()], 0.76 + float(code % 49) * 0.017]
