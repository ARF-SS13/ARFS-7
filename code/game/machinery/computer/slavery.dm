/obj/machinery/computer/slavery
	name = "\improper slave management console"
	desc = "Used to track and manage collared slaves. The limited range reaches only as far as the hideout perimeter."
	icon_screen = "explosive"
	icon_keyboard = "security_key"
	clockwork = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	req_access = list(ACCESS_SLAVER)
	light_color = LIGHT_COLOR_RED
	var/selected_cat
	/// Dictates if the compact mode of the interface is on or off
	var/compact_mode = FALSE
	/// Possible gear to be dispensed
	var/list/possible_gear

/obj/machinery/computer/slavery/Initialize(mapload)
	. = ..()
	possible_gear = get_slaver_gear()

/obj/machinery/computer/slavery/proc/get_slaver_gear()
	var/list/filtered_modules = list()
	for(var/path in GLOB.slaver_gear)
		var/datum/slaver_gear/SG = new path
		if(!filtered_modules[SG.category])
			filtered_modules[SG.category] = list()
		filtered_modules[SG.category][SG] = SG
	return filtered_modules

// /obj/machinery/computer/slavery/ui_interact(mob/user)
// 	. = ..()
// 	var/dat = ""
// 	dat += "<a href='byond://?src=[REF(src)];scan=1'>Refresh.</a><BR>"
// 	dat += "[storedcrystals] telecrystals are available for distribution. <BR>"
// 	dat += "<BR><BR>"

// 	dat += "<HR>Slaves<BR>"
// 	for(var/obj/item/electropack/shockcollar/slave/S in GLOB.tracked_slaves)
// 		if(!isliving(loc))
// 			continue
// 		Tr = get_turf(T.imp_in)
// 		if((Tr) && (Tr.z != src.z))
// 			continue//Out of range

// 		var/loc_display = "Unknown"
// 		var/mob/living/M = T.imp_in
// 		if(is_station_level(Tr.z) && !isspaceturf(M.loc))
// 			var/turf/mob_loc = get_turf(M)
// 			loc_display = mob_loc.loc

// 		dat += "ID: [T.imp_in.name] | Location: [loc_display]<BR>"
// 		dat += "<A href='?src=[REF(src)];warn=[REF(T)]'>(<font class='bad'><i>Message Holder</i></font>)</A> |<BR>"
// 		dat += "********************************<BR>"
// 	dat += "<HR><A href='?src=[REF(src)];lock=1'>{Log Out}</A>"

/obj/machinery/computer/slavery/ui_interact(mob/user, datum/tgui/ui)
	// priority_announce("Message test 123 123 Message test 123 123 Message test 123 123 Message test 123 123 Message test 123 123.", sender_override = "Hail from the [slaver_team.slaver_crew_name]")
	// if(!GLOB.bounties_list.len)
	// 	setup_bounties()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlaveConsole", name)
		ui.open()

/obj/machinery/computer/slavery/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()
	for(var/category in possible_gear)
		var/list/cat = list(
			"name" = category,
			"items" = (category == selected_cat ? list() : null))
		for(var/gear in possible_gear[category])
			var/datum/slaver_gear/AG = possible_gear[category][gear]
			cat["items"] += list(list(
				"name" = AG.name,
				"cost" = AG.cost,
				"desc" = AG.description,
			))
		data["categories"] += list(cat)

	var/turf/curr = get_turf(src)
	data["currentCoords"] = "[curr.x], [curr.y], [curr.z]"

	return data


