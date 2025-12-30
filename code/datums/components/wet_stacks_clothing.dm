///
/datum/component/wet_stacks_clothing
	/// how many wet stacks it will add
	var/stacks_to_add = 3
	/// will it remove fire stacks
	var/dousing = FALSE
	///
	var/must_be_worn = TRUE
	///
	var/mob/living/carbon/wearer
	///
	var/datum/callback/use_cell
	///
	var/power_cost
	///
	COOLDOWN_DECLARE(tick_cooldown)

/datum/component/wet_stacks_clothing/Initialize(power_cost, datum/callback/use_cell, must_be_worn)
	. = ..()
	src.power_cost = power_cost
	src.use_cell = use_cell
	src.must_be_worn = must_be_worn

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
	if(must_be_worn && (slot & ITEM_SLOT_HANDS))
		return
	START_PROCESSING(SSobj, src)
	wearer = user

///
/datum/component/wet_stacks_clothing/proc/stop_processing(obj/item/source, mob/living/user, slot)
	SIGNAL_HANDLER
	STOP_PROCESSING(SSobj, src)
	wearer = null

/datum/component/wet_stacks_clothing/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, tick_cooldown))
		return
	COOLDOWN_START(src, tick_cooldown, rand(10 SECONDS, 30 SECONDS))
	//
	var/datum/status_effect/fire_handler/wet_stacks/wet_stacks = wearer.has_status_effect(/datum/status_effect/fire_handler/wet_stacks)
	if(wet_stacks && wet_stacks?.stacks > stacks_to_add)
		return
	//
	if(power_cost)
		if(!use_cell?.Invoke())
			return
	playsound(wearer, 'sound/effects/droplet.ogg', rand(15, 35), TRUE, falloff_exponent = 5)
	wearer.set_wet_stacks(stacks = stacks_to_add, remove_fire_stacks = dousing)
