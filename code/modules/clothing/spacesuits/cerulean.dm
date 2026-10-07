/obj/item/clothing/head/helmet/fishbowl
	name = "\improper fishbowl helm"
	desc = "A spheroidal helmet typically filled with water and worn around the head of (hopefully) someone with gills."
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	worn_icon = 'icons/mob/clothing/head/spacehelm.dmi'
	icon_state = "fishbowl"
	armor_type = /datum/armor/fishbowl
	interaction_flags_click = NEED_DEXTERITY
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | STACKABLE_HELMET_EXEMPT | HEADINTERNALS
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	flags_inv = NONE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	dog_fashion = null
	equip_sound = 'sound/items/handling/beaker_pickup.ogg'
	pickup_sound = 'sound/items/handling/beaker_place.ogg'
	drop_sound = 'sound/items/handling/beaker_place.ogg'
	sound_vary = TRUE
	worn_y_offset = 2
	custom_materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT*2)

/datum/armor/fishbowl
	bio = 100
	fire = 100

/obj/item/clothing/head/helmet/fishbowl/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wet_stacks_granting, CALLBACK(src, PROC_REF(use_reagent)), must_be_worn = TRUE)
	AddComponent(/datum/component/hat_stabilizer, loose_hat = FALSE, layer_beneath = TRUE, include_worn_y_offset = FALSE)

/obj/item/clothing/head/helmet/fishbowl/proc/use_reagent()
	return TRUE