/obj/machinery/computer/slavery/ui_data(mob/user)
	var/list/data = list()

	data["credits"] = GLOB.slavers_credits_balance
	data["compactMode"] = compact_mode
	var/list/slaves = list()
	data["slaves"] = list()

	for(var/tracked_slave in GLOB.tracked_slaves)
		var/obj/item/electropack/shockcollar/slave/C = tracked_slave
		if (!isliving(C.loc))
			continue;

		var/mob/living/L = C.loc
		var/turf/pos = get_turf(L)
		if(!pos || C != L.get_item_by_slot(SLOT_NECK))
			continue

		var/list/slave = list()
		slave["id"] = REF(C)// C.collarID
		slave["name"] = L.real_name
		slave["price"] = C.price
		slave["bought"] = C.bought
		slave["shockcooldown"] = C.shock_cooldown;
		slave["inexportbay"] = FALSE

		var/turf/curr = get_turf(src)
		if(pos.z == curr.z) //Distance/Direction calculations for same z-level only
			slave["coords"] = "[pos.x], [pos.y], [pos.z]"
			slave["dist"] = max(get_dist(curr, pos), 0) //Distance between the machine and slave turfs
			slave["degrees"] = round(Get_Angle(curr, pos)) //0-360 degree directional bearing, for more precision.

			var/area/A = get_area(get_turf(L))
			if (istype(A, /area/slavers/export))
				slave["inexportbay"] = TRUE

			switch(L.stat)
				if(CONSCIOUS)
					slave["stat"] = "Conscious"
					slave["statstate"] = "good"
				if(SOFT_CRIT)
					slave["stat"] = "Conscious"
					slave["statstate"] = "average"
				if(UNCONSCIOUS)
					slave["stat"] = "Unconscious"
					slave["statstate"] = "average"
				if(DEAD)
					slave["stat"] = "Dead"
					slave["statstate"] = "bad"
		else
			slave["stat"] = "Unknown"
			slave["statstate"] = "grey"

		slaves += list(slave) //Add this slave to the list of slaves
	data["slaves"] = slaves
	return data

