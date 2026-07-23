/datum/antagonist/sapper
	name = "\improper Space Sapper"
	antagpanel_category = ANTAG_GROUP_PIRATES
	pref_flag = ROLE_SPACE_SAPPER
	antag_hud_name = "traitor"
	roundend_category = "space sappers"
	show_to_ghosts = TRUE
	var/datum/team/sapper_gang/gang

/datum/antagonist/sapper/get_preview_icon()
	var/datum/universal_icon/sapper_one_icon = render_preview_outfit(/datum/outfit/sapper_preview)
	sapper_one_icon.shift(WEST, 5)
	var/datum/universal_icon/sapper_two_icon = render_preview_outfit(/datum/outfit/sapper_preview/partner)
	sapper_two_icon.shift(EAST, 5)
	var/datum/universal_icon/final_icon = sapper_one_icon
	final_icon.blend_icon(sapper_two_icon, ICON_OVERLAY)
	final_icon.shift(NORTH, 1)
	return finish_preview_icon(final_icon)

/datum/antagonist/sapper/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/owner_mob = mob_override || owner.current
	var/datum/language_holder/holder = owner_mob.get_language_holder()
	holder.grant_language(/datum/language/uncommon, source = LANGUAGE_PIRATE)
	holder.selected_language = /datum/language/uncommon

/datum/antagonist/sapper/remove_innate_effects(mob/living/mob_override)
	var/mob/living/owner_mob = mob_override || owner.current
	owner_mob.remove_language(/datum/language/uncommon, source = LANGUAGE_PIRATE)
	return ..()

/datum/antagonist/sapper/greet()
	. = ..()
	to_chat(owner, span_notice("<B>You're an illegal credits miner, build your defenses to protect your credit-miner and your ship, and harvest as many credits as you can!</B>"))

/datum/antagonist/sapper/on_gain()
	forge_objectives()
	. = ..()
	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_SAPPER_HIDEOUT)
	owner.current.forceMove(pick(GLOB.sapper_start))

/datum/antagonist/sapper/one/on_gain()
	. = ..()
	var/mob/living/carbon/human/sapper = owner.current
	sapper.equip_species_outfit(/datum/outfit/sapper)

/datum/antagonist/sapper/two/on_gain()
	. = ..()
	var/mob/living/carbon/human/sapper = owner.current
	sapper.equip_species_outfit(/datum/outfit/sapper/partner)

/datum/antagonist/sapper/forge_objectives()
	if(isnull(gang))
		for(var/datum/team/sapper_gang/sapper_gang in GLOB.antagonist_teams)
			gang = sapper_gang
			break
	objectives |= gang.objectives

/datum/antagonist/sapper/get_team()
	return gang


/datum/team/sapper_gang
	name = "\improper Sapper gang"

/datum/team/sapper_gang/New()
	. = ..()
	var/datum/objective/creditmining/maingoal = new
	maingoal.cargo_hold = locate_cargohold()
	maingoal.team = src
	objectives += maingoal

/datum/team/sapper_gang/roundend_report()
	var/list/parts = list()
	parts += printplayerlist(members)
	var/datum/objective/creditmining/objective = locate() in objectives
	parts += "Total cash-out : [objective.get_loot_value()] credits"
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/sapper_gang/proc/locate_cargohold()
	for(var/obj/machinery/computer/piratepad_control/sapper/piratepad as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/piratepad_control/sapper))
		return piratepad

/datum/objective/creditmining
	var/obj/machinery/computer/piratepad_control/sapper/cargo_hold
	name = "Credit Mining"
	explanation_text = "Acquire as many credits as you can from the station's powernet and cash it out into the shuttle's cargo hold."

/datum/objective/creditmining/Destroy()
	if(!isnull(cargo_hold))
		QDEL_NULL(cargo_hold)
	return ..()

/datum/objective/creditmining/proc/get_loot_value()
	return cargo_hold ? cargo_hold.points : 0
