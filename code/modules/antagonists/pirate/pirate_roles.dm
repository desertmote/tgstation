
//space pirates from the pirate event.

/obj/effect/mob_spawn/ghost_role/human/pirate
	name = "space pirate sleeper"
	desc = "A cryo sleeper smelling faintly of rum."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "a space pirate"
	outfit = /datum/outfit/pirate/space
	anchored = TRUE
	density = FALSE
	show_flavor = FALSE //Flavour only exists for spawners menu
	you_are_text = "You are a space pirate."
	flavour_text = "The station refused to pay for your protection. Protect the ship, siphon the credits from the station, and raid it for even more loot."
	spawner_job_path = /datum/job/space_pirate
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE
	///Rank of the pirate on the ship, it's used in generating pirate names!
	var/rank = "Deserter"
	///Leader spawners are filled before the rest of the crew.
	var/is_leader = FALSE
	///Path of the structure we spawn after creating a pirate.
	var/fluff_spawn = /obj/structure/showcase/machinery/oldpod/used

	//obviously, these pirate name vars are only used if you don't override `generate_pirate_name()`
	///json key to pirate names, the first part ("Comet" in "Cometfish")
	var/name_beginnings = "generic_beginnings"
	///json key to pirate names, the last part ("fish" in "Cometfish")
	var/name_endings = "generic_endings"

/obj/effect/mob_spawn/ghost_role/human/pirate/special(mob/living/spawned_mob, mob/mob_possessor, apply_prefs)
	. = ..()
	spawned_mob.fully_replace_character_name(spawned_mob.real_name, generate_pirate_name(spawned_mob.gender))
	spawned_mob.mind.add_antag_datum(/datum/antagonist/pirate)

/obj/effect/mob_spawn/ghost_role/human/pirate/proc/generate_pirate_name(spawn_gender)
	var/beggings = strings(PIRATE_NAMES_FILE, name_beginnings)
	var/endings = strings(PIRATE_NAMES_FILE, name_endings)
	return "[rank ? rank + " " : ""][pick(beggings)][pick(endings)]"

/obj/effect/mob_spawn/ghost_role/human/pirate/create(mob/mob_possessor, newname, apply_prefs)
	if(fluff_spawn)
		new fluff_spawn(drop_location())
	return ..()

/obj/effect/mob_spawn/ghost_role/human/pirate/captain
	rank = "Renegade Leader"
	outfit = /datum/outfit/pirate/space/captain
	is_leader = TRUE

/obj/effect/mob_spawn/ghost_role/human/pirate/gunner
	rank = "Rogue"

/obj/effect/mob_spawn/ghost_role/human/pirate/skeleton
	name = "pirate remains"
	desc = "Some inanimate bones. They feel like they could spring to life at any moment!"
	density = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	prompt_name = "a skeleton pirate"
	mob_species = /datum/species/skeleton
	outfit = /datum/outfit/pirate
	rank = "Mate"
	fluff_spawn = null
	allow_custom_character = NONE

/obj/effect/mob_spawn/ghost_role/human/pirate/skeleton/captain
	rank = "Captain"
	outfit = /datum/outfit/pirate/captain/skeleton
	is_leader = TRUE

/obj/effect/mob_spawn/ghost_role/human/pirate/skeleton/gunner
	rank = "Gunner"

/obj/effect/mob_spawn/ghost_role/human/pirate/silverscale
	name = "elegant sleeper"
	desc = "Cozy. You get the feeling you aren't supposed to be here, though..."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "a silverscale"
	mob_species = /datum/species/lizard/silverscale
	outfit = /datum/outfit/pirate/silverscale
	rank = "High-born"
	allow_custom_character = NONE

