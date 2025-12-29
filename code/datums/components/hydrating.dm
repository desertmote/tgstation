///
/datum/component/wet_stacks_granter
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// how many wet stacks it will add
	var/stacks_to_add = 2
	/// will it remove fire stacks
	var/dousing = FALSE
	/// the kind of status effect that will be given by the component holder
	var/datum/status_effect/grouped/hydrating/status_effect_type

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
	user.apply_status_effect(/datum/status_effect/grouped/hydrating, REF(source), stacks_to_add, dousing)

///
/datum/component/wet_stacks_granter/proc/remove_status_effect(obj/item/source, mob/living/user, slot)
	SIGNAL_HANDLER
	user.remove_status_effect(/datum/status_effect/grouped/hydrating, REF(source), stacks_to_add, dousing)

///
/datum/status_effect/grouped/hydrating
	id = "hydrating"
	alert_type = null
	tick_interval = 5 SECONDS
	var/stacks_to_add
	var/dousing

/datum/status_effect/grouped/hydrating/on_creation(mob/living/new_owner, source, _stacks_to_add, _dousing)
	stacks_to_add = _stacks_to_add
	dousing = _dousing
	return ..()

/datum/status_effect/grouped/hydrating/tick(seconds_between_ticks)
	var/datum/status_effect/fire_handler/wet_stacks/wet_status = owner?.has_status_effect(/datum/status_effect/fire_handler/wet_stacks)
	if(wet_status?.stacks <= stacks_to_add)
		owner.set_wet_stacks(stacks = stacks_to_add, remove_fire_stacks = dousing)
