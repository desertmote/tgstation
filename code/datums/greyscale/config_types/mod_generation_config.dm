/*
 * The greyscale config which contains all the modsuit parts we can choose to use to render.
 * this config expects 3 color sources
 */
/datum/greyscale_config/modular_mod_parts_mermaid
	name = "Mermaid Tail Modsuit Parts"
	icon_file = MERMAID_MODSUIT_GEN_FILE
	json_config = 'code/datums/greyscale/json_configs/mermaid_mod.json'

/*
 *	The greyscale config which contains only the fem flipper modsuit parts, and a pre-made design for
 *	modsuits which were not given an entry in GLOB.mermaid_mod_theme.
 *	this config expects 1 color source
 */
/datum/greyscale_config/modular_mod_parts_mermaid/basic
	name = "Mermaid Tail Modsuit Parts (Basic)"
	json_config = 'code/datums/greyscale/json_configs/mermaid_mod_basic.json'
