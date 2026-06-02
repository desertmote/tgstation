/datum/species/human/cerulean
	name = "\improper Cerulean"
	id = SPECIES_CERULEAN
	mutant_organs = list(/obj/item/organ/tail/fish/cerulean = /datum/sprite_accessory/tails/fish/oversized::name)
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
	inert_mutation = /datum/mutation/echolocation
	payday_modifier = 0.9
	family_heirlooms = list(
		/obj/item/ammo_casing/harpoon,
		/obj/item/toy/seashell,
	)
	/*	fun vars to check out:
	death_sound =
	grab_sound =
	*/

/datum/species/human/cerulean/get_physical_attributes()
	return "An unremarkable species."

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
	LAZYOR(features, /datum/preference/choiced/lungs_choice::savefile_key)
	LAZYOR(features, /datum/preference/color/fish_tail_color::savefile_key)
	return features

/datum/species/human/cerulean/randomize_features()
	var/list/features = ..()
	LAZYSET(features, FEATURE_TAIL_FISH_COLOR, pick(GLOB.carp_colors - COLOR_CARP_SILVER))
	return features

/datum/species/human/cerulean/on_species_gain(mob/living/carbon/human/cerulean, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if (isdummy(cerulean))
		cerulean.visual_only_organs = FALSE //sorry but we need them all for the organ set bonus
		return
	if (cerulean.has_gravity())
		cerulean.set_resting(TRUE, silent = TRUE, instant = TRUE)
	// apply a free wet stack to prevent the choking screen alert to appear for a second on mob creation
	cerulean.apply_status_effect(/datum/status_effect/fire_handler/wet_stacks, 1, FALSE)

/// good guy nanotrasen provides a wheelchair to their employees
/datum/species/human/cerulean/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/cerulean, visuals_only)
	if (visuals_only)
		return
	if (!istype(job))
		return
	cerulean.put_in_wheelchair()

/// gives a 'necessary for life' device to Ceruleans with gills
/datum/species/human/cerulean/post_equip_species_outfit(mob/living/carbon/human/cerulean, visuals_only)
	if (visuals_only)
		return
	var/obj/item/organ/lungs/lungs = cerulean.get_organ_slot(ORGAN_SLOT_LUNGS)
	if (!(/datum/gas/water_vapor in lungs?.breathe_always))
		return
	// try to attach to uniform
	var/obj/item/clothing/under/uniform = cerulean.w_uniform
	var/attached = uniform?.attach_accessory(SSwardrobe.provide_type(/obj/item/clothing/accessory/vaporizer/with_cell, cerulean))
	if (attached)
		return
	// try anything else
	cerulean.equip_in_one_of_slots(
		equipping = SSwardrobe.provide_type(/obj/item/clothing/accessory/vaporizer/with_cell, cerulean),
		slots = list(LOCATION_LPOCKET, LOCATION_RPOCKET, LOCATION_HANDS, LOCATION_BACKPACK),
		qdel_on_fail = FALSE,
		indirect_action = TRUE,
	)


// cerulean but with gills
/datum/species/human/cerulean/ancestral
	name = "\improper Ancestral Cerulean"
	id = SPECIES_CERULEAN_ANCESTRAL
	mutantlungs = /obj/item/organ/lungs/fish

// cerulean but with gills, an angler fish lantern and echolocation
/datum/species/human/cerulean/ancestral/abyssal
	name = "\improper Abyssal Cerulean"
	id = SPECIES_CERULEAN_ABYSSAL
	mutant_organs = list(
		/obj/item/organ/tail/fish/cerulean = /datum/sprite_accessory/tails/fish/oversized::name,
		/obj/item/organ/horns = /datum/sprite_accessory/horns/angler::name, // pretty funny lizards have this
	)

/datum/species/human/cerulean/ancestral/abyssal/on_species_gain(mob/living/carbon/human/cerulean, datum/species/old_species, pref_load, regenerate_icons)
	cerulean.dna.features[FEATURE_HORNS] = /datum/sprite_accessory/horns/angler::name
	cerulean.dna.update_uf_block(/datum/dna_block/feature/accessory/horn)
	. = ..()
	var/datum/mutation/echolocation/abyssal_sight = locate() in cerulean.dna.mutation_index
	cerulean.dna.activate_mutation(abyssal_sight)


/// the tail which makes the species, without this you're basically just a fishy, legless human.
/obj/item/organ/tail/fish/cerulean
	name = "oversized fish tail"
	desc = "A hugely sized and scaled fish tail, clearly severed from something much larger than a mere space carp."
	fillet_amount = 12
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/fish/cerulean
	external_bodyshapes = BODYSHAPE_CERULEAN
	w_class = WEIGHT_CLASS_BULKY
	organ_traits = list(
		TRAIT_FREE_FLOAT_MOVEMENT,
		TRAIT_FLOPPING,
		TRAIT_SWIMMER,
		TRAIT_BLOCK_ATTACHING_LEGS,
	)

/obj/item/organ/tail/fish/cerulean/on_mob_insert(mob/living/carbon/owner, special)
	. = ..()
	get_your_sealegs(owner, special)
	RegisterSignals(owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN), PROC_REF(update_species_fluff))