/obj/effect/mob_spawn/ghost_role/human/pirate/silverscale/generate_pirate_name(spawn_gender)
	var/first_name
	switch(spawn_gender)
		if(MALE)
			first_name = pick(GLOB.lizard_names_male)
		if(FEMALE)
			first_name = pick(GLOB.lizard_names_female)
		else
			first_name = pick(GLOB.lizard_names_male + GLOB.lizard_names_female)

	return "[rank] [first_name]-Silverscale"

/obj/effect/mob_spawn/ghost_role/human/pirate/silverscale/captain
	rank = "Old-guard"
	outfit = /datum/outfit/pirate/silverscale/captain
	is_leader = TRUE

/obj/effect/mob_spawn/ghost_role/human/pirate/silverscale/gunner
	rank = "Top-drawer"

/obj/effect/mob_spawn/ghost_role/human/pirate/interdyne
	name = "\improper Interdyne sleeper"
	desc = "A surprisingly clean cryogenic sleeper. You can see your reflection on the sides!"
	density = FALSE
	you_are_text = "You are an Ex-Interdyne pharmacyst now turned space pirate."
	flavour_text = "The station has refused to fund your research, so you will 'convince' them to donate to your charitable cause."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "An Ex-Interdyne employee"
	outfit = /datum/outfit/pirate/interdyne
	rank = "Pharmacist"

/obj/effect/mob_spawn/ghost_role/human/pirate/interdyne/generate_pirate_name(spawn_gender)
	var/first_name
	switch(spawn_gender)
		if(MALE)
			first_name = pick(GLOB.first_names_male)
		if(FEMALE)
			first_name = pick(GLOB.first_names_female)
		else
			first_name = pick(GLOB.first_names)

	return "[rank] [first_name]"

/obj/effect/mob_spawn/ghost_role/human/pirate/interdyne/senior
	rank = "Pharmacist Director"
	outfit = /datum/outfit/pirate/interdyne/captain
	is_leader = TRUE

/obj/effect/mob_spawn/ghost_role/human/pirate/interdyne/junior
	rank = "Pharmacist"

/obj/effect/mob_spawn/ghost_role/human/pirate/grey
	name = "\improper Assistant sleeper"
	desc = "A very dirty cryogenic sleeper. You're not sure if it even works."
	density = FALSE
	you_are_text = "You used to be a Nanotrasen assistant, until a riot gone awry. Now you wander space, ransacking any ships you come across!"
	flavour_text = "There's nothing a toolbox can't whack in the head enough times to spill blood, or in this case money. Loot everything!"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "An assistant gone loose"
	outfit = /datum/outfit/pirate/grey
	rank = "Tider"

/obj/effect/mob_spawn/ghost_role/human/pirate/grey/shitter
	rank = "Tidemaster"

/obj/effect/mob_spawn/ghost_role/human/pirate/irs
	name = "\improper Space IRS sleeper"
	desc = "A surprisingly clean cryogenic sleeper. You can see your reflection on the sides!"
	density = FALSE
	you_are_text = "You are an agent working for the space IRS"
	flavour_text = "Not even in the expanse of the expanding universe can someone evade the tax man! Whether you are just a well disciplined and professional pirate gang or an actual agent from a local polity. You will squeeze the station dry of its income regardless! Through peaceful means or otherwise..."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "An agent of the space IRS"
	outfit = /datum/outfit/pirate/irs
	fluff_spawn = null // dirs are fucked and I don't have the energy to deal with it
	rank = "Agent"

/obj/effect/mob_spawn/ghost_role/human/pirate/irs/generate_pirate_name(spawn_gender)
	var/first_name
	switch(spawn_gender)
		if(MALE)
			first_name = pick(GLOB.first_names_male)
		if(FEMALE)
			first_name = pick(GLOB.first_names_female)
		else
			first_name = pick(GLOB.first_names)

	return "[rank] [first_name]"


/obj/effect/mob_spawn/ghost_role/human/pirate/irs/auditor
	rank = "Head Auditor"
	outfit = /datum/outfit/pirate/irs/auditor
	is_leader = TRUE

