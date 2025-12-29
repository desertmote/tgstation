#define MIN_WET_STACKS 1
#define MAX_WET_STACKS 4

/obj/item/clothing/accessory/vaporizer
	name = "hydro-vaporizer"
	desc = ""
	icon_state = "vaporizer"
	base_icon_state = "vaporizer"
	///
	var/obj/item/stock_parts/power_store/cell/cell
	///
	var/datum/progressbar/charge_bar
	///
	var/datum/component/wet_stacks_granter/wet_stacks_component

/obj/item/clothing/accessory/vaporizer/Initialize(mapload)
	. = ..()
	cell = new(src)
	wet_stacks_component = AddComponent(/datum/component/wet_stacks_granter)

/obj/item/clothing/accessory/vaporizer/Destroy()
	. = ..()
	QDEL_NULL(wet_stacks_component)

/obj/item/clothing/accessory/vaporizer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Dial down"
	context[SCREENTIP_CONTEXT_ALT_RMB] = "Dial up"

/obj/item/clothing/accessory/vaporizer/examine(mob/user)
	. = ..()
	. += "It has a dial. Alt + Left-click / Right-click to turn down or up."
	. += "Its dial is currently set to [wet_stacks_component?.stacks_to_add]."

/obj/item/clothing/accessory/vaporizer/equipped(mob/user, slot, initial)
	. = ..()
	if(!cell || charge_bar)
		return
	if(istype(loc, /obj/item/clothing))
		charge_bar = new(user, cell.maxcharge, loc, cell.charge)
		charge_bar.offset_y = -4
	else
		charge_bar = new(user, cell.maxcharge, src, cell.charge)

/obj/item/clothing/accessory/vaporizer/dropped(mob/user, silent)
	. = ..()
	if(!charge_bar)
		return
	QDEL_NULL(charge_bar)

/obj/item/clothing/accessory/vaporizer/can_use(mob/user)
	if(!wet_stacks_component)
		return FALSE
	if(!user.can_perform_action(src))
		return FALSE
	return ..()

/obj/item/clothing/accessory/vaporizer/click_alt(mob/user)
	. = ..()
	if(!can_use(user))
		return CLICK_ACTION_BLOCKING
	if(wet_stacks_component.stacks_to_add <= MIN_WET_STACKS)
		return CLICK_ACTION_BLOCKING
	wet_stacks_component.stacks_to_add--
	balloon_alert(user, "dialed down")
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/accessory/vaporizer/click_alt_secondary(mob/user)
	. = ..()
	if(!can_use(user))
		return CLICK_ACTION_BLOCKING
	if(wet_stacks_component.stacks_to_add >= MAX_WET_STACKS)
		return CLICK_ACTION_BLOCKING
	wet_stacks_component.stacks_to_add++
	balloon_alert(user, "dialed up")
	return CLICK_ACTION_SUCCESS

/mob/living/carbon/human/emp_act(severity)
	. = ..()
	var/obj/item/clothing/under/worn_uniform = w_uniform
	var/obj/item/clothing/accessory/vaporizer/vaporizer = locate() in worn_uniform?.attached_accessories
	vaporizer?.on_emp()

/obj/item/clothing/accessory/vaporizer/emp_act(severity)
	. = ..()
	var/turf/open/tile = get_turf(src)
	var/list/nearby_mobs = oviewers(4, get_turf(src))
	for(var/mob/living/victim as anything in nearby_mobs)
		victim.set_jitter_if_lower(15 SECONDS)
		victim.set_eye_blur_if_lower(5 SECONDS)
	if (tile)
		tile.atmos_spawn_air("[GAS_WATER_VAPOR]=50;[TURF_TEMPERATURE(1000)]")
		new /obj/effect/decal/cleanable/plastic(tile)
	balloon_alert_to_viewers("overloaded!")
	to_chat(src, span_warning("[src] overloads, exploding in a cloud of hot steam!"))
	playsound(src, 'sound/effects/spray.ogg', 80)
	qdel(src)

/obj/item/clothing/accessory/vaporizer/proc/on_emp()
	var/obj/item/clothing/under/attached_to = loc
	detach(attached_to) // safely remove the status effect
	emp_act()

#undef MIN_WET_STACKS
#undef MAX_WET_STACKS
