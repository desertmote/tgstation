/obj/item/clothing/mask/surgical
	name = "sterile mask"
	desc = "A sterile mask designed to help prevent the spread of diseases."
	icon_state = "sterile"
	inhand_icon_state = "s_mask"
	bodyshape_flags = list(BODYSHAPE_SNOUTED)
	w_class = WEIGHT_CLASS_TINY
	flags_inv = HIDEFACE|HIDESNOUT
	flags_cover = MASKCOVERSMOUTH
	visor_flags_inv = HIDEFACE
	visor_flags_cover = MASKCOVERSMOUTH
	armor_type = /datum/armor/mask_surgical
	actions_types = list(/datum/action/item_action/adjust)

/obj/item/clothing/mask/surgical/Initialize(mapload)
	. = ..()
	LAZYADDASSOC(bodyshape_icons, "[BODYSHAPE_SNOUTED]", SNOUTED_MASKS_FILE)

/datum/armor/mask_surgical
	bio = 100

/obj/item/clothing/mask/surgical/attack_self(mob/user)
	adjust_visor(user)