/obj/effect/mob_spawn/ghost_role/human/pirate/lustrous
	name = "lustrous crystal"
	desc = "A crystal housing a mutated Ethereal, it emanates a foreboding glow."
	density = FALSE
	you_are_text = "Once you were a proud Ethereal, now all that remains is your hunger for the precious bluespace crystal."
	flavour_text = "The station has denied you your bluespace crystals, the sweet ambrosia of the fifth-dimension. Strike the earth!"
	icon = 'icons/mob/effects/ethereal_crystal.dmi'
	icon_state = "ethereal_crystal"
	fluff_spawn = null
	prompt_name = "a geode dweller"
	mob_species = /datum/species/ethereal/lustrous
	outfit = /datum/outfit/pirate/lustrous
	rank = "Scintillant"
	allow_custom_character = NONE

/obj/effect/mob_spawn/ghost_role/human/pirate/lustrous/captain
	rank = "Radiant"
	outfit = /datum/outfit/pirate/lustrous/captain
	is_leader = TRUE

/obj/effect/mob_spawn/ghost_role/human/pirate/lustrous/gunner
	rank = "Coruscant"

/obj/effect/mob_spawn/ghost_role/human/pirate/medieval
	name = "\improper Improvised sleeper"
	desc = "A body bag poked with holes, currently being used as a sleeping bag. Someone seems to be sleeping inside of it."
	density = FALSE
	you_are_text = "You were a nobody before, until you were given a sword and the opportunity to rise up in ranks. If you put some effort, you can make it big!"
	flavour_text = "Raiding some cretins while engaging in bloodsport and violence? what a deal. Stay together and pillage everything!"
	icon = 'icons/obj/medical/bodybag.dmi'
	icon_state = "bodybag"
	fluff_spawn = null
	prompt_name = "a medieval warmonger"
	outfit = /datum/outfit/pirate/medieval
	rank = "Footsoldier"

/obj/effect/mob_spawn/ghost_role/human/pirate/medieval/special(mob/living/carbon/spawned_mob, mob/mob_possessor, apply_prefs)
	. = ..()
	if(rank == "Footsoldier")
		spawned_mob.add_traits(list(TRAIT_NOGUNS, TRAIT_TOSS_GUN_HARD), INNATE_TRAIT)
		spawned_mob.AddComponent(/datum/component/unbreakable)
		var/datum/action/cooldown/mob_cooldown/dash/dodge = new(spawned_mob)
		dodge.Grant(spawned_mob)

/obj/effect/mob_spawn/ghost_role/human/pirate/medieval/warlord
	rank = "Warlord"
	outfit = /datum/outfit/pirate/medieval/warlord
	is_leader = TRUE

/obj/effect/mob_spawn/ghost_role/human/pirate/medieval/warlord/special(mob/living/carbon/spawned_mob, mob/mob_possessor, apply_prefs)
	. = ..()
	spawned_mob.dna.add_mutation(/datum/mutation/hulk/superhuman, MUTATION_SOURCE_GHOST_ROLE)
	spawned_mob.dna.add_mutation(/datum/mutation/gigantism, MUTATION_SOURCE_GHOST_ROLE)

/obj/effect/mob_spawn/ghost_role/human/pirate/siren
	name = "\improper Sleeper"
//	desc = ""
	density = TRUE
	deletes_on_zero_uses_left = FALSE
	mob_species = /datum/species/human/cerulean/abyssal
	allow_custom_character = NONE
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_1"
	fluff_spawn = /obj/effect/decal/cleanable/greenglow
//	you_are_text = ""
//	flavour_text = ""
//	prompt_name = ""
	outfit = /datum/outfit/pirate/siren
	rank = "Guitarist"

/obj/effect/mob_spawn/ghost_role/human/pirate/siren/check_uses()
	. = ..()
	if(!uses)
		icon_state = "pod_0"

