///
/datum/component/wet_stacks_granter
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///
	var/power_cost = 15 JOULES
	/// how many wet stacks it will add
	var/stacks_to_add = 2
	/// will it remove fire stacks
	var/dousing = FALSE

/datum/component/wet_stacks_granter/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(apply_status_effect))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(remove_status_effect))

/datum/component/wet_stacks_granter/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
	))

///
/datum/component/wet_stacks_granter/proc/apply_status_effect(obj/item/source, mob/living/user, slot)
	SIGNAL_HANDLER
	user.apply_status_effect(/datum/status_effect/grouped/artificial_hydration, source, power_cost, stacks_to_add, dousing)

///
/datum/component/wet_stacks_granter/proc/remove_status_effect(obj/item/source, mob/living/user, slot)
	SIGNAL_HANDLER
	user.remove_status_effect(/datum/status_effect/grouped/artificial_hydration, source)

///
/datum/status_effect/grouped/artificial_hydration
	id = "artificial_hydration"
	alert_type = null
	tick_interval = 5 SECONDS
	var/power_cost
	var/stacks_to_add
	var/dousing

/datum/status_effect/grouped/artificial_hydration/on_creation(mob/living/new_owner, obj/item/source, _power_cost, _stacks_to_add, _dousing)
	power_cost = _power_cost
	stacks_to_add = _stacks_to_add
	dousing = _dousing
	return ..()

/datum/status_effect/grouped/artificial_hydration/tick(seconds_between_ticks)
	var/charged = FALSE
	for(var/obj/item as anything in sources)
		if(istype(item, /obj/item/mod/control))
			var/obj/item/mod/module/humidity_regulator/regulator = locate() in item.contents
			if(regulator?.active)
				charged = TRUE // charging handled by modsuit
				break
		var/obj/item/stock_parts/power_store/cell/cell = locate() in item.contents
		if(cell?.charge > power_cost)
			var/obj/item/clothing/accessory/vaporizer/vaporizer = item
			vaporizer?.charge_bar?.update(cell.charge())
			cell.use(power_cost, TRUE)
			charged = TRUE
			break
		else
			continue
	if(!charged)
		return
	var/datum/status_effect/fire_handler/wet_stacks/wet_status = owner?.has_status_effect(/datum/status_effect/fire_handler/wet_stacks)
	if(wet_status?.stacks <= stacks_to_add)
		owner.set_wet_stacks(stacks = stacks_to_add, remove_fire_stacks = dousing)
