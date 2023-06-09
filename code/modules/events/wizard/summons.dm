/datum/round_event_control/wizard/summonguns //The Classic
	name = "Summon Guns"
	weight = 1
	typepath = /datum/round_event/wizard/summonguns
	max_occurrences = 1
	earliest_start = 0 MINUTES
	can_be_midround_wizard = FALSE // not removing it completely yet
	description = "Summons a gun for everyone. Might turn people into survivalists."

/datum/round_event_control/wizard/summonguns/New()
	if(CONFIG_GET(flag/no_summon_guns))
		weight = 0
	..()

/datum/round_event/wizard/summonguns/start()
	rightandwrong(SUMMON_GUNS, null, 10)

/datum/round_event_control/wizard/summonmagic //The Somewhat Less Classic
	name = "Summon Magic"
	weight = 1
	typepath = /datum/round_event/wizard/summonmagic
	max_occurrences = 1
	earliest_start = 0 MINUTES
	can_be_midround_wizard = FALSE // not removing it completely yet
	description = "Summons a magic item for everyone. Might turn people into survivalists."

/datum/round_event_control/wizard/summonmagic/New()
	if(CONFIG_GET(flag/no_summon_magic))
		weight = 0
	..()

/datum/round_event/wizard/summonmagic/start()
	rightandwrong(SUMMON_MAGIC, null, 10)
