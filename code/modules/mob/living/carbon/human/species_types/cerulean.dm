/datum/species/human/cerulean
	name = "\improper Cerulean"
	id = SPECIES_CERULEAN
	mutant_organs = list(/obj/item/organ/tail/fish/mermaid)
	mutanttongue = /obj/item/organ/tongue/fish
	mutantstomach = /obj/item/organ/stomach/fish
	mutantliver = /obj/item/organ/liver/fish
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right,
		BODY_ZONE_HEAD = /obj/item/bodypart/head,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_AQUATIC

	species_cookie = /obj/item/food/chips/shrimp
//	inert_mutation =
	payday_modifier = 0.9
//	family_heirlooms = list(
//		,
//	)

/datum/species/human/cerulean/get_species_description()
	return "Nothing yet."

/datum/species/human/cerulean/get_species_lore()
	return list(
		"Nothing yet.",
	)

/datum/species/human/cerulean/prepare_human_for_preview(mob/living/carbon/human/preview_human)
	preview_human.set_haircolor("#a54ea1", update = FALSE)
	preview_human.set_hairstyle("Ponytail (Country)", update = TRUE)
	preview_human.dna.features[TRAIT_USES_SKINTONES] = "asian1"
	preview_human.dna.features[FEATURE_TAIL_FISH_COLOR] = COLOR_CARP_TEAL
	regenerate_organs(preview_human)
	preview_human.update_body(is_creating = TRUE)

/datum/species/human/cerulean/get_features()
	var/list/features = ..()
	LAZYOR(features, "feature_cerulean_respiration")
	return features

/datum/species/human/cerulean/randomize_features()
	var/list/features = ..()
	LAZYSET(features, FEATURE_TAIL_FISH_COLOR, pick(GLOB.carp_colors - COLOR_CARP_SILVER))
	return features

/datum/species/human/cerulean/on_species_gain(mob/living/carbon/human/human_being, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if (isdummy(human_being))
		return
	if (human_being.has_gravity())
		human_being.set_resting(TRUE, silent = TRUE, instant = TRUE)
	// apply a free wet stack to prevent the choking screen alert to appear for a second on mob creation
	human_being.apply_status_effect(/datum/status_effect/fire_handler/wet_stacks, 1, FALSE)

/// good guy nanotrasen provides a wheelchair to their employees
/datum/species/human/cerulean/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only)
	if (visuals_only)
		return
	if (!istype(job))
		return
	equipping.put_in_wheelchair()

/// gives a 'necessary for life' device to mermaids with gills
/datum/species/human/cerulean/post_equip_species_outfit(mob/living/carbon/human/equipping, visuals_only)
	if (visuals_only)
		return
	// have gill?
	var/obj/item/organ/lungs/lungs = equipping.get_organ_slot(ORGAN_SLOT_LUNGS)
	if (!(/datum/gas/water_vapor in lungs?.breathe_always))
		return
	// try to attach to uniform
	var/obj/item/clothing/under/uniform = equipping.w_uniform
	var/attached = uniform?.attach_accessory(SSwardrobe.provide_type(/obj/item/clothing/accessory/vaporizer, equipping))
	if (attached)
		return
	// try anything else
	equipping.equip_in_one_of_slots(
		equipping = SSwardrobe.provide_type(/obj/item/clothing/accessory/vaporizer, equipping),
		slots = list(LOCATION_LPOCKET, LOCATION_RPOCKET, LOCATION_HANDS, LOCATION_BACKPACK),
		qdel_on_fail = FALSE,
		indirect_action = TRUE,
	)

/// the tail which makes the species, without this you're basically just a fishy human. without legs.
/obj/item/organ/tail/fish/mermaid
	name = "huge fish tail"
//	desc = ""
	fillet_amount = 12
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/fish/mermaid
	external_bodyshapes = BODYSHAPE_MERMAID
	restyle_flags = NONE
	w_class = WEIGHT_CLASS_BULKY
	organ_traits = list(
		TRAIT_FREE_FLOAT_MOVEMENT,
		TRAIT_FLOPPING,
		TRAIT_SWIMMER,
		TRAIT_BLOCK_LEGS,
	)

/obj/item/organ/tail/fish/mermaid/Initialize(mapload)
	. = ..()
	set_greyscale(pick(GLOB.carp_colors - COLOR_CARP_SILVER))

/obj/item/organ/tail/fish/mermaid/on_mob_insert(mob/living/carbon/owner, special, movement_flags)
	. = ..()
	get_your_sealegs(owner)

/obj/item/organ/tail/fish/mermaid/on_mob_remove(mob/living/carbon/owner)
	. = ..()
	if (QDELING(owner) || QDELING(src))
		return
	// losing half your bodymass is going to be bad
	owner.apply_damage(rand(35, 45), def_zone = BODY_ZONE_CHEST, wound_bonus = CANT_WOUND)
	if (owner.blood_volume)
		owner.blood_volume -= (BLOOD_VOLUME_NORMAL / 3)
		owner.add_splatter_floor(get_turf(src))
		owner.spray_blood(REVERSE_DIR(owner.dir))
		owner.visible_message(span_warning("[src] detaches from [owner], spilling out liters of [LOWER_TEXT(owner.get_bloodtype()?.get_blood_name())]!"))
		playsound(src, 'sound/effects/cartoon_sfx/cartoon_splat.ogg', rand(50, 75), TRUE)

/obj/item/organ/tail/fish/mermaid/mutate_feature(features, mob/living/carbon/human/owner)
	return //no mutation

/// Remove legs on insertion, if we had any
/obj/item/organ/tail/fish/mermaid/proc/get_your_sealegs(mob/living/carbon/owner)
	var/obj/item/bodypart/right_leg = owner.get_bodypart(BODY_ZONE_R_LEG)
	var/obj/item/bodypart/left_leg = owner.get_bodypart(BODY_ZONE_L_LEG)
	right_leg?.dismember()
	left_leg?.dismember()

/// The bodypart overlay
/datum/bodypart_overlay/mutant/tail/fish/mermaid
	layers = EXTERNAL_BEHIND|EXTERNAL_ADJACENT

/datum/bodypart_overlay/mutant/tail/fish/mermaid/randomize_appearance()
	set_appearance(/datum/sprite_accessory/tails/fish/mermaid)

/datum/bodypart_overlay/mutant/tail/fish/mermaid/override_color(obj/item/bodypart/limb)
	return limb.owner.dna.features[FEATURE_TAIL_FISH_COLOR]

/datum/bodypart_overlay/mutant/tail/fish/mermaid/can_draw_on_bodypart(obj/item/bodypart/limb)
	return TRUE //always draw
