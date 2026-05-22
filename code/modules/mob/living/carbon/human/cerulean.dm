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

/// in reference to GLOB.mermaid_mod_theme and its entries. if (un)defined, the following proc generates accordingly
#define NO_THEME_ENTRY "undefined"
#define FEM_FLIPPER "f" //lady physique ceruleans have extra fins, to keep her eggs close. we'll cover these up if the modsuit is sealed

/**
 *	This proc handles icon building for ceruleans wearing modsuits.
 *	If a drawn sprite exists, we prioritize it. If it doesn't, we'll look for an entry in GLOB.mermaid_mod_theme
 *	If that doesn't, we'll generate a basic modsuit icon for the cerulean.
 */
/proc/handle_mermaid_modsuit(icon/base_icon, obj/item/clothing/chestpiece, key)
	var/icon/mermaid_modsuit = base_icon
	/// the entry in GLOB.mermaid_mod_theme
	var/theme = NO_THEME_ENTRY
	/// the color of the icon we're helping render. we fetch this on init because in most cases we mask away where it samples from
	var/general_color = chestpiece.get_general_color(base_icon)
	/// whether the modsuit is sealed or open, we read this from our lovely key
	var/sealed = findtext(key, "sealed") ? TRUE : FALSE
	/// whether our wearer has boy or girl physique, read from the last symbol of our key
	var/physique = copytext_char(key, length(key))

	/// our full icon state string, lets find a pre-drawn modsuit!
	var/icon_state_string = "[physique == FEM_FLIPPER ? "f-" : ""][chestpiece.icon_state]"
	if(icon_exists(MERMAID_MODSUIT_FILE, icon_state_string))
		// we have a pre-drawn modsuit, yay
		return icon(MERMAID_MODSUIT_FILE, icon_state_string)

	// lets cut away the legs first, we really don't need them
	replace_icon_legs(mermaid_modsuit, replace = FALSE)
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
			var/icon/generated_mermaid_part = icon(
				SSgreyscale.GetColoredIconByType(
					/datum/greyscale_config/modular_mod_parts_mermaid,
					modular_part_list[modular_part_list[index]],
					),
				"[modular_part_list[index]][sealed ? "-sealed" : ""]",
			)
			mermaid_modsuit.Blend(generated_mermaid_part, ICON_OVERLAY)
	else
		// we have no drawn sprite and no entry in the preset combinations alist. one little neglected modsuit :(
		// lets generate a barebones colored icon
		var/icon/generated_mermaid_part = icon(
			SSgreyscale.GetColoredIconByType(
				/datum/greyscale_config/modular_mod_parts_mermaid,
				general_color,
				),
			"[NO_THEME_ENTRY][sealed ? "-sealed" : ""]",
		)
		mermaid_modsuit.Blend(generated_mermaid_part, ICON_OVERLAY)
	// apply a flipper icon if we are sealed and have a female physique.
	// ideally we color after the theme fetched from GLOB.mod_theme_to_flipper_color
	if(physique == FEM_FLIPPER && sealed && GLOB.mod_theme_to_flipper_color[theme] != "no_flippers")
		var/icon/generated_mermaid_part = icon(
			SSgreyscale.GetColoredIconByType(
				/datum/greyscale_config/modular_mod_parts_mermaid,
				theme == NO_THEME_ENTRY ? general_color : GLOB.mod_theme_to_flipper_color[theme],
				),
			"flippers",
		)
		mermaid_modsuit.Blend(generated_mermaid_part, ICON_OVERLAY)

	// 🪸🐟
	return mermaid_modsuit

#undef NO_THEME_ENTRY
#undef FEM_FLIPPER
