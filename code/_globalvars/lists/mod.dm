/// Global list of all /datum/mod_theme
GLOBAL_LIST_INIT(mod_themes, setup_mod_themes())
/// Global list of all ids associated to a /datum/mod_link instance
GLOBAL_LIST_EMPTY(mod_link_ids)

/**
 *	A global double associated list with entries named after modsuit themes.
 *	When an entry exists here, and there isn't a drawn modsuit sprite to use,
 *	handle_mermaid_modsuit(...) will generate a modsuit sprite with the supplied parts.
 *	Check MERMAID_MODSUIT_GEN_FILE for existing parts to pick from.
 *	Sprites at the top of the list load first
 */
GLOBAL_ALIST_INIT(mermaid_mod_theme, list(
	/datum/mod_theme/debug::default_skin = list(
		"rubber" = "#343442",
//		"metal" = "#00289f",
	),
	/datum/mod_theme/loader::default_skin = list(),
))

/**
 *	Like above but slightly less alisty. The color given are just for the flippers
 *	Ceruleans with a female physique have, when the modsuit is sealed.
 *	If you use this, make sure there is also an entry in the above alist
 */
GLOBAL_ALIST_INIT(mod_theme_to_flipper_color, list(
	/datum/mod_theme/debug::default_skin = "#2faff5",
	/datum/mod_theme/loader::default_skin = NO_FLIPPERS,
))
