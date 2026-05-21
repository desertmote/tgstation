/// Global list of all /datum/mod_theme
GLOBAL_LIST_INIT(mod_themes, setup_mod_themes())
/// Global list of all ids associated to a /datum/mod_link instance
GLOBAL_LIST_EMPTY(mod_link_ids)

/**
 *	A global double associated list with entries named after modsuit themes.
 *	When an entry exists here, and there isn't a drawn modsuit sprite to use,
 *	handle_mermaid_modsuit(...) will generate a modsuit sprite with the supplied parts.
 *	Check MERMAID_MODSUIT_GEN_FILE for existing parts to pick from.
 *	Sprites at the top of the list load first.
 */
GLOBAL_LIST_INIT(mermaid_modsuit_themes, list(
	"advanced" = list(
		"shape_1" = "#FFFFFF",
	),
))

/**
 *	Like above but slightly less alisty. The color given are just for the flippers
 *	ceruleans with a female physique have, and when the modsuit is sealed.
 */
GLOBAL_LIST_INIT(mermaid_modsuit_themes_flippers, list(
	"advanced" = "#FFFFFF",
))
