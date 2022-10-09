/obj/structure/blacksmith/furnace
	name = "furnace"
	desc = "A furnace."
	icon = 'modular_atom/blacksmith/icons/blacksmith.dmi'
	icon_state = "furnace0"
	density = TRUE
	anchored = TRUE
	max_integrity = 700
	var/debug = FALSE //debugging only
	var/working = TRUE
	var/fueluse = 1
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = GLOW_BRIGHT
	light_color = LIGHT_COLOR_FIRE
	light_on = FALSE
	var/datum/looping_sound/furnace/soundloop

/obj/structure/blacksmith/furnace/Initialize()
	. = ..()
	create_reagents(250, TRANSPARENT)
	START_PROCESSING(SSobj, src)
	soundloop = new(src, TRUE)

/obj/structure/blacksmith/furnace/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/blacksmith/furnace/process()
	if(debug)
		reagents.add_reagent(/datum/reagent/fuel, 1)
		return TRUE
	if(reagents.remove_reagent(/datum/reagent/fuel, fueluse))
		working = TRUE
		soundloop.start()
		set_light_on(TRUE)
		if(icon_state == "furnace0")
			icon_state = "furnace1"

	else
		working = FALSE
		soundloop.stop()
		set_light_on(FALSE)
		icon_state = "furnace0"

/obj/structure/blacksmith/furnace/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/blacksmith/ingot))
		var/obj/item/blacksmith/ingot/notsword = I
		if(working)
			to_chat(user, "You heat the [notsword] in the [src].")
			notsword.workability = "shapeable"
			notsword.icon_state = "hot_ingot"
			notsword.set_light_on(TRUE)
			I.on_attack_hand(user)
		else
			to_chat(user, "The furnace isn't working!.")
	else
		. = ..()

/obj/structure/blacksmith/furnace/attackby(obj/item/W, mob/user, params)
	if(W.reagents)
		W.reagents.trans_to(src, 250)
	else
		return ..()

/obj/structure/blacksmith/furnace/plunger_act(obj/item/plunger/P, mob/living/user, reinforced)
	to_chat(user, "<span class='notice'>You start furiously plunging [name].")
	if(do_after(user, 30, target = src))
		to_chat(user, "<span class='notice'>You finish plunging the [name].")
		reagents.reaction(get_turf(src), TOUCH) //splash on the floor
		reagents.clear_reagents()

/datum/looping_sound/furnace
	mid_sounds = list('modular_atom/blacksmith/sound/furnace1.ogg'=1)
	mid_length = 70
	volume = 80