/obj/effect/mob_spawn/ghost_role/human/pirate/siren/special(mob/living/carbon/spawned_mob, mob/mob_possessor, apply_prefs)
	. = ..()
	var/mob/living/carbon/human/human_mob = spawned_mob
	var/datum/language_holder/language_holder = human_mob.get_language_holder()
	language_holder.selected_language = /datum/language/common //sing
	human_mob.add_personalities(list(/datum/personality/apathetic, /datum/personality/pessimistic, /datum/personality/brave)) //i'm not willing to die for this, but i'm willing to kill you
	var/obj/item/organ/lungs/lungs = new human_mob.dna.species.mutantlungs(human_mob)
	lungs.mob_insert(human_mob, TRUE, DELETE_IF_REPLACED) //updates the organ set bonus "appropriately", thanks to randomize_human_normie() earlier in the parent call
	var/list/eyecolors = list("#ff0000", "#04ff58", "#ffe600", "#d400ff")
	var/list/hairstyles = list(
		/datum/sprite_accessory/hair/sadako::name,
		/datum/sprite_accessory/hair/moneypiece::name,
		/datum/sprite_accessory/hair/frizzysidecut::name,
		/datum/sprite_accessory/hair/coily::name,
		/datum/sprite_accessory/hair/wolfcut::name,
		/datum/sprite_accessory/hair/shortwavy::name,
		/datum/sprite_accessory/hair/sidecutbang::name,
		/datum/sprite_accessory/hair/shorterbangs::name,
	)
	var/hex_to_edit = copytext(human_mob.dna.features[FEATURE_TAIL_FISH_COLOR], 2)
	var/haircolor = sanitize_hexcolor(rgb(//returns a much brighter variation of the blorbo's tail color
		min(255, hex2num(copytext(hex_to_edit, 1, 3)) * 3.5),
		min(255, hex2num(copytext(hex_to_edit, 3, 5)) * 3.5),
		min(255, hex2num(copytext(hex_to_edit, 5, 7)) * 3.5),
	))
	var/hairgradient_color = sanitize_hexcolor(rgb(//returns a slightly brighter variation of the blorbo's tail color
		min(255, hex2num(copytext(hex_to_edit, 1, 3)) * 1.5),
		min(255, hex2num(copytext(hex_to_edit, 3, 5)) * 1.5),
		min(255, hex2num(copytext(hex_to_edit, 5, 7)) * 1.5),
	))
	human_mob.set_facial_hairstyle(/datum/sprite_accessory/facial_hair/shaved::name)
	human_mob.set_hairstyle(pick(hairstyles))
	human_mob.set_haircolor(haircolor)
	human_mob.set_hair_gradient_style(/datum/sprite_accessory/gradient/reflected_inverse::name)
	human_mob.set_hair_gradient_color(hairgradient_color)
	human_mob.set_eye_color(pick(eyecolors), pick(eyecolors))
	human_mob.update_eyes()

	var/its_not_actually_a_horn = human_mob.dna.species.mutant_organs[/obj/item/organ/horns]
	var/obj/item/organ/horn = human_mob.get_organ_slot(ORGAN_SLOT_EXTERNAL_HORNS)
	human_mob.dna.features[FEATURE_HORNS] = its_not_actually_a_horn
	horn?.bodypart_overlay.draw_color = human_mob.dna.features[FEATURE_TAIL_FISH_COLOR]
	horn?.simple_change_sprite(horn.bodypart_overlay.fetch_sprite_datum_from_name(its_not_actually_a_horn))

	human_mob.gender = (rand(0, 10) > 3) ? FEMALE : PLURAL //despite physique always she/her or they/them. why? because they're sisters of course. 🏳️‍⚧️

	human_mob.set_resting(FALSE, TRUE, TRUE)
	human_mob.refresh_gravity()

/obj/effect/mob_spawn/ghost_role/human/pirate/siren/vocalist
	rank = "Vocalist"
	outfit = /datum/outfit/pirate/siren/vocalist
