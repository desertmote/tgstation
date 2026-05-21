// File of procs for human_update_icons.dm specifically to render cerulean clothing appropriately. so it doesn't get any more lines than it already has...

/**
 *	Modifies the sprite of clothing to have no legs! For pants, which mermaids canonically can't wear.
 *	What we generate will be saved in a cache, how nice! Our keys look slightly different than the sister proc wear_digi_version(...)
 *	we also assign physique into the end of the key, and read this in handle_mermaid_modsuit(...)
 */
/proc/wear_mermaid_version(icon/base_icon, obj/item/item, key, greyscale_colors)
	var/index = "[key]-[item.type]-[greyscale_colors]"
	var/static/list/mermaid_clothing_icons = list()
	var/icon/mermaid_clothing_icon = mermaid_clothing_icons[index]
	if(!mermaid_clothing_icon)
		if(item.slot_flags & ITEM_SLOT_ICLOTHING)
			mermaid_clothing_icon = replace_icon_legs(base_icon, replace = FALSE)
		else if((item.slot_flags & ITEM_SLOT_OCLOTHING) || (item.slot_flags & ITEM_SLOT_NECK))
			if(istype(item, /obj/item/clothing/suit/mod))
				mermaid_clothing_icon = handle_mermaid_modsuit(base_icon, item, key)
			else
				mermaid_clothing_icon = cut_coat(base_icon)
		if(!mermaid_clothing_icon)
			return base_icon
		mermaid_clothing_icons[index] = fcopy_rsc(mermaid_clothing_icon)

	return icon(mermaid_clothing_icon)

/// Removes pixels that often appear between the legs on suits or cloaks, for ceruleans who have it layer above their tail
/proc/cut_coat(icon/base_icon)
	var/static/icon/coat_mask
	if(!coat_mask)
		coat_mask = icon('icons/mob/clothing/under/masking_helpers.dmi', "coat_mask")

	base_icon.Blend(coat_mask, ICON_SUBTRACT)
	return base_icon

/// in reference to GLOB.mermaid_modsuit_themes and its entries. if (un)defined, the following proc generates accordingly
#define NO_THEME_ENTRY "undefined"
#define FEM_FLIPPER "f" //lady physique ceruleans have extra fins, to keep her eggs close. we'll cover these up if the modsuit is sealed

/**
 *	This proc handles icon building for ceruleans wearing modsuits.
 *	If a drawn sprite exists, we prioritize it. If it doesn't, we'll look for an entry in GLOB.mermaid_modsuit_themes
 *	If that doesn't, we'll generate a basic modsuit icon for the cerulean.
 */
/proc/handle_mermaid_modsuit(icon/base_icon, obj/item/clothing/chestpiece, key)
	var/icon/mermaid_modsuit = base_icon
	/// the entry in GLOB.mermaid_modsuit_themes
	var/theme = NO_THEME_ENTRY
	// check a list of preset combinations for modsuit icon generation
	for(var/theme_entry in GLOB.mermaid_modsuit_themes)
		if(findtext(key, theme_entry))
			theme = theme_entry
			continue

	var/sealed = findtext(key, "sealed") ? TRUE : FALSE
	var/physique = copytext_char(key, length(key))

	if(theme == NO_THEME_ENTRY)
		var/icon_state_string = "[physique == FEM_FLIPPER ? "f-" : ""][chestpiece.icon_state]"
		if(icon_exists(MERMAID_MODSUIT_FILE, icon_state_string))
			var/icon/drawn_mermaid_part = icon(MERMAID_MODSUIT_FILE, icon_state_string)
			mermaid_modsuit.Blend(drawn_mermaid_part, ICON_OVERLAY)
			// we have a pre-drawn modsuit, yay
			return mermaid_modsuit
		else
			// we have no drawn sprite and no entry in the preset combinations alist. one little neglected modsuit :(
			// lets generate a barebones colored icon
			var/icon/generated_mermaid_part = icon(MERMAID_MODSUIT_GEN_FILE, "[NO_THEME_ENTRY][sealed ? "-sealed" : ""]")
			generated_mermaid_part.Blend(chestpiece.get_general_color(base_icon), ICON_MULTIPLY)
			mermaid_modsuit.Blend(generated_mermaid_part, ICON_OVERLAY)
	else
		// add a colored icon for each modular part, according to the theme fetched from GLOB.mermaid_modsuit_themes
		var/list/modular_part_list = GLOB.mermaid_modsuit_themes[theme]
		for(var/index in 1 to length(modular_part_list))
			var/icon/generated_mermaid_part = icon(MERMAID_MODSUIT_GEN_FILE, "[GLOB.mermaid_modsuit_themes[theme][index]][sealed ? "-sealed" : ""]")
			generated_mermaid_part.Blend(GLOB.mermaid_modsuit_themes[theme][GLOB.mermaid_modsuit_themes[theme][index]], ICON_MULTIPLY)
			mermaid_modsuit.Blend(generated_mermaid_part, ICON_OVERLAY)
	// apply a flipper icon if we are sealed and have a female physique. ideally we color after the theme fetched from GLOB.mermaid_modsuit_themes_flippers
	if(physique == FEM_FLIPPER && sealed)
		var/icon/generated_mermaid_part = icon(MERMAID_MODSUIT_GEN_FILE, "flippers")
		generated_mermaid_part.Blend(theme == NO_THEME_ENTRY ? chestpiece.get_general_color(base_icon) : GLOB.mermaid_modsuit_themes_flippers[theme] , ICON_MULTIPLY)
		mermaid_modsuit.Blend(generated_mermaid_part, ICON_OVERLAY)

	return mermaid_modsuit

#undef NO_THEME_ENTRY
#undef FEM_FLIPPER