/obj/item/organ/tail/fish/cerulean/on_mob_remove(mob/living/carbon/owner, special)
	. = ..()
	UnregisterSignal(owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))
	if(special)
		return
	var/limb_name = "\improper [bodypart_owner.name]"
	var/tail_name = "\improper [name]"
	owner.apply_damage(rand(35, 45), def_zone = BODY_ZONE_CHEST, wound_bonus = CANT_WOUND)
	if(!HAS_TRAIT(owner, TRAIT_ANALGESIA))
		owner.emote("scream") //owowowowowow
		owner.set_jitter_if_lower(1 SECONDS)
		shake_camera(owner, 1 SECONDS, 2)
		to_chat(owner, span_userdanger("You wince and scream as your [tail_name] is grotesquely torn from your [limb_name]!"))
	if(!splatter_check(owner))
		// if you have no blood or are missing half of it, its a clean cut
		return
	owner.blood_volume -= (owner.blood_volume / 3)
	owner.add_splatter_floor(get_turf(src))
	owner.spray_blood(REVERSE_DIR(owner.dir), 2)
	owner.visible_message(span_danger("[src] detaches from [owner]'s [limb_name], spilling out liters of [LOWER_TEXT(owner.get_bloodtype()?.get_blood_name())]!"))
	REMOVE_TRAIT(src, TRAIT_NODROP, ORGAN_INSIDE_BODY_TRAIT) //do this early so we can fling it
	throw_at(get_edge_target_turf(owner, REVERSE_DIR(owner.dir))) //ok so it doesnt actually fling it it just spins but idk hwo to fling
	playsound(src, 'sound/effects/cartoon_sfx/cartoon_splat.ogg', rand(50, 75), TRUE)

/obj/item/organ/tail/fish/cerulean/on_surgical_removal(mob/living/user, obj/item/bodypart/limb, obj/item/tool)
	. = ..()
	if(!splatter_check(limb.owner))
		return
	shake_camera(user, 1 SECONDS, 2) //you shake too hehe
	user.set_jitter_if_lower(1 SECONDS)

/obj/item/organ/tail/fish/cerulean/get_valid_restyles()
	return bodypart_overlay.get_global_feature_list()

/// check if we have (enough) blood for an (un)clean cut
/obj/item/organ/tail/fish/cerulean/proc/splatter_check(mob/living/carbon/owner)
	if(isnull(owner))
		return FALSE
	return (owner.blood_volume && !HAS_TRAIT(owner, TRAIT_NOBLOOD) && owner.blood_volume >= (owner.default_blood_volume / 2))

/// do some fun fluff stuff when our organs or organ bonus situation changes
/obj/item/organ/tail/fish/cerulean/proc/update_species_fluff(mob/living/carbon/owner)
	//check for scales
	var/datum/status_effect/organ_set_bonus/fish/organ_bonus = owner?.has_status_effect(/datum/status_effect/organ_set_bonus/fish)
	owner.dna.species.skinned_type = organ_bonus?.color_active ? /obj/item/stack/sheet/animalhide/carp/fish : /datum/species/human::skinned_type
	owner.dna.species.meat = organ_bonus?.color_active ? /obj/item/food/fishmeat : /datum/species/human::meat
	//check for fishy tail
	var/obj/item/organ/tail/fish/cerulean/fish_tail = owner?.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	owner.dna.species.fire_overlay = fish_tail ? "monkey" : /datum/species/human::fire_overlay //monkey overlay is just legless - perfect for Ceruleans
	owner.dna.species.electrocution_overlay = fish_tail ? "electrocuted_base_cerulean" : /datum/species/human::electrocution_overlay //they call her one of the most dedicated fluff devs

/// Remove legs on insertion, if we had any
/obj/item/organ/tail/fish/cerulean/proc/get_your_sealegs(mob/living/carbon/owner, special)
	var/obj/item/bodypart/right_leg = owner.get_bodypart(BODY_ZONE_R_LEG)
	var/obj/item/bodypart/left_leg = owner.get_bodypart(BODY_ZONE_L_LEG)
	if(special)
		right_leg?.drop_limb(special, FALSE, FALSE)
		left_leg?.drop_limb(special, FALSE, FALSE)
		return
	right_leg?.dismember()
	left_leg?.dismember()

/// the tail has a fixed appearance for the modsuit overlays
/datum/bodypart_overlay/mutant/tail/fish/cerulean
	layers = EXTERNAL_BEHIND|EXTERNAL_ADJACENT

/datum/bodypart_overlay/mutant/tail/fish/cerulean/get_global_feature_list()
	var/static/list/glob_feature_list = list()
	if(!length(glob_feature_list))
		glob_feature_list = SSaccessories.feature_list[feature_key]
	var/list/feature_list = glob_feature_list.Copy()
	for(var/accessory in feature_list)
		var/datum/sprite_accessory/accessory_datum = feature_list[accessory]
		// removing the normal fishe tails from the pool
		if(!istype(accessory_datum, /datum/sprite_accessory/tails/fish/oversized))
			feature_list -= accessory
	return feature_list

/datum/bodypart_overlay/mutant/tail/fish/cerulean/get_random_appearance()
	return fetch_sprite_datum_from_name(pick(get_global_feature_list()))
