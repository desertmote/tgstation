// Deafness makes you deaf.
/datum/mutation/deaf
	name = "Deafness"
	desc = "The holder of this genome is completely deaf."
	instability = NEGATIVE_STABILITY_MAJOR
	quality = NEGATIVE
	text_gain_indication = span_danger("You can't seem to hear anything.")
	mutation_traits = list(TRAIT_DEAF)

//
/datum/mutation/echolocation
	name = "Echolocation"
	desc = "N/A."
	instability = NEGATIVE_STABILITY_MODERATE
	quality = NEGATIVE
	text_gain_indication = span_danger("N/A.")
	///
	var/datum/weakref/echolocation_component

/datum/mutation/echolocation/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	echolocation_component = WEAKREF(acquirer.AddComponent(/datum/component/echolocation))

/datum/mutation/echolocation/on_losing(mob/living/carbon/human/owner)
	. = ..()
	qdel(echolocation_component)
