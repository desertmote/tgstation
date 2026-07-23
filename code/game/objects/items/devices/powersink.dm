#define DISCONNECTED 0
#define CLAMPED_OFF 1
#define OPERATING 2

#define FRACTION_TO_RELEASE 0.2
#define ALERT 90
#define MINIMUM_HEAT 20000

// Powersink - used to drain station power

/obj/item/powersink
	name = "power sink"
	desc = "A power sink which drains energy from electrical systems and converts it to heat. Ensure short workloads and ample time to cool down if used in high energy systems."
	icon = 'icons/obj/devices/syndie_gadget.dmi'
	icon_state = "powersink0"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = NO_PIXEL_RANDOM_DROP
	throwforce = 5
	throw_speed = 1
	throw_range = 2
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT* 7.5)
	var/max_heat = 20 MEGA JOULES // Maximum contained heat before exploding.
	var/internal_heat = 0 // Contained heat, goes down every tick.
	var/mode = DISCONNECTED // DISCONNECTED, CLAMPED_OFF, OPERATING
	var/warning_given = FALSE //! Stop warning spam, only warn the admins/deadchat once that we are about to boom.
	var/ghost_announce = TRUE //should we announce events related to ghosts?

	var/obj/structure/cable/attached

/obj/item/powersink/update_icon_state()
	icon_state = "powersink[mode == OPERATING]"
	return ..()

/obj/item/powersink/examine(mob/user)
	. = ..()
	if(mode)
		. += "\The [src] is bolted to the floor."
	if((in_range(user, src) || isobserver(user)) && internal_heat > max_heat * 0.5)
		. += span_danger("[src] is warping the air above it. It must be very hot.")

/obj/item/powersink/set_anchored(anchorvalue)
	. = ..()
	set_density(anchorvalue)

/obj/item/powersink/proc/set_mode(value)
	if(value == mode)
		return
	switch(value)
		if(DISCONNECTED)
			attached = null
			if(mode == OPERATING && internal_heat < MINIMUM_HEAT)
				STOP_PROCESSING(SSobj, src)
				internal_heat = 0
			set_anchored(FALSE)

		if(CLAMPED_OFF)
			if(!attached)
				return
			if(mode == OPERATING && internal_heat < MINIMUM_HEAT)
				STOP_PROCESSING(SSobj, src)
				internal_heat = 0
			set_anchored(TRUE)

		if(OPERATING)
			if(!attached)
				return
			START_PROCESSING(SSobj, src)
			set_anchored(TRUE)

	mode = value
	update_appearance()
	set_light(0)

/obj/item/powersink/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(mode == DISCONNECTED)
		var/turf/T = loc
		if(isturf(T) && T.underfloor_accessibility >= UNDERFLOOR_INTERACTABLE)
			attached = locate() in T
			if(!attached)
				to_chat(user, span_warning("\The [src] must be placed over an exposed, powered cable node!"))
			else
				set_mode(CLAMPED_OFF)
				user.visible_message( \
					"[user] attaches \the [src] to the cable.", \
					span_notice("You bolt \the [src] into the floor and connect it to the cable."),
					span_hear("You hear some wires being connected to something."))
		else
			to_chat(user, span_warning("\The [src] must be placed over an exposed, powered cable node!"))
	else
		set_mode(DISCONNECTED)
		user.visible_message( \
			"[user] detaches \the [src] from the cable.", \
			span_notice("You unbolt \the [src] from the floor and detach it from the cable."),
			span_hear("You hear some wires being disconnected from something."))

/obj/item/powersink/screwdriver_act(mob/living/user, obj/item/tool)
	user.visible_message( \
		"[user] messes with \the [src] for a bit.", \
		span_notice("You can't fit the screwdriver into \the [src]'s bolts! Try using a wrench."))
	return TRUE

/obj/item/powersink/attack_paw(mob/user, list/modifiers)
	return

/obj/item/powersink/attack_ai()
	return

