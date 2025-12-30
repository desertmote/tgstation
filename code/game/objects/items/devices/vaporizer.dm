/obj/item/clothing/accessory/vaporizer
	name = "hydro-vaporizer"
	desc = ""
	icon_state = "vaporizer"
	base_icon_state = "vaporizer"
	///
	var/datum/progressbar/charge_bar
	///
	var/obj/item/stock_parts/power_store/cell/cell
	///
	var/power_cost = 25 JOULES

/obj/item/clothing/accessory/vaporizer/Initialize(mapload)
	. = ..()
	cell = new(src)
	AddComponent(/datum/component/wet_stacks_clothing, power_cost, CALLBACK(src, PROC_REF(use_cell)))

/obj/item/clothing/accessory/vaporizer/Destroy()
	. = ..()
	qdel(GetComponent(/datum/component/wet_stacks_clothing))

///
/obj/item/clothing/accessory/vaporizer/equipped(mob/user, slot, initial)
	. = ..()
	if(!cell || charge_bar)
		return
	if(istype(loc, /obj/item/clothing))
		charge_bar = new(user, cell.maxcharge, loc, cell.charge)
		charge_bar.offset_y = -4
	else
		charge_bar = new(user, cell.maxcharge, src, cell.charge)

///
/obj/item/clothing/accessory/vaporizer/dropped(mob/user, silent)
	. = ..()
	if(!charge_bar)
		return
	QDEL_NULL(charge_bar)

///
/obj/item/clothing/accessory/vaporizer/proc/use_cell()
	if(!cell || !cell.use(power_cost, TRUE))
		return FALSE
	charge_bar?.update(cell.charge())
	return TRUE

///
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