/obj/machinery/computer/slavery/ui_act(action, params)
	if(..())
		return

	var/collarID = params["id"]
	var/obj/item/electropack/shockcollar/slave/collar

	if(collarID)
		for(var/tracked_slave in GLOB.tracked_slaves)
			var/obj/item/electropack/shockcollar/slave/C = tracked_slave
			if (REF(C) == collarID)
				collar = C;
				break

	switch(action)


		if ("makePriorityAnnouncement")
			// priority_announce("Announcement.", sender_override = "Beep Beep upgate")
			var/datum/bank_account/bank = SSeconomy.get_dep_account(ACCOUNT_CAR)
			priority_announce("Station credits: [bank.account_balance], Deposit: [GLOB.slavers_credits_deposits], Balance: [GLOB.slavers_credits_balance], Total: [GLOB.slavers_credits_total]", sender_override = "Bank status")
			// var/is_ai = issilicon(user)
			// if(!SScommunications.can_announce(user, is_ai))
			// 	to_chat(user, "<span class='alert'>Intercomms recharging. Please stand by.</span>")
			// 	return
			// var/input = stripped_input(user, "Please choose a message to announce to the station crew.", "What?")
			// if(!input || !user.canUseTopic(src, !issilicon(usr)))
			// 	return
			// if(!(user.can_speak())) //No more cheating, mime/random mute guy!
			// 	input = "..."
			// 	to_chat(user, "<span class='warning'>You find yourself unable to speak.</span>")
			// else
			// 	input = user.treat_message(input) //Adds slurs and so on. Someone should make this use languages too.
			// SScommunications.make_announcement(user, is_ai, input)
			// deadchat_broadcast(" made a priority announcement from <span class='name'>[get_area_name(usr, TRUE)]</span>.", "<span class='name'>[user.real_name]</span>", user)

		if("purchaseSupplies")
			priority_announce("Purchase Supplies.", sender_override = "Beep Beep upgate")

		if("setPrice")
			var/newPrice = input(usr, "The station will need to pay this to get the slave back.", "Set slave price", 4000) as num
			if(!newPrice)
				priority_announce("New price empty.", sender_override = "Set price")

			newPrice = clamp(round(newPrice), 1, 1000000)
			collar.price = newPrice

		if("export")
			// var/area/curr = get_area(get_turf(collar.loc))

		// if (istype(curr, /area/slavers/export))
			// priority_announce("EXPORTING...", sender_override = "Set price")
			// var/area/thearea  = /area/slavers/export

			// if(!curr)
			// 	priority_announce("No area found", sender_override = "Set price")
			// 	return

			// var/list/L = list()
			// for(var/turf/T in get_area_turfs(curr.type))
			// 	L+=T
			// if(!L || !L.len)
			// 	say("Error: No destination found.")
			// 	return

			// var/slaver_crew_name = /datum/antagonist/slaver.get_team().slaver_crew_name
			// var/datum/antagonist/slaver.get_team()
			// priority_announce("The [GLOB.slavers_team_name]", sender_override = "Set price")

			// var/datum/bank_account/bank = SSeconomy.get_dep_account(ACCOUNT_CAR)
			// if(bank)
			// 	bank.adjust_money(-1000)
			GLOB.slavers_credits_deposits -= collar.price
			GLOB.slavers_credits_balance += collar.price
			GLOB.slavers_credits_total += collar.price
			GLOB.slavers_slaves_sold++


			new /obj/effect/temp_visual/dir_setting/ninja(get_turf(collar.loc), collar.loc.dir)
			// var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			// s.set_up(3, 1, collar.loc)
			// s.start()

			playsound(get_turf(src.loc), 'sound/effects/bamf.ogg', 50, 1)
			visible_message("<span class='notice'>[collar.loc] vanishes into the droppod.</span>", \
			"<span class='notice'>You are taken by the droppod.</span>")

			var/area/pod_storage_area = locate(/area/centcom/supplypod/podStorage) in GLOB.sortedAreas
			var/mob/living/M = collar.loc

			priority_announce("[M.real_name] has been returned to the station.", sender_override = "[GLOB.slavers_team_name] Transmission")
			var/obj/structure/closet/supplypod/centcompod/exportPod = new(pick(get_area_turfs(pod_storage_area)))
			var/obj/effect/landmark/observer_start/dropzone = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
			M.forceMove(exportPod) //and forceMove any atom/moveable into the supplypod

			new /obj/effect/pod_landingzone(dropzone.loc, exportPod) //Then, create the DPTarget effect, which will eventually forceMove the temp_pod to it's location

			qdel(collar)
		// else
		// 	priority_announce("Nope", sender_override = "Set price")

		if("shock")
			var/datum/signal/signal = new /datum/signal
			signal.data["code"] = -1
			collar.receive_signal(signal)

		if("release")
			qdel(collar)

		if("compact_toggle")
			compact_mode = !compact_mode
			return TRUE

		if("select")
			selected_cat = params["category"]
			return TRUE

		if("buy")
			var/item_name = params["name"]
			var/list/buyable_items = list()
			for(var/category in possible_gear)
				buyable_items += possible_gear[category]
			for(var/key in buyable_items)
				var/datum/slaver_gear/SG = buyable_items[key]
				if(SG.name == item_name)
					if(GLOB.slavers_credits_balance < SG.cost)
						say("Insufficent credits!")
						return

					GLOB.slavers_credits_balance -= SG.cost
					say("Supplies inbound!")

					addtimer(CALLBACK(src, .proc/dropSupplies, SG.build_path), rand(4,8) * 10)
					// dropSupplies(SG.build_path)

					return TRUE




/obj/machinery/computer/slavery/proc/dropSupplies(item)

	// Pick random drop location somewhere in the export zone.
	var/list/L = list()
	for(var/turf/T in get_area_turfs(/area/slavers/export))
		L+=T
	if(!L || !L.len)
		to_chat(usr, "No dropzone available.")
		return
	var/drop_location = pick(L)

	var/area/pod_storage_area = locate(/area/centcom/supplypod/podStorage) in GLOB.sortedAreas
	var/obj/structure/closet/supplypod/centcompod/exportPod = new(pick(get_area_turfs(pod_storage_area)))

	// imp_in.forceMove(pick(L))
	new item(exportPod)


	// var/mob/living/M = collar.loc


	// var/obj/effect/landmark/observer_start/dropzone = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	// M.forceMove(exportPod) //and forceMove any atom/moveable into the supplypod
	new /obj/effect/pod_landingzone(drop_location, exportPod) //Then, create the DPTarget effect, which will eventually forceMove the temp_pod to it's location

	// Find References(exportPod)