/obj/item/powersink/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	switch(mode)
		if(DISCONNECTED)
			..()

		if(CLAMPED_OFF)
			user.visible_message( \
				"[user] activates \the [src]!", \
				span_notice("You activate \the [src]."),
				span_hear("You hear a click."))
			message_admins("[src] activated by [ADMIN_LOOKUPFLW(user)] at [ADMIN_VERBOSEJMP(src)]")
			user.log_message("activated \the [src]", LOG_GAME)
			if(ghost_announce)
				notify_ghosts(
					"[user.real_name] has activated a power sink!",
					source = src,
					header = "Shocking News!",
				)
			set_mode(OPERATING)

		if(OPERATING)
			user.visible_message( \
				"[user] deactivates \the [src]!", \
				span_notice("You deactivate \the [src]."),
				span_hear("You hear a click."))
			user.log_message("deactivated [src]", LOG_GAME)
			set_mode(CLAMPED_OFF)

/// Removes internal heat and shares it with the atmosphere.
/obj/item/powersink/proc/release_heat()
	var/turf/our_turf = get_turf(src)
	var/temp_to_give = internal_heat * FRACTION_TO_RELEASE
	internal_heat -= temp_to_give
	var/datum/gas_mixture/environment = our_turf.return_air()
	var/delta_temperature = temp_to_give / environment.heat_capacity()
	if(delta_temperature)
		environment.temperature += delta_temperature
		air_update_turf(TRUE, FALSE)
	if(warning_given && internal_heat < max_heat * 0.75)
		warning_given = FALSE
		message_admins("[name] at ([x],[y],[z] - <A href='byond://?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>) has cooled down and will not explode.")
	if(mode != OPERATING && internal_heat < MINIMUM_HEAT)
		internal_heat = 0
		STOP_PROCESSING(SSobj, src)

