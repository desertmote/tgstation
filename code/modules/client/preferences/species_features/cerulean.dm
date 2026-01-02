GLOBAL_LIST_INIT(cerulean_lungs, list(
	"Oxygen" = /obj/item/organ/lungs, //i know fish also breathe oxygen
	"Water vapor" = /obj/item/organ/lungs/fish, //but this gets the idea across better
	))

/// wether or not a cerulean has air-breathing lungs, or water-breathing gills.
/datum/preference/choiced/lungs_choice
	savefile_key = "feature_cerulean_lungs"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_BODYPARTS
	randomize_by_default = FALSE

/datum/preference/choiced/lungs_choice/has_relevant_feature(datum/preferences/preferences)
	return current_species_has_savekey(preferences)

/datum/preference/choiced/lungs_choice/apply_to_human(mob/living/carbon/human/target, value)
	if(!iscerulean(target))
		return
	target.dna.species.mutantlungs = GLOB.cerulean_lungs[value]
	var/obj/item/organ/lungs/new_organ = SSwardrobe.provide_type(GLOB.cerulean_lungs[value])
	new_organ.Insert(target, TRUE, DELETE_IF_REPLACED)

/datum/preference/choiced/lungs_choice/init_possible_values()
	return GLOB.cerulean_lungs

/datum/preference/choiced/lungs_choice/create_default_value()
	return "Oxygen"

/datum/preference/choiced/lungs_choice/deserialize(value, datum/preferences/preferences)
	if(!current_species_has_savekey(preferences))
		return ..(create_default_value(), preferences)
	return ..(value, preferences)

/// the color given to people with a fish tail, not exclusive to ceruleans
/datum/preference/color/fish_tail_color
	savefile_key = "feature_fish_tail_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_organ = /obj/item/organ/tail/fish

/datum/preference/color/fish_tail_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_TAIL_FISH_COLOR] = value

/datum/preference/color/fish_tail_color/create_default_value()
	return pick(GLOB.carp_colors - COLOR_CARP_SILVER)
