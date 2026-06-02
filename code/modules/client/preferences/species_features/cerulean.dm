GLOBAL_LIST_INIT(cerulean_respiration_variation, list(
	"Oxygen" = /datum/species/human/cerulean, // i know fish also breathe oxygen
	"Water vapor" = /datum/species/human/cerulean/ancestral, // but this gets the idea across better
	))

/// Whether or not a Cerulean has air-breathing lungs or water-breathing gills
/datum/preference/choiced/lungs_choice
	savefile_key = "feature_cerulean_respiration"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_SPECIES
	randomize_by_default = FALSE

/datum/preference/choiced/lungs_choice/has_relevant_feature(datum/preferences/preferences)
	return current_species_has_savekey(preferences)

/datum/preference/choiced/lungs_choice/apply_to_human(mob/living/carbon/human/target, value)
	if(savefile_key in target.dna?.species?.get_features())
		target.set_species(GLOB.cerulean_respiration_variation[value], icon_update = TRUE, pref_load = FALSE)

/datum/preference/choiced/lungs_choice/init_possible_values()
	return GLOB.cerulean_respiration_variation

/datum/preference/choiced/lungs_choice/create_default_value()
	return "Oxygen"

/datum/preference/choiced/lungs_choice/deserialize(value, datum/preferences/preferences)
	if(!current_species_has_savekey(preferences))
		return ..(create_default_value(), preferences)
	return ..(value, preferences)

/// The color given to people with a fish tail, the selection is exclusive to Ceruleans
/datum/preference/color/fish_tail_color
	savefile_key = "feature_fish_tail_color"
	relevant_organ = /obj/item/organ/tail/fish
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/color/fish_tail_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_TAIL_FISH_COLOR] = value

/datum/preference/color/fish_tail_color/create_default_value()
	return pick(GLOB.carp_colors - COLOR_CARP_SILVER)
