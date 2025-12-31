/obj/item/clothing/accessory/vaporizer
	name = "hydro-vaporizer"
	desc = ""
	icon_state = "vaporizer"
	base_icon_state = "vaporizer"
	pickup_sound = SFX_GENERIC_DEVICE_PICKUP
	drop_sound = SFX_GENERIC_DEVICE_DROP
	/// visual which shows how much charge is left in the cell
	var/datum/progressbar/charge_bar
	/// the cell which will be used to power the item
	var/obj/item/stock_parts/power_store/cell/cell
	/// how much will be drawn from the cell every time it applies wet stacks
	var/power_cost = 45 JOULES

/obj/item/clothing/accessory/vaporizer/Initialize(mapload)
	. = ..()
	cell = new(src)
	AddComponent(/datum/component/wet_stacks_clothing, CALLBACK(src, PROC_REF(use_cell)), must_be_worn = FALSE)

/obj/item/clothing/accessory/vaporizer/Destroy()
	. = ..()
	qdel(GetComponent(/datum/component/wet_stacks_clothing))

/obj/item/clothing/accessory/vaporizer/equipped(mob/living/user, slot)
	. = ..()
	create_charge_bar(user)

/obj/item/clothing/accessory/vaporizer/dropped(mob/living/user)
	. = ..()
	destroy_charge_bar()

/// create a visual for how much power is left in the cell of the item
/obj/item/clothing/accessory/vaporizer/proc/create_charge_bar(mob/living/user)
	if(!cell || charge_bar)
		return
	if(istype(loc, /obj/item/clothing))
		charge_bar = new(user, cell.maxcharge, loc, cell.charge)
		charge_bar.offset_y = -4 //why does this do nothing
	else
		charge_bar = new(user, cell.maxcharge, src, cell.charge)

/obj/item/clothing/accessory/vaporizer/proc/destroy_charge_bar()
	if(!charge_bar)
		return
	QDEL_NULL(charge_bar)

// remove the cell with a screwdriver
/obj/item/clothing/accessory/vaporizer/screwdriver_act(mob/living/user, obj/item/tool)
	if(!cell)
		return FALSE
	tool.play_tool_sound(src)
	destroy_charge_bar()
	balloon_alert(user, "removed [cell]")
	cell.forceMove(get_turf(src))
	cell = null
	return TRUE

// proc to feed the machine a new cell
/obj/item/clothing/accessory/vaporizer/item_interaction(mob/living/user, obj/item/stock_parts/power_store/cell/new_cell, list/modifiers)
	if(!istype(new_cell))
		return NONE
	if(!isnull(cell))
		balloon_alert(user, "slot occupied!")
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(new_cell, src))
		return NONE
	cell = new_cell
	balloon_alert(user, "installed [new_cell]")
	create_charge_bar(user)
	return ITEM_INTERACT_SUCCESS

/// proc we forward to the callback the wet stack component uses every time it ticks
/obj/item/clothing/accessory/vaporizer/proc/use_cell()
	if(!cell || !cell.use(power_cost, TRUE))
		return FALSE
	charge_bar?.update(cell.charge())
	return TRUE

/// overload and spew hot steam on EMP
/obj/item/clothing/accessory/vaporizer/emp_act(severity)
	. = ..()
	var/turf/tile = get_turf(src)
	var/list/nearby_mobs = oviewers(4, get_turf(src))
	for(var/mob/living/victim as anything in nearby_mobs)
		victim.set_jitter_if_lower(rand(5 SECONDS, 15 SECONDS))
		victim.set_eye_blur_if_lower(rand(3 SECONDS, 7 SECONDS))
	if(!isclosedturf(tile))
		tile.atmos_spawn_air("[GAS_WATER_VAPOR]=[rand(50, 65)];[TURF_TEMPERATURE(1000)]")
		new /obj/effect/decal/cleanable/plastic(tile)
	balloon_alert_to_viewers("overloaded!")
	to_chat(src, span_warning("[src] overloads, exploding in a cloud of hot steam!"))
	playsound(src, 'sound/effects/spray.ogg', rand(50, 80), TRUE)
	qdel(src)
