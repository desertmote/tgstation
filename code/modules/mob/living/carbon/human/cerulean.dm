// File of procs for human_update_icons.dm specifically to render cerulean clothing appropriately. so it doesn't get any more lines than it already has...

/**
 *	Modifies the sprite of clothing to have no legs! For pants, which mermaids canonically can't wear.
 *	What we generate will be saved in a cache, how nice! Our keys look slightly different than the sister proc wear_digi_version(...)
 *	we also assign physique into the end of the key, and read this in handle_mermaid_modsuit(...)
 */
/proc/wear_mermaid_version(icon/base_icon, obj/item/item, key, greyscale_colors)
	ASSERT(istype(item), "wear_mermaid_version: no item passed")
	ASSERT(istext(key), "wear_mermaid_version: no key passed")
	if(isnull(greyscale_colors) || length(SSgreyscale.ParseColorString(greyscale_colors)) > 1)
		greyscale_colors = item.get_general_color(base_icon)

	var/mob/living/carbon/human/wearer = item.loc
	var/physique = wearer?.physique == FEMALE ? "f" : "m"

	///
	var/static/list/mermaid_clothing_icons = list()
	/// our way to find what we generate in the cache
	var/index = "[key]-[item.type]-[greyscale_colors]-[physique]"

	var/icon/mermaid_clothing_icon = mermaid_clothing_icons[index]
	if(mermaid_clothing_icon)
		return icon(mermaid_clothing_icon)

	if(istype(item, /obj/item/clothing/suit/mod))
		// if we are generating for modsuits, we need to run through a bespoke proc!
		mermaid_clothing_icon = handle_mermaid_modsuit(base_icon, item, "[key]-[physique]", greyscale_colors)

	else
		// uniforms, we are just cutting the pant
		if(item.slot_flags & ITEM_SLOT_ICLOTHING)
			mermaid_clothing_icon = mask_icon(base_icon, LEGS_MASK)
		// suit or neck items, we want to remove any pixels that typically appear between the legs
		else if((item.slot_flags & ITEM_SLOT_OCLOTHING) || (item.slot_flags & ITEM_SLOT_NECK))
			mermaid_clothing_icon = mask_icon(base_icon, BACK_COAT_MASK)

	if(!mermaid_clothing_icon)
		stack_trace("[item.type] was set to generate a mermaid tail clothing icon, but there was no result.")
		return base_icon

	mermaid_clothing_icons[index] = fcopy_rsc(mermaid_clothing_icon)
	return icon(mermaid_clothing_icon)

/// in reference to GLOB.mermaid_mod_theme and its entries. if (un)defined, the following proc generates accordingly
#define NO_THEME_ENTRY "undefined"
#define FEM_FLIPPER "f" //lady physique Ceruleans have extra fins, to keep her eggs close. we'll cover these up if the modsuit is sealed
#define SEALED "sealed"

/**
 *	This proc handles icon building for Ceruleans wearing modsuits.
 *	If a drawn sprite exists, we prioritize it. If it doesn't, we'll look for an entry in GLOB.mermaid_mod_theme
 *	If that doesn't, we'll generate a basic modsuit icon for the cerulean.
 */
/proc/handle_mermaid_modsuit(icon/base_icon, obj/item/clothing/chestpiece, key, greyscale_colors)
	/// the entry in GLOB.mermaid_mod_theme
	var/theme = NO_THEME_ENTRY
	/// whether the modsuit is sealed or open, we read this from our lovely key
	var/sealed = findtext(key, SEALED) ? TRUE : FALSE
	/// whether our wearer has boy or girl physique, read from the last symbol of our key
	var/physique = copytext_char(key, length(key))

	/// our full icon state string, lets find a pre-drawn modsuit!
	var/icon_state_string = "[physique == FEM_FLIPPER ? "[FEM_FLIPPER]-" : ""][chestpiece.icon_state]"
	if(icon_exists(MERMAID_MODSUIT_FILE, icon_state_string))
		// we have a pre-drawn modsuit, yay
		return icon(MERMAID_MODSUIT_FILE, icon_state_string)

	// lets cut away the legs first, we really don't need them
	mask_icon(base_icon, LEGS_MASK)
	// check a list of preset combinations for modsuit icon generation
	for(var/theme_entry in GLOB.mermaid_mod_theme)
		if(findtext(key, theme_entry))
			theme = theme_entry
			continue
	// lets run through generating according to what our variables are set to
	if(theme != NO_THEME_ENTRY)
		// add a colored icon for each modular part, according to the theme fetched from GLOB.mermaid_mod_theme
		var/list/modular_part_list = GLOB.mermaid_mod_theme[theme]
		for(var/index in 1 to length(modular_part_list))
			base_icon.Blend(
				icon(
					SSgreyscale.GetColoredIconByType(
						/datum/greyscale_config/modular_mod_parts_mermaid,
						modular_part_list[modular_part_list[index]],
					),
					"[modular_part_list[index]][sealed ? "-[SEALED]" : ""]",
				),
				ICON_OVERLAY,
			)
	else
		// we have no drawn sprite and no entry in the preset combinations alist. one little neglected modsuit :(
		// lets generate a barebones colored icon
		base_icon.Blend(
			icon(
				SSgreyscale.GetColoredIconByType(
					/datum/greyscale_config/modular_mod_parts_mermaid/basic,
					greyscale_colors,
				),
				"[NO_THEME_ENTRY][sealed ? "-[SEALED]" : ""]",
			),
			ICON_OVERLAY,
		)
	// apply a flipper icon if we are sealed and have a female physique.
	// ideally we color after the theme fetched from GLOB.mod_theme_to_flipper_color
	if(physique == FEM_FLIPPER && sealed && GLOB.mod_theme_to_flipper_color[theme] != NO_FLIPPERS)
		base_icon.Blend(
			icon(
				SSgreyscale.GetColoredIconByType(
					/datum/greyscale_config/modular_mod_parts_mermaid/basic,
					theme == NO_THEME_ENTRY ? greyscale_colors : GLOB.mod_theme_to_flipper_color[theme],
				),
				"[FLIPPERS]",
			),
			ICON_OVERLAY,
			)

	// 🪸🐟
	return base_icon

#undef NO_THEME_ENTRY
#undef FEM_FLIPPER
#undef SEALED