/// Drains power from the connected powernet, if any.
/obj/item/powersink/proc/drain_power()
	var/datum/powernet/powernet = attached.powernet
	var/drained = 0
	set_light(5)

	// Drain as much as we can from the powernet.
	drained = attached.newavail()
	attached.add_delayedload(drained)

	// If tried to drain more than available on powernet, now look for APCs and drain their cells
	for(var/obj/machinery/power/terminal/terminal in powernet.nodes)
		if(istype(terminal.master, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/apc = terminal.master
			if(apc.operating && apc.cell)
				drained += 0.001 * apc.cell.use(0.1 * STANDARD_BATTERY_CHARGE, force = TRUE)
	internal_heat += drained
	return drained

/obj/item/powersink/process()
	if(!attached)
		set_mode(DISCONNECTED)

	release_heat()

	if(mode != OPERATING)
		return

	drain_power()

	if(internal_heat > max_heat * ALERT / 100)
		if (!warning_given)
			warning_given = TRUE
			message_admins("Power sink at ([x],[y],[z] - <A href='byond://?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>) has reached [ALERT]% of max heat. Explosion imminent.")
			if(ghost_announce)
				notify_ghosts(
					"[src] is about to reach critical heat capacity!",
					source = src,
					header = "Power Sunk",
				)
		playsound(src, 'sound/effects/screech.ogg', 100, TRUE, TRUE)

	if(internal_heat >= max_heat)
		STOP_PROCESSING(SSobj, src)
		explosion(src, devastation_range = 4, heavy_impact_range = 8, light_impact_range = 16, flash_range = 32)
		qdel(src)


#define POWER_FOR_PAYOUT (20 KILO WATTS) // How much do we draw for a payout
#define PAYOUT 100 // How much is the energy worth
#define DRAIN_FORMULA (0.1 * STANDARD_BATTERY_CHARGE) //How much % per tick gets drained from the powernet. standard cell because thats what APCs start with

/obj/item/powersink/creditminer
	name = "converted power sink"
	desc = "A highly modified power sink, functionally the same on one exception, it transforms the power into minted holo credit - still gets extremely hot while working; keep the temperature in check or suffer the explosive consequence."
	w_class = WEIGHT_CLASS_HUGE
	max_heat = 50 MEGA JOULES
	/// The amount of power the machine has converted to credits.
	var/cash_out = 0
	/// The machine's internal radio, used to broadcast alerts.
	var/obj/item/radio/radio
	/// The key our internal radio uses
	var/radio_key = /obj/item/encryptionkey/syndicate
	/// The channel we announce over.
	var/radio_channel = RADIO_CHANNEL_SYNDICATE
	/// Amount of time before the next warning over the radio is announced.
	var/next_warning = 0
	/// The amount of time we have between warnings
	var/minimum_time_between_warnings = 3 SECONDS

/obj/item/powersink/creditminer/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.keyslot = new radio_key
	radio.set_listening(FALSE)
	radio.recalculateChannels()

/obj/item/powersink/creditminer/examine(mob/user)
	. = ..()
	if(cash_out)
		. += span_blue("[src] has mined [trunc(cash_out)] credits.")
	if(mode) //can only print when in structure mode, not object mode
		. += span_blue("<b>Ctrl-click</b> to print a holochip.")

/// Controls for printing the cash
/obj/item/powersink/creditminer/item_ctrl_click(mob/user)
	. = ..()
	if(!mode) //unwrenched
		return CLICK_ACTION_BLOCKING
	print()
	return CLICK_ACTION_SUCCESS

/// Additional sound effects on clicking with hand
/obj/item/powersink/creditminer/attack_hand(mob/user, list/modifiers)
	. = ..()
	switch(mode)
		if(CLAMPED_OFF) //on turning off
			playsound(src, 'sound/machines/credit_miner/creditminer_stop.ogg', 50, FALSE)

		if(OPERATING) //on turning on
			playsound(src, 'sound/machines/credit_miner/creditminer_start.ogg', 50, FALSE)

/// Radio alarm functionality
/obj/item/powersink/creditminer/process()
	. = ..()
	if(!(internal_heat > max_heat * ALERT / 100))
		return
	if(next_warning < world.time)
		var/area = "[uppertext(get_area(src))]"
		var/message = "OVERHEAT IMMINENT at [area]!!"
		radio.talk_into(src, message, radio_channel)
		next_warning = world.time + minimum_time_between_warnings

/// Additional sfx/vfx
/obj/item/powersink/creditminer/release_heat()
	. = ..()
	if(internal_heat < MINIMUM_HEAT)
		return
	if(mode != OPERATING) //sfx if we release heat, but don't overlap the drain sfx
		playsound(src, 'sound/machines/credit_miner/creditminer_vent.ogg', 50, FALSE)
	new /obj/effect/temp_visual/mook_dust(get_turf(src))

/// Power to cash logic
/obj/item/powersink/creditminer/drain_power()
	var/drained = ..()
	var/cash_pulse = min(energy_to_power(drained) / POWER_FOR_PAYOUT, PAYOUT)
	if(cash_pulse >= 1)
		cash_out += cash_pulse
		balloon_alert_to_viewers("mined [trunc(cash_pulse)]cr")
		playsound(src, 'sound/machines/credit_miner/creditminer_drain.ogg', 50, FALSE)

/// The actual cash printing
/obj/item/powersink/creditminer/proc/print()
	if(cash_out > 0)
		playsound(src, 'sound/items/poster/poster_being_created.ogg', 100, TRUE)
		balloon_alert_to_viewers("printed [trunc(cash_out)] credits")
		new /obj/item/holochip(drop_location(), trunc(cash_out)) //get the loot
		cash_out = 0

#undef POWER_FOR_PAYOUT
#undef PAYOUT
#undef DRAIN_FORMULA

#undef DISCONNECTED
#undef CLAMPED_OFF
#undef OPERATING
#undef FRACTION_TO_RELEASE
#undef ALERT
#undef MINIMUM_HEAT
