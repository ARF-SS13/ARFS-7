/proc/detongueify(message) //for the half gag speech impediment function of deprivation helmets. could also be used for a standalone ring gag item.
	var/static/regex/tongueless_lower_1 = new("\[tdpsfjz]+", "g")
	var/static/regex/tongueless_upper_1 = new("\[TDPSFJZ]+", "g")
	var/static/regex/tongueless_lower_2 = new("\[wlvb]+", "g")
	var/static/regex/tongueless_upper_2 = new("\[WLVB]+", "g")
	var/static/regex/tongueless_lower_3 = new("\[m]+", "g")
	var/static/regex/tongueless_upper_3 = new("\[M]+", "g")
	if(message[1] != "*")
		message = tongueless_lower_1.Replace(message, pick("h", "hh"))
		message = tongueless_upper_1.Replace(message, pick("H", "HH"))
		message = tongueless_lower_2.Replace(message, pick("ooh", "uuh"))
		message = tongueless_upper_2.Replace(message, pick("OOH", "UUH"))
		message = tongueless_lower_3.Replace(message, pick("nn"))
		message = tongueless_upper_3.Replace(message, pick("NN"))
	return message