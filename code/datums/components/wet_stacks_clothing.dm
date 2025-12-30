///
/datum/component/wet_stacks_clothing
	///
	var/mob/living/carbon/wearer
	///
	var/datum/callback/use_cell
	///
	var/power_cost
	/// how many wet stacks it will add
	var/stacks_to_add = 3
	/// will it remove fire stacks
	var/dousing = FALSE
	///
	var/cooldown = 5 //seconds

/datum/component/wet_stacks_clothing/Initialize(power_cost, datum/callback/use_cell)
	. = ..()
	src.power_cost = power_cost
	src.use_cell = use_cell

///
/datum/component/wet_stacks_clothing/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(start_processing))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(stop_processing))

///
/datum/component/wet_stacks_clothing/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
	))

///
/datum/component/wet_stacks_clothing/proc/start_processing(obj/item/source, mob/living/user, slot)
	SIGNAL_HANDLER
	START_PROCESSING(SSobj, src)
	wearer = user

///
/datum/component/wet_stacks_clothing/proc/stop_processing(obj/item/source, mob/living/user, slot)
	SIGNAL_HANDLER
	STOP_PROCESSING(SSobj, src)
	wearer = null

/datum/component/wet_stacks_clothing/process(seconds_per_tick)
	if (cooldown > 0)
		cooldown -= seconds_per_tick
		return
	cooldown = initial(cooldown)
	//
	var/datum/status_effect/fire_handler/wet_stacks/wet_stacks = wearer?.has_status_effect(/datum/status_effect/fire_handler/wet_stacks)
	if(wet_stacks && wet_stacks?.stacks > stacks_to_add)
		return
	//
	if(power_cost)
		if(!use_cell?.Invoke())
			return
	wearer?.set_wet_stacks(stacks = stacks_to_add, remove_fire_stacks = dousing)